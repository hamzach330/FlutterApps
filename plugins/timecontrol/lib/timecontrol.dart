library timecontrol_protocol;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/message.dart';
import 'package:mt_interface/queue.dart';
import 'package:version/version.dart';

part 'package:timecontrol_protocol/message.dart';
part 'package:timecontrol_protocol/queue.dart';
part 'package:timecontrol_protocol/parameters.dart';

class Timecontrol<Message_T extends TimecontrolMessage>
    extends MTReaderWriter<Message_T, List<int>, Timecontrol> {
  final _queue = TimecontrolQueue();
  final _read = 0x80;

  TCOperationModeParam operationMode = TCOperationModeParam();
  TCOperationModeType? _type;
  TCSunThresholdParam? _internalSensorSun;
  int? _internalSensorDawn;
  int? _windSensorThreshold;
  int? _rainSensorDelay;
  int? _frostSensorDelay;
  (int, int)? position;
  final List<int> _astroTableSunrise = [];
  final List<int> _astroTableSunset = [];
  final List<TCClockParam> _clocks = [];

  int? thresSunInternal;
  int? thresDawnInternal;
  int? thresWind;
  int? delayFrost;
  int? delayRain;
  bool? rain;
  bool? frost;

  int? sunValue;
  int? windValue;
  int? dawnValue;
  bool? rainValue;

  Timer? _timer;
  Completer? _initiate;
  @override
  void read(data) {
    _queue.unpack(data);
  }

  Future<T?> _write<T extends Message_T>(T message) async {
    _queue.add(message);
    await message.slot.future;
    dev.log(
        ">>> ${message.packedRequest?.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))}");
    await endpoint.write(message.packedRequest ?? []);
    await message.completer.future;
    dev.log(
        "<<< ${message.packedResponse?.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))}");
    return message;
  }

  @override
  Future<void> writeMessage(Message_T message) async {
    await _write(message);
  }

  Future<T?> writeMessageWithResponse<T extends Message_T>(T message) async {
    return await _write(message).timeout(Duration(seconds: 10));
  }

  @override
  void notifyListeners() => updateStream.add(this);

  Future<List<int>?> _writeRaw(List<int> data, {withResponse = true}) async {
    if (withResponse == true) {
      return (await writeMessageWithResponse(
              TimecontrolMessage(data, withResponse: withResponse)
                  as Message_T))
          ?.unpackedResponse;
    } else {
      await writeMessage(
          TimecontrolMessage(data, withResponse: withResponse) as Message_T);
      return null;
    }
  }

  Future<void> startPolling() async {
    // _initiate = Completer();
    await _poll();
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(const Duration(seconds: 5), _poll);

    // return _initiate?.future;
  }

  void stopPolling() {
    //  _queue.wipe();
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll([Timer? _]) async {
    await getOperationMode(force: true);
    final lightSensorValues = operationMode.lightSensorExternal
        ? await getExternalSensorValue()
        : operationMode.lightSensorInternal
            ? await getInternalSensorValue()
            : null;

    if ((lightSensorValues?.length ?? 0) > 0) {
      sunValue = lightSensorValues?[0];
    }
    if ((lightSensorValues?.length ?? 0) > 1) {
      dawnValue = lightSensorValues?[1];
    }
    windValue = operationMode.windSensor ? await getWindSensorValue() : null;
    rainValue = operationMode.windSensor ? await getRainSensorValue() : null;
    frost =
        operationMode.temperatureActive ? await getFrostSensorValue() : null;

    thresSunInternal = (await getThresholdSensorSun()).thresOut;
    thresDawnInternal = await getThresholdSensorDawn();
    thresWind = await getThresholdWindSensor();
    delayFrost = await getDelayFrostSensor();
    delayRain = await getDelayRainSensor();
    rain = await getRainSensorValue();
    frost = await getFrostSensorValue();
    position = await getPosition(TCClockChannel.wired);
    dev.log("POSITION: $position");

    if (_initiate?.isCompleted == false) {
      _initiate?.complete();
      _initiate = null;
    }
    notifyListeners();
  }

  Future<Version> getVersion() async {
    final request =
        await writeMessageWithResponse(TimecontrolMessage([0x81]) as Message_T);
    return Version.parse(request?.unpackedResponse?.join(".") ?? "0.0" + ".0");
  }

  /// Get initial setup
  Future<(bool, DateTime?)> getSetupDate() async {
    final result = await _writeRaw([0x02 | _read]);
    if (result == null) {
      return (false, null);
    }

    DateTime? time;
    time = DateTime(
      result[5] + 2000,
      result[4],
      result[3],
      result[2],
      result[1],
    );
    return (result[0] > 0, time);
  }

  // /// Set initial setup time - unsupported, set by the device itself
  // Future<void> setSetupDate () async {
  //   await _writeRaw([0x02, 12, 14, 2, 3, 25], withResponse: false);
  // }

  Future<List<int>?> getCycles() async {
    return await _writeRaw([0x83]);
  }

  /// Get overall drive time
  Future<List<int>?> getOperationTime() async {
    return await _writeRaw([0x84]);
  }

  /// End bluetooth mode
  Future<void> btEnd() async {
    await _writeRaw([0x05], withResponse: false);
  }

  /// Enable / disable test mode
  Future<void> setTestMode(int mode) async {
    await _writeRaw([0x06, mode], withResponse: false);
  }

  /// Enable test mode
  Future<bool> getTestMode(int mode) async {
    final result = await _writeRaw([0x06 | _read, mode], withResponse: true);
    return result?.first == 1;
  }

  /// Factory reset
  Future<void> reset() async {
    // operationMode.windDetected = false;
    // operationMode.temperatureActive = false;
    // operationMode.automaticSensor = false;
    // operationMode.dawnMode = false;
    // operationMode.windSensor = false;
    // operationMode.lightSensorExternal = false;
    // operationMode.lightSensorInternal = false;
    // operationMode.winter = false;
    // operationMode.sunProtection = false;
    // operationMode.amTimeDisplay = false;
    // operationMode.setupComplete = false;
    // operationMode.memo = false;
    // operationMode.random = false;
    // operationMode.automatic = false;
    // operationMode.unused2 = false;
    // operationMode.unused1 = false;

    // await setOperationMode();
    await _writeRaw([0x07], withResponse: false);
  }

  /// Set datetime
  Future<void> setDateTime(DateTime date) async {
    if (date.year < 2000 || date.year > 2099) {
      throw ("Invalid year: Value > 2000 < 2099 required");
    }
    await _writeRaw(
        [0x08, date.minute, date.hour, date.day, date.month, date.year - 2000],
        withResponse: false);
  }

  /// Get configured datetime
  Future<DateTime?> getDateTime() async {
    final result = await _writeRaw([0x08 | _read]);

    if (result != null) {
      final time = DateTime(
        result[4] + 2000,
        result[3],
        result[2],
        result[1],
        result[0],
      );
      return time;
    }

    return null;
  }

  /// Set summer / winter mode
  Future<void> setSummerTime(bool type) async {
    await _writeRaw([0x09, type ? 1 : 0], withResponse: false);
  }

  /// Get summer / winter mode
  Future<bool> getSummerTime() async {
    return (await _writeRaw([0x09 | _read]) ?? [0]).first > 0;
  }

  /// Set operation type (0 - shutter, 1 - awning, 2 - screen)
  Future<List<int>?> setType(TCOperationModeType type) async {
    _type = type;
    return await _writeRaw([0x0A, type.index], withResponse: false);
  }

  /// Get operation type (0 - shutter, 1 - awning, 2 - screen)
  Future<TCOperationModeType?> getType({bool force = false}) async {
    if (_type == null || force == true) {
      final result = await _writeRaw([0x0A | _read]);
      if (result != null) {
        _type = TCOperationModeType.values[result[0]];
        return TCOperationModeType.values[result[0]];
      }
      return TCOperationModeType.Shutter;
    } else {
      return _type;
    }
  }

  /// Set operation mode
  Future<void> setOperationMode() async {
    await _writeRaw([0x0B, ...operationMode._raw], withResponse: false);
  }

  /// Get operation mode
  Future<TCOperationModeParam?> getOperationMode({bool force = false}) async {
    if (!force && operationMode.initialized) {
      return operationMode;
    }
    final result = await _writeRaw([0x0B | _read]) ?? [0x00, 0x00];
    operationMode.initialized = true;
    if (result.length == 2) {
      operationMode.update(result.sublist(0, 2));
    } else if (result.length == 3) {
      operationMode.update(result.sublist(0, 3));
    }
    return operationMode;
  }

  /// Set runtime in seconds (low / high)
  Future<void> setRuntime(double runtime) async {
    final rt = (runtime * 10).toInt();
    await _writeRaw([0x0C, rt & 0xFF, (rt >> 8) & 0xFF], withResponse: false);
  }

  /// Get runtime in seconds (low / high)
  Future<double?> getRuntime() async {
    final runtime = await _writeRaw([0x0C | _read]);
    if (runtime != null) {
      return ((runtime[1] << 8) | runtime[0]) / 10;
    }

    return null;
  }

  Future<void> setCorrectionFactors(
      int start, int upDownPercent, int reactionTime) async {
    await _writeRaw([0x0D, start, upDownPercent, reactionTime],
        withResponse: false);
  }

  Future<List<int>?> getCorrectionFactors() async {
    return await _writeRaw([0x0D | _read]);
  }

  // /// Set fabric tension in seconds
  // Future<void> setFabricTension (double tension) async {
  //   await _writeRaw([0x0D, (tension * 10).toInt()], withResponse: false);
  // }

  // /// Get fabric tension in seconds
  // Future<double> getFabricTension () async {
  //   final result = await _writeRaw([0x0D | _read]);
  //   if(result == null || result.isEmpty) {
  //     return 0;
  //   } else {
  //     return result.first / 10;
  //   }
  // }

  /// Set turnaround time in seconds
  Future<void> setTurnaround(double time) async {
    final val = (time * 10).toInt();
    await _writeRaw([0x0E, val], withResponse: false);
  }

  /// Get turnaround time in seconds
  Future<double> getTurnaround() async {
    final result = await _writeRaw([0x0E | _read]);
    if (result == null || result.isEmpty) {
      return 0;
    } else {
      return result.first / 10;
    }
  }

  /// Set external control device
  Future<void> setEnableAdditionalSensors(int groupDevice) async {
    await _writeRaw([0x0F, groupDevice], withResponse: false);
  }

  /// Get external control device
  Future<int?> getEnableAdditionalSensors() async {
    return (await _writeRaw([0x0F | _read]))?.firstOrNull;
  }

  /// Set threshold for internal sun sensor
  Future<void> setInternalSensorSun(TCSunThresholdParam params) async {
    _internalSensorSun = params;
    await _writeRaw([0x10, ...params._raw], withResponse: false);
  }

  /// Get threshold for internal sun sensor
  Future<TCSunThresholdParam> getThresholdSensorSun(
      {bool force = false}) async {
    if (_internalSensorSun == null || force == true) {
      final result = TCSunThresholdParam((await _writeRaw([0x10 | _read])));
      _internalSensorSun = result;
      return result;
    } else {
      return _internalSensorSun!;
    }
  }

  // /// Set threshold for external sun sensor
  // Future<void> setExternalSensorSun (TCSunThresholdParam params) async {
  //   _externalSensorSun = params;
  //   await _writeRaw([0x11, ...params._raw], withResponse: false);
  // }

  // /// Get threshold for external sun sensor
  // Future<TCSunThresholdParam> getExternalSensorSun ({bool force = false}) async {
  //   if(_externalSensorSun == null || force == true) {
  //     final result = TCSunThresholdParam((await _writeRaw([0x11 | _read])));
  //     _externalSensorSun = result;
  //     return result;
  //   } else {
  //     return _externalSensorSun!;
  //   }
  // }

  /// Set threshold for internal dawn sensor
  Future<void> setInternalSensorDawn(int threshold) async {
    _internalSensorDawn = threshold;
    await _writeRaw([0x12, threshold], withResponse: false);
  }

  /// Get threshold for internal dawn sensor
  Future<int> getThresholdSensorDawn({bool force = false}) async {
    if (_internalSensorDawn == null || force == true) {
      final result = (await _writeRaw([0x12 | _read]))?.first ?? 0;
      _internalSensorDawn = result;
      return result;
    } else {
      return _internalSensorDawn!;
    }
  }

  /// Set threshold for external dawn sensor
  // Future<void> setExternalSensorDawn (int threshold) async {
  //   _externalSensorDawn = threshold;
  //   await _writeRaw([0x13, threshold], withResponse: false);
  // }

  /// Get threshold for external dawn sensor
  // Future<int> getExternalSensorDawn ({bool force = false}) async {
  //   if(_externalSensorDawn == null || force == true) {
  //     final result = (await _writeRaw([0x13 | _read]))?.first ?? 0;
  //     _externalSensorDawn = result;
  //     return result;
  //   } else {
  //     return _externalSensorDawn!;
  //   }
  // }

  // /// Set internal sensor value
  // Future<void> setInternalSensorValue (int threshold) async {
  //   await _writeRaw([0x14, threshold], withResponse: false);
  // }

  /// Get internal sensor value
  Future<List<int>> getInternalSensorValue() async {
    final result = await _writeRaw([0x14 | _read]);
    return result ?? [0, 0];
  }

  // /// Set external sensor value
  // Future<void> setExternalSensorValue (int threshold) async {
  //   await _writeRaw([0x15, threshold], withResponse: false);
  // }

  /// Get external sensor value
  Future<List<int>> getExternalSensorValue() async {
    final result = await _writeRaw([0x15 | _read]);
    return result ?? [0, 0];
  }

  /// Set wind sensor threshold
  Future<void> setWindSensorThreshold(int threshold) async {
    _windSensorThreshold = threshold;
    await _writeRaw([0x16, threshold], withResponse: false);
  }

  /// Get wind sensor threshold
  Future<int> getThresholdWindSensor({bool force = false}) async {
    if (_windSensorThreshold == null || force == true) {
      final result = (await _writeRaw([0x16 | _read]))?.first ?? 0;
      _windSensorThreshold = result;
      return result;
    } else {
      return _windSensorThreshold!;
    }
  }

  /// Set wind sensor value
  Future<void> setWindSensorValue(int threshold) async {
    await _writeRaw([0x17, threshold], withResponse: false);
  }

  /// Get wind sensor value
  Future<int> getWindSensorValue() async {
    return (await _writeRaw([0x17 | _read]))?.first ?? 0;
  }

  /// Set rain delay
  Future<void> setRainSensorDelay(int value) async {
    _rainSensorDelay = value;
    await _writeRaw([0x18, value & 0xFF, value >> 8 & 0xFF],
        withResponse: false);
  }

  /// Get rain delay
  Future<int> getDelayRainSensor({bool force = false}) async {
    if (_rainSensorDelay == null || force == true) {
      final response = await _writeRaw([0x18 | _read]) ?? [0, 0];
      final result = (response[1] << 8) | response[0];
      _rainSensorDelay = result;
      return result;
    } else {
      return _rainSensorDelay!;
    }
  }

  /// Set rain value
  Future<void> setRainSensorValue(int value) async {
    await _writeRaw([0x19, value], withResponse: false);
  }

  /// Get rain value
  Future<bool> getRainSensorValue() async {
    return (await _writeRaw([0x19 | _read]) ?? [0]).first > 0;
  }

  /// Set rain delay
  Future<void> setFrostSensorDelay(int value) async {
    _frostSensorDelay = value;
    await _writeRaw([0x1A, value & 0xFF, value >> 8 & 0xFF],
        withResponse: false);
  }

  /// Get rain delay
  Future<int> getDelayFrostSensor({bool force = false}) async {
    if (_frostSensorDelay == null || force == true) {
      final response = await _writeRaw([0x1a | _read]) ?? [0, 0];
      final result = (response[1] << 8) | response[0];
      _frostSensorDelay = result;
      return result;
    } else {
      return _frostSensorDelay!;
    }
  }

  /// Set rain value
  Future<void> setFrostSensorValue(int value) async {
    await _writeRaw([0x1B, value], withResponse: false);
  }

  /// Get rain value
  Future<bool> getFrostSensorValue() async {
    return (await _writeRaw([0x1B | _read]) ?? [0]).first > 0;
  }

  Future<List<int>?> moveUp(TCClockChannel channel) async {
    return await moveToPosition(0, channel, slat: 0);
  }

  Future<List<int>?> moveDown(TCClockChannel channel) async {
    return await moveToPosition(100, channel, slat: 100);
  }

  Future<List<int>?> moveToPosition(int percent, TCClockChannel channel,
      {int slat = 0}) async {
    return await _writeRaw(
        [0x20, 100 - percent, 100 - slat, ...channel.toBytes()],
        withResponse: false);
  }

  Future<(int, int)?> getPosition(TCClockChannel channel,
      {int slat = 0}) async {
    final result = await _writeRaw([0x13 | _read], withResponse: true);

    if (result != null) {
      return (result[0], result[1]); // 0 is position, 1 is slat
    }
    return null;
  }

  Future<List<int>?> movePreset1(TCClockChannel channel) async {
    return await _writeRaw([0x22, ...channel.toBytes()], withResponse: false);
  }

  Future<List<int>?> movePreset2(TCClockChannel channel) async {
    return await _writeRaw([0x23, ...channel.toBytes()], withResponse: false);
  }

  Future<List<int>?> moveStop(TCClockChannel channel) async {
    return await _writeRaw([0x24, ...channel.toBytes()], withResponse: false);
  }

  /// Set Astro table (Sunrise)
  Future<void> setAstroTableSunrise(List<int> astro) async {
    _astroTableSunrise.clear();
    _astroTableSunrise.addAll(astro);
    for (int i = 0; i < 4; i++) {
      if (i == 3) {
        final data = Int8List.fromList(
            astro.sublist(i * 12, min(i * 12 + 11, astro.length)));
        await _writeRaw([0x1E, i, ...Uint8List.sublistView(data)],
            withResponse: false);
      } else {
        final data = Int8List.fromList(
            astro.sublist(i * 12, min(i * 12 + 12, astro.length)));
        await _writeRaw([0x1E, i, ...Uint8List.sublistView(data)],
            withResponse: false);
      }
    }
  }

  /// Get Astro table (Sunrise)
  Future<List<int>> getAstroTableSunrise({bool force = false}) async {
    // if(_astroTableSunrise.isNotEmpty && force == false) {
    //   return _astroTableSunrise;
    // }

    List<int> astro = [];
    for (int i = 0; i < 4; i++) {
      final res = await _writeRaw([0x1E | _read, i], withResponse: true);
      if (res != null) {
        final data = Int8List.sublistView(Uint8List.fromList(res));
        final actual = data.sublist(0, data.length);
        astro.addAll(actual);
      }
    }

    _astroTableSunrise
      ..clear()
      ..addAll(astro);
    return astro;
  }

  /// Set Astro table (Sunset)
  Future<void> setAstroTableSunset(List<int> astro) async {
    _astroTableSunset.clear();
    _astroTableSunset.addAll(astro);
    for (int i = 0; i < 4; i++) {
      if (i == 3) {
        final data = Int8List.fromList(
            astro.sublist(i * 12, min(i * 12 + 11, astro.length)));
        await _writeRaw([0x1F, i, ...Uint8List.sublistView(data)],
            withResponse: false);
      } else {
        final data = Int8List.fromList(
            astro.sublist(i * 12, min(i * 12 + 12, astro.length)));
        await _writeRaw([0x1F, i, ...Uint8List.sublistView(data)],
            withResponse: false);
      }
    }
  }

  /// Get Astro table (Sunset)
  Future<List<int>> getAstroTableSunset({bool force = false}) async {
    // if(_astroTableSunset.isNotEmpty && force == false) {
    //   return _astroTableSunset;
    // }
    List<int> astro = []; // List.filled(48, 0x00);

    for (int i = 0; i < 4; i++) {
      final res = await _writeRaw([0x1F | _read, i], withResponse: true);
      if (res != null) {
        final data = Int8List.sublistView(Uint8List.fromList(res));
        final actual = data.sublist(0, data.length);
        astro.addAll(actual);
      }
    }

    _astroTableSunset
      ..clear()
      ..addAll(astro);
    return astro;
  }

  /// Set Astro offset
  Future<void> setAstroOffset(TCAstroOffsetParam offset) async {
    await _writeRaw([0x1D, ...offset._raw], withResponse: false);
  }

  /// Get Astro offset
  Future<TCAstroOffsetParam?> getAstroOffset() async {
    final result = (await _writeRaw([0x1D | _read], withResponse: true));
    final config = TCAstroOffsetParam(result);
    return config;
  }

  /// Set upper end position (Sunset)
  /// [posId] - 1 or 2 (1 - upper end position, 2 - lower end position)
  /// [setOrDelete] - 1 (set), 2 (delete), 3 (set conver and slat positions as percentage value)
  /// [coverPosition] - 0-100
  /// [slatPosition] - 0-100
  Future<void> configurePreset(TCClockChannel channel, int posId,
      [int setOrDelete = 1,
      int coverPosition = 0,
      int slatPosition = 0]) async {
    await _writeRaw([
      0x25,
      ...channel.toBytes(),
      posId = posId,
      setOrDelete,
      coverPosition,
      slatPosition
    ], withResponse: false);
  }

  Future<List<int>?> readPreset(TCClockChannel channel, int posId) async {
    final result = await _writeRaw(
        [0x25 | _read, ...channel.toBytes(), posId = posId],
        withResponse: true);
    return result;
  }

  /// Set Lower end position (Sunset)
  // Future<void> configurePreset2 (int id, TCPresetOption opt) async {
  //   await _writeRaw([0x26, id, opt.value], withResponse: false);
  // }

  Future<void> learn(TCClockChannel channel, TCLearn opt,
      [int correction = 0]) async {
    // if(opt == TCLearn.responseTime || opt == TCLearn.none) {
    //   return;
    // }
    await _writeRaw([0x26, ...channel.toBytes(), opt.value],
        withResponse: false);
    // await _writeRaw([0x26, ...channel.toBytes(), opt.value], withResponse: false);
  }

  Future<List<int>?> readLearn(TCClockChannel channel) async {
    final result = await _writeRaw([0x26 | _read, ...channel.toBytes()],
        withResponse: true);
    return result;
  }

  Future<void> setDeviceName(String value) async {
    final data = utf8.encode(value).toList();
    final len = data.length;

    if (len < 21) {
      data.addAll(List.filled(21 - len, 0x20));
    }

    dev.log("Set device name: $value ($data)");
    await _writeRaw([0x27, ...data], withResponse: false);
  }

  Future<List<TCClockParam>> getTimeProg({
    TCClockChannel channel = TCClockChannel.wired,
    bool force = false
  }) async {
    if (_clocks.isNotEmpty && force == false) {
      // TODO: Caching disabled during development
      // return _clocks;
    }

    final List<TCClockParam> clocks = [];
    final List<TCClockParam> mergedClocks = [];

    for (int day = 0; day < 7; day++) {
      final result = await _getTimeProg(day: day);
      clocks.addAll(result);
    }

    print("CLOCK COUNT: ${clocks.length}");

    for (int i = clocks.length; i > 0; i--) {
      final clock = clocks.firstOrNull;

      if (clock != null) {
        print(clock.action);
        final mergers = clocks.where((c) {
          try {
            return c.minute == clock.minute &&
                c.hour == clock.hour &&
                c.action == clock.action &&
                c.moveTo == clock.moveTo &&
                c.moveSlatTo == clock.moveSlatTo;
          } catch (e) {
            rethrow;
          }
        });

        print("MERGERS: ${mergers.length} ${mergers}");

        final merged = mergers.reduce((clockA, clockB) {
          final index = clockB.days.indexOf(true);
          final days = clockA.days;
          days[index] = true;
          clockA.days = days;
          return clockA;
        });

        clocks.removeWhere((c) =>
            c.minute == clock.minute &&
            c.hour == clock.hour &&
            c.action == clock.action &&
            c.moveTo == clock.moveTo &&
            c.moveSlatTo == clock.moveSlatTo);

        i -= mergers.length;
        mergedClocks.add(merged);
      }
    }

    _clocks
      ..clear()
      ..addAll(mergedClocks);
    return mergedClocks;
  }

  /// Get all configurations for a given channel and day.
  /// Defaults
  /// [channel] 18 (all)
  /// [day] 0 (monday!)
  Future<List<TCClockParam>> _getTimeProg(
      {TCClockChannel channel = TCClockChannel.wired, int day = 0}) async {
    List<TCClockParam> configurations = [];
    for (int switchpoint = 0; switchpoint < TCMaxClocksPerDay; switchpoint++) {
      final result = await _writeRaw([
        0x1C | _read,
        day,
        switchpoint,

        0, // Minute
        0, // Hour
        0, // Action
        0, // Offset
        0, // Position
        0, // Slat

        ...channel.toBytes()
      ], withResponse: true);

      if (result != null && result[4] != 0) {
        configurations.add(TCClockParam.fromResponse(
            result: result, day: day, channel: channel));
      } else if (result != null && result[4] == 0) {
        /// Action == 0
        break;
      }
    }

    return configurations;
  }

  Future<void> clearTimeProg({List<TCClockParam>? clocks}) async {
    if (clocks != null) {
      _clocks
        ..clear()
        ..addAll(clocks);
    } else {
      _clocks.clear();
    }

    await _writeRaw([0x1C, 0xFF], withResponse: false);
  }

  Future<void> setTimeProg(List<TCClockParam> clocks) async {
    stopPolling();
    await Future.delayed(const Duration(milliseconds: 2000));
    await clearTimeProg(clocks: [...clocks]);

    final List<List<TCClockParam>> clocksPerDay = [[], [], [], [], [], [], []];

    for (final clock in clocks) {
      for (int day = 0; day < clock.days.length; day++) {
        if (clock.days[day] == true) {
          clocksPerDay[day].add(clock);
        }
      }
    }

    for (int day = 0; day < clocksPerDay.length; day++) {
      for (int switchpoint = 0;
          switchpoint < clocksPerDay[day].length;
          switchpoint++) {
        int action = clocksPerDay[day][switchpoint].action.value;
        if (clocksPerDay[day][switchpoint].isAstroEvening) {
          action = clocksPerDay[day][switchpoint].setBit(action, 6);
        } else if (clocksPerDay[day][switchpoint].isAstroMorning) {
          action = clocksPerDay[day][switchpoint].setBit(action, 7);
        }
        final astroOffset =
            Uint8List.fromList([clocksPerDay[day][switchpoint].astroOffset])
                .first;
        await Future.delayed(const Duration(milliseconds: 200));
        await _writeRaw([
          0x1C, // Write time program
          day,
          switchpoint,
          clocksPerDay[day][switchpoint].time.minute,
          clocksPerDay[day][switchpoint].time.hour,
          action,
          astroOffset,

          clocksPerDay[day][switchpoint].moveTo, // position
          clocksPerDay[day][switchpoint].moveSlatTo, // slat
          ...clocksPerDay[day][switchpoint].channel.toBytes()
        ], withResponse: false);
      }
    }

    Future.delayed(const Duration(milliseconds: 2000)).then((value) {
      unawaited(startPolling());
    });
  }

  Future<List<TCClockParam>> preset(
      {required TCOperationModeType mode,
      required TCPresets preset,
      TCClockChannel channel = TCClockChannel.wired}) async {
    final List<TCClockParam> clocks = [];

    final clockVersion = await getVersion();
    final buggedVersion = Version.parse("1.32.0");

    if (mode == TCOperationModeType.Awning) {
      switch (preset) {
        case TCPresets.awningShade:
          final presetClocks = [TCClockParam(), TCClockParam()];
          presetClocks[0]
            ..days = List.filled(7, true)
            ..clockType = [true, false, false]
            ..action = TCClockAction.automaticOn
            ..hour = 8
            ..minute = 0
            ..channel = channel;

          presetClocks[1]
            ..days = List.filled(7, true)
            ..clockType = [true, false, false]
            ..action = TCClockAction.move
            ..moveTo = 0
            ..hour = 16
            ..minute = 0
            ..channel = channel;

          clocks.addAll(presetClocks);
          break;
        case TCPresets.awningPermanent:
          final presetClocks = [TCClockParam(), TCClockParam()];
          presetClocks[0]
            ..days = List.filled(7, true)
            ..clockType = [true, false, false]
            ..action = TCClockAction.move
            ..moveTo = 100
            ..hour = 8
            ..minute = 0
            ..channel = channel;

          presetClocks[1]
            ..days = List.filled(7, true)
            ..clockType = [true, false, false]
            ..action = TCClockAction.automaticOn
            ..hour = 16
            ..minute = 0
            ..channel = channel;

          clocks.addAll(presetClocks);
          break;
        default:
          break;
      }
    } else {
      switch (preset) {
        case TCPresets.shutterAstro:
          final presetClocks = [TCClockParam(), TCClockParam()];
          presetClocks[0]
            ..days = List.filled(7, true)
            ..clockType = [false, true, false]
            ..action = TCClockAction.move
            ..moveTo = 100
            ..moveSlatTo = 0
            ..astroOffset = 30
            ..channel = channel;

          presetClocks[1]
            ..days = List.filled(7, true)
            ..clockType = [false, false, true]
            ..action = mode == TCOperationModeType.Shutter
                ? TCClockAction.move
                : TCClockAction.pos1
            ..moveSlatTo = 0
            ..moveTo = 0
            ..hour = 8
            ..minute = 0
            ..channel = channel;

          clocks.addAll(presetClocks);
          break;
        case TCPresets.shutterLiving:
          final presetClocks = [TCClockParam(), TCClockParam(), TCClockParam()];
          presetClocks[0]
            ..days = List.filled(7, true)
            ..clockType = [false, true, false]
            ..action = TCClockAction.move
            ..moveTo = 100
            ..moveSlatTo = 0
            ..astroOffset = 30
            ..channel = channel;

          presetClocks[1]
            ..days = [false, false, false, false, false, true, true]
            ..clockType = [true, false, false]
            ..action = mode == TCOperationModeType.Shutter
                ? TCClockAction.move
                : TCClockAction.pos1
            ..moveTo = 0
            ..moveSlatTo = 0
            ..hour = 8
            ..minute = 30
            ..channel = channel;

          presetClocks[2]
            ..days = [true, true, true, true, true, false, false]
            ..clockType = [true, false, false]
            ..action = mode == TCOperationModeType.Shutter
                ? TCClockAction.move
                : TCClockAction.pos1
            ..moveTo = 0
            ..moveSlatTo = 0
            ..hour = 7
            ..minute = 30
            ..channel = channel;

          clocks.addAll(presetClocks);
          break;
        case TCPresets.shutterSleeping:
          final presetClocks = [TCClockParam(), TCClockParam(), TCClockParam()];
          presetClocks[0]
            ..days = List.filled(7, true)
            ..clockType = [false, true, false]
            ..action = TCClockAction.move
            ..moveTo = 100
            ..moveSlatTo = 0
            ..astroOffset = 30
            ..channel = channel;
          // ..astroOffsetController.text = "30";

          presetClocks[1]
            ..days = [false, false, false, false, false, true, true]
            ..clockType = [true, false, false]
            ..action = TCClockAction.move
            ..moveTo = 0
            ..moveSlatTo = 0
            ..hour = 9
            ..minute = 0
            ..channel = channel;

          presetClocks[2]
            ..days = [true, true, true, true, true, false, false]
            ..clockType = [true, false, false]
            ..action = TCClockAction.move
            ..moveTo = 0
            ..moveSlatTo = 0
            ..hour = 8
            ..minute = 30
            ..channel = channel;

          clocks.addAll(presetClocks);
          break;
        default:
          break;
      }
    }

    if (clockVersion <= buggedVersion) {
      final fixedClocks = <TCClockParam>[];
      for (final clock in clocks) {
        if (clock.action == TCClockAction.pos1 ||
            clock.action == TCClockAction.pos2 ||
            clock.action == TCClockAction.move) {
          if (clock.clockType.first == true) {
            fixedClocks.add(TCClockParam()
              ..days = clock.days
              ..clockType = clock.clockType
              ..action = TCClockAction.automaticOff
              ..moveTo = clock.moveTo
              ..hour = clock.hour
              ..minute = clock.minute + 1
              ..channel = clock.channel);
          } else {
            fixedClocks.add(TCClockParam()
              ..days = clock.days
              ..clockType = clock.clockType
              ..action = TCClockAction.automaticOff
              ..moveTo = clock.moveTo
              ..astroOffset = clock.astroOffset + 1
              ..channel = clock.channel);
          }
        }
      }

      fixedClocks.addAll(clocks);
      return fixedClocks;
    }

    return clocks;
  }
}
