/// CCEleven protocol implementation for Centronic Plus devices.
///
/// This class provides high-level access to device features such as time, position,
/// device info, timers, taster configuration, user data, and various settings.
/// All communication is performed using the CCEleven protocol over a generic endpoint.
///
/// Usage:
///   - Use [getTime], [setTime], [getPos], [setPos], [getDeviceInfo], etc. for device operations.
///   - Use [setTimers], [readTimer], [readActiveTimers], [getTimersStatus], [saveTimers] for timer management.
///   - Use [getButtonInfo], [setTasterInfo] for taster configuration.
///   - Use [readUserdata], [writeUserdata], [deleteUserdata] for user data operations.
///   - All methods are asynchronous and return Futures.
///
/// See also:
///   - [models.dart] for data models and enums.
///   - [const.dart] for protocol command constants.
import 'dart:async';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:cc_eleven_protocol/const.dart';
import 'package:collection/collection.dart';
import 'package:mt_interface/protocol.dart';
import 'store/store.dart';
import 'package:centronic_plus_protocol/centronic_plus.dart';

import 'message.dart';
import 'models.dart';

/// Main protocol handler for Centronic Plus CCEleven devices.
class CCEleven extends MTReaderWriter<CCElevenMessage, List<int>, CCEleven> {
  /// Create a new CCEleven protocol handler.
  CCEleven();

  final store = CPBinaryStore();

  int _idQueueCounter = -1;
  final Map<int, List<Completer<List<int>>>> _idListQueue = {};

  /// Returns the next available queue ID (u16).
  int _nextQueueId() {
    _idQueueCounter++;
    if (_idQueueCounter > 0xFFEE) {
      _idQueueCounter = 0;
    }
    return _idQueueCounter;
  }

  final List<int> _readBuffer = [];

  /// When we read this, that means the database file has been commited to device.
  final List<int> dbCommitResponse = [2, 244, 0];

  /// Handles incoming data from the endpoint.
  /// Buffers data and completes the corresponding completer when a full message is received.
  @override
  void read(List<int> data) {
    dev.log("CC ELEVEN RCV: $data");

    _readBuffer.addAll(data);

    final stxPos = _readBuffer.indexOf(0x02);
    final etxPos = _readBuffer.indexOf(0x03);

    if (etxPos == -1 && stxPos == -1) {
      return;
    }

    if (etxPos < stxPos) {
      _readBuffer.removeRange(0, stxPos);
    } else if (etxPos > -1 && stxPos == -1) {
      _readBuffer.clear();
    } else if (etxPos > stxPos) {
      final message = _readBuffer.sublist(stxPos, etxPos + 1);
      _readBuffer.removeRange(0, etxPos + 1);

      final unescaped = CCElevenMessage.unescape(message);
      final int id = CCElevenMessage.getIdFromBuffer(unescaped);
      final completers = _idListQueue[id];

      if ((completers?.length ?? 0) > 0) {
        completers?.first.complete(unescaped);
        completers?.removeAt(0);
      } else if(message.sublist(0, dbCommitResponse.length).equals(dbCommitResponse)) {
        store.onUpdate().then((_) => notifyListeners());
      }
    }
  }

  List<CCGroup> groups = [];

  /// Sends a message to the endpoint.
  Future<void> writeMessage(CCElevenMessage message) async {
    dev.log("CC ELEVEN WRT: ${message.payload}");
    endpoint.write(message.payload);
  }

  /// Sends a message and waits for a response, returning the unpacked message.
  Future<T?> writeMessageWithResponse<T extends CCElevenMessage>(T message, {int numResponses = 1}) async {
    final id = _nextQueueId();
    message.id = id;
    if(_idListQueue[id] == null) {
      _idListQueue[id] = [];
    }

    for(int i = 0; i < numResponses; i++) {
      _idListQueue[id]!.add(Completer<List<int>>());
    }

    final completer = Future.wait(_idListQueue[id]!.map((c) => c.future));

    final packed = message.pack();
    dev.log("CC ELEVEN WRT: $packed");

    await endpoint.write(packed);

    final result = await completer.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _idListQueue.remove(id);
        throw TimeoutException("Request $id timed out");
      },
    );


    if(numResponses == 1 && result.isNotEmpty) {
      message.unpack(result.first);
      return message;
    } else if (numResponses > 1) {
      final List<int> results = [];
      for (final resp in result) {
        message.unpack(resp);
        results.addAll(message.response);
      }

      message.response = results;
      
      return message;
    }

    return null;
  }

  /// Closes the endpoint.
  @override
  void closeEndpoint() {
    super.closeEndpoint();
  }

  /// Notifies listeners about updates.
  @override
  void notifyListeners() => updateStream.add(this);

  /// Gets the current device time as [DateTime].
  Future<DateTime?> getTime() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getTime,
    ));

    if (result != null) {
      final payload = result.response;
      if (payload.length >= 8) {
        final data =
            ByteData.sublistView(Uint8List.fromList(payload.sublist(0, 8)));
        final unixTime = data.getUint64(0, Endian.little);
        return DateTime.fromMillisecondsSinceEpoch(unixTime * 1000,
            isUtc: true);
      }
    }

    return DateTime.now();
  }

  /// Sets the device time to [dateTime].
  Future<void> setTime(DateTime dateTime) async {
    final unixTime = dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
    final data = ByteData(8);
    data.setUint64(0, unixTime, Endian.little);
    final payload = data.buffer.asUint8List();

    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setTime,
      payload: payload,
    ));
  }

  /// Gets the current device position as [CCElevenGeoLocation].
  Future<CCElevenGeoLocation?> getPos() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getPos,
    ));

    if (result != null) {
      final payload = result.response;
      if (payload.length == 24) {
        return CCElevenGeoLocation.fromBytes(payload);
      }
    }
    return null;
  }

  /// Sets the device position to [pos].
  Future<void> setPos(CCElevenGeoLocation pos) async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setPos,
      payload: pos.toBytes(),
    ));
  }

  /// Gets device information.
  Future<CCElevenDeviceInfo?> getDeviceInfo() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getDeviceInfo,
    ));

    if (result != null) {
      final payload = result.response;
      if (payload.length == 28) {
        return CCElevenDeviceInfo.fromBytes(payload);
      }
    }
    return null;
  }

  /// Sets the device name.
  /// Throws [ArgumentError] if name is not 1-31 bytes.
  Future<void> setDeviceName(String name) async {
    // Name is encoded as UTF-8, max 31 bytes
    final nameBytes = Uint8List.fromList(name.codeUnits);
    if (nameBytes.length < 1 || nameBytes.length > 31) {
      throw ArgumentError('Device name must be 1-31 bytes');
    }
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setDeviceName,
      payload: nameBytes,
    ));
  }

  /// Gets the device name.
  Future<String?> getDeviceName() async {
    return "";
  }

  /// Performs a factory reset on the device.
  Future<void> factoryReset() async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.factoryReset,
    ));
  }

  /// Gets the current LED intensity (0-255).
  Future<int?> getLedIntensity() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getLedIntensity,
    ));
    if (result != null) {
      final payload = result.response;
      if (payload.isNotEmpty) {
        return payload[0];
      }
    }
    return null;
  }

  /// Sets the LED intensity (0-255).
  /// Throws [ArgumentError] if intensity is out of range.
  Future<void> setLedIntensity(int intensity) async {
    if (intensity < 0 || intensity > 255) {
      throw ArgumentError('LED intensity must be 0-255');
    }
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setLedIntensity,
      payload: [intensity],
    ));
  }

  /// Gets whether BLE is always connectable.
  Future<bool?> getBleAlwaysConnectable() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getBleAlwaysConnectable,
    ));
    if (result != null) {
      final payload = result.response;
      if (payload.isNotEmpty) {
        return payload[0] != 0;
      }
    }
    return null;
  }

  /// Sets whether BLE is always connectable.
  Future<void> setBleAlwaysConnectable(bool alwaysConnectable) async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setBleAlwaysConnectable,
      payload: [alwaysConnectable ? 1 : 0],
    ));
  }

  /// Enables or disables the timer automation.
  Future<void> setAutomaticTime(bool enabled) async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setTimeAutomaticTime,
      payload: [enabled ? 1 : 0],
    ));
  }

  /// Gets the current timer automation state.
  Future<bool?> getAutomaticTime() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getAutomaticTime,
    ));
    if (result != null) {
      final payload = result.response;
      if (payload.isNotEmpty) {
        return payload[0] != 0;
      }
    }
    return null;
  }

  /// Reads user data from the device.
  /// [offset]: start offset (uint32)
  /// [len]: number of bytes to read (uint8)
  /// Returns: List<int> with the data read, or null on error.
  Future<List<int>?> readUserdata(
      {required int offset, required int len}) async {
    if (offset < 0 || offset > 0xFFFFFFFF)
      throw ArgumentError('offset out of range');

    if (len < 0 || len > 0xFF) throw ArgumentError('len out of range');

    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.readUserdata,
      payload: (ByteData(5)
            ..setUint32(0, offset, Endian.little)
            ..setUint8(4, len))
          .buffer
          .asUint8List(),
    ));

    if (result != null) {
      return result.response;
    }
    return null;
  }

  /// Writes user data to the device.
  /// [offset]: start offset (uint32)
  /// [data]: bytes to write (List<int>)
  /// Returns: number of bytes written, or null on error.
  Future<int?> writeUserdata(
      {required int offset, required List<int> data}) async {
    if (offset < 0 || offset > 0xFFFFFFFF)
      throw ArgumentError('offset out of range');

    if (data.isEmpty || data.length > 0xFF)
      throw ArgumentError('data length out of range');

    final offsetData = (ByteData(4)..setUint32(0, offset, Endian.little)).buffer.asUint8List();

    final payload = [
      ...offsetData,
      ...data,
    ];

    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.writeUserdata,
      payload: payload,
    ));

    if (result != null) {
      final resp = result.response;
      if (resp.isNotEmpty) {
        return resp[0];
      }
    }
    return null;
  }

  /// Deletes all user data on the device.
  Future<void> deleteUserdata() async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.deleteUserdata,
    ));
  }

  /// Write lock user data on the device.
  Future<bool> lockUserData() async {
    try {
      await writeMessageWithResponse(CCElevenMessage(
        command: CCElevenCommand.lockUserdata,
      ));
    } catch(e) {
      if(e is CCElevenError && e.error == CCElevenErrors.badLockState) {
        return false;
      } else {
        rethrow;
      }
    }

    return true;
  }

  /// Commits user data changes on the device.
  Future<void> commitUserData() async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.commitUserdata,
    ));
  }

  /// Gets button configuration for [buttonId].
  Future<CCElevenButtonInfo?> getButtonInfo(CCElevenButtonId buttonId) async {
    // buttonId as uint8
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getButtonInfo,
      payload: [buttonId.index],
    ));
    if (result != null) {
      final payload = result.response;
      if (payload.length >= 23) {
        return CCElevenButtonInfo(
          buttonId: CCElevenButtonId.values[payload[0]],
          command: CCElevenButtonInfoCommand.fromBytes(payload.sublist(1, 22)),
        );
      }
    }
    return null;
  }

  /// Sets button configuration for [info].
  Future<void> setButtonInfo(CCElevenButtonInfo info) async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setButtonInfo,
      payload: info.toBytes(),
    ));
  }

  /// Reads a single timer by [id].
  Future<CCElevenTimer?> readTimer(int id) async {
    final payload = [
      (id >> 8) & 0xFF,
      id & 0xFF,
    ];
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.readTimer,
      payload: payload,
    ));
    if (result != null) {
      final resp = result.response;
      if (resp.length >= 37) {
        return CCElevenTimer.deserialize(resp.sublist(0, 37));
      }
    }
    return null;
  }

  /// Reads all active timers from the device.
  List<CCElevenTimer>? timers;
  Future<List<CCElevenTimer>> readActiveTimers({bool cacheFirst = true}) async {
    if (cacheFirst && timers != null) {
      return timers!;
    }

    timers = [];

    while(true) {
      final response = await writeMessageWithResponse(CCElevenMessage(
        command: CCElevenCommand.readActiveTimers,
      ));

      if (response != null) {
        if(response.response.isEmpty) {
          break;
        } else {

          final resp = response.response;
          for (int i = 0; i + 70 <= resp.length; i += 70) {
            try {
              final timer = CCElevenTimer.deserialize(resp.sublist(i, i + 70));
              timers!.add(timer);
            } catch(e) {
              dev.log("Failed to deserialize timer from bytes: ${resp.sublist(i, i + 70)}", name: "CCEleven");
            }
          }
        }
      }
    }

    return timers!;
  }

  Future<void> removeAllTimers () async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.clearAllTimers,
    ));
  }

  Future<int> nextFreeTimerIndex () async {
    final timers = await readActiveTimers();
    if (timers.isEmpty){
      return 0;
    } else {
      return List.generate(timers.length + 1, (i) => i)
        .firstWhere((i) => !timers.any((t) => t.index == i), orElse: () => timers.length);
    }
  }

  /// Gets the timers status (used/max).
  Future<CCElevenTimersStat?> getTimersStatus() async {
    final result = await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.getTimersStatus,
    ));
    if (result != null) {
      final resp = result.response;
      if (resp.length >= 4) {
        return CCElevenTimersStat.fromBytes(resp.sublist(0, 4));
      }
    }
    return null;
  }

  /// Saves timers to persistent storage on the device.
  Future<void> saveTimers() async {
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.saveTimers,
    ));
  }

  /// Sets multiple timers on the device.
  Future<void> setTimers(List<CCElevenTimer> timers) async {
    final payload = timers.expand((t) => t.serialize()).toList();
    await writeMessageWithResponse(CCElevenMessage(
      command: CCElevenCommand.setTimers,
      payload: payload,
    ));
  }

  int getNextFreeIndex (List<CCElevenTimer> timers) {
    if (timers.isEmpty){
      return 0;
    } else {
      final indices = timers.map((e) => e.index ?? 0).toSet();
      for (int i = 0; i < indices.length + 1; i++) {
        if (!indices.contains(i)) {
          return i;
        }
      }
      return indices.length;
    }
  }

  Iterable<CPFeatures> getCommonFeatures(List<CentronicPlusNode> nodes) {
    final commonFeatures = nodes.first.features.toSet();
    for (final node in nodes.skip(1)) {
      commonFeatures.retainAll(node.features.toSet());
    }
    return commonFeatures;
  }

  List<CPAvailableCommands> getSharedCommands(List<CentronicPlusNode> nodes) {
    if(nodes.isEmpty) return [];
    
    List<CPAvailableCommands> commands = [];
    final commonFeatures = getCommonFeatures(nodes);

    commands = [];
    
    if (commonFeatures.contains(CPFeatures.moveUp)) {
      commands.add(CPAvailableCommands.up);
    }
    if (commonFeatures.contains(CPFeatures.moveDown)) {
      commands.add(CPAvailableCommands.down);
    }
    if (commonFeatures.contains(CPFeatures.moveStop)) {
      commands.add(CPAvailableCommands.stop);
    }
    if (commonFeatures.contains(CPFeatures.moveTo)) {
      commands.add(CPAvailableCommands.moveTo);
    }
    if (commonFeatures.contains(CPFeatures.intermediatePosition1)) {
      commands.add(CPAvailableCommands.pos1);
    }
    if (commonFeatures.contains(CPFeatures.intermediatePosition2)) {
      commands.add(CPAvailableCommands.pos2);
    }
    if (commonFeatures.contains(CPFeatures.sunProtection)) {
      commands.add(CPAvailableCommands.sunProtectionOn);
      commands.add(CPAvailableCommands.sunProtectionOff);
    }
    if (commonFeatures.contains(CPFeatures.onOff)) {
      commands.add(CPAvailableCommands.on);
      commands.add(CPAvailableCommands.off);
    }
    
    // dev.log("Available commands: ${commands.map((c) => c.name).toList()}", name: "_CCElevenClockState");

    return commands;
  }



}
