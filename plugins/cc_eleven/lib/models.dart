import 'dart:typed_data';

import 'package:centronic_plus_protocol/centronic_plus.dart';

import 'const.dart';

class CCelevenUserData {
  CCelevenUserData();
}

class CCElevenDeviceInfo {
  final DateTime firstDate;
  final int serialNumber;
  final int swVersion;
  final int hwVersion;
  final String swArticleNumber;

  CCElevenDeviceInfo({
    required this.firstDate,
    required this.serialNumber,
    required this.swVersion,
    required this.hwVersion,
    required this.swArticleNumber,
  });

  factory CCElevenDeviceInfo.fromBytes(List<int> bytes) {
    DateTime firstDate;
    try {
      final firstDateData =
          ByteData.sublistView(Uint8List.fromList(bytes.sublist(0, 8)));
      final firstDateUnix = firstDateData.getUint64(0, Endian.little);
      firstDate = DateTime.fromMillisecondsSinceEpoch(
          firstDateUnix * 1000,
          isUtc: true);
    } catch (_) {
      firstDate = DateTime.now();
    }

    final serialData =
        ByteData.sublistView(Uint8List.fromList(bytes.sublist(8, 12)));
    final serialNumber = serialData.getUint32(0, Endian.little);

    final swVersion = bytes[12];
    final hwVersion = bytes[13];
    final swArticleNumber =
        String.fromCharCodes(bytes.sublist(14, 28)).trim();

    return CCElevenDeviceInfo(
      firstDate: firstDate,
      serialNumber: serialNumber,
      swVersion: swVersion,
      hwVersion: hwVersion,
      swArticleNumber: swArticleNumber,
    );
  }
}

class CCElevenTimerCommand {
  int cDevices; // uint64_t
  List<int> cpDevices; // uint64_t
  CPAvailableCommands cmd;
  int lift; // uint16_t
  int tilt; // uint16_t
  CCElevenEvoProfile? evoPro;

  CCElevenTimerCommand({
    required this.cDevices,
    required this.cpDevices,
    required this.cmd,
    required this.lift,
    required this.tilt,
    this.evoPro,
  });

  factory CCElevenTimerCommand.empty() {
    return CCElevenTimerCommand(
      cDevices: 0,
      cpDevices: List.filled(8, 0),
      cmd: CPAvailableCommands.up,
      lift: 0,
      tilt: 0,
      evoPro: null,
    );
  }
}

class CCElevenTimer {
  DateTime nextTime; // time_t (unix time)
  CCElevenTimerState type;
  int offset; // uint8_t
  int minute; // uint8_t
  int hour; // uint8_t
  int bitdays; // uint8_t
  CCElevenTimerCommand command;
  int appId; // uint16_t
  int? index; // uint16_t
  String name;

  void clear() {
    type = CCElevenTimerState(
      type: CCElevenTimerType.unused,
      active: false,
    );
    offset = 0;
    minute = 0;
    hour = 0;
    bitdays = 0;
    command = CCElevenTimerCommand.empty();
  }

  void toggleDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex > 6) {
      throw ArgumentError("Day index must be between 0 and 6.");
    }
    bitdays ^= (1 << dayIndex);
  }

  List<bool> get weekdays {
    final days = <bool>[];
    for (int i = 0; i < 7; i++) {
      days.add((bitdays & (1 << i)) != 0);
    }
    return days;
  }

  set weekdays(List<bool> days) {
    bitdays = 0;
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        bitdays |= (1 << i);
      }
    }
  }

  bool get isAstroControlled {
    return type.type == CCElevenTimerType.astroAfternoon || type.type == CCElevenTimerType.astroMorning;
  }

  bool get isMidnight {
    return hour == 0 && minute == 0;
  }

  bool get blockTimeActive {
    return !isMidnight && isAstroControlled;
  }

  void toggleMode(int modeIndex) {
    if (modeIndex < 0 || modeIndex >= CCElevenTimerType.values.length) {
      throw ArgumentError("Invalid mode index: $modeIndex");
    }
    type = CCElevenTimerState(
      type: CCElevenTimerType.values[modeIndex],
      active: type.active,
    );
  }

  void setOffset(int newOffset) {
    if (newOffset < -120 || newOffset > 120) {
      throw ArgumentError("Offset must be between -120 and 120 minutes.");
    }
    offset = newOffset;
  }

  void setTime(int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError("Hour must be between 0 and 23, and minute between 0 and 59.");
    }
    this.hour = hour;
    this.minute = minute;
  }

  DateTime get time {
    final now = DateTime.now();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }

  CCElevenTimer({
    required this.index,
    required this.nextTime,
    required this.type,
    required this.offset,
    required this.minute,
    required this.hour,
    this.bitdays = 0,
    required this.command,
    required this.appId,
    required this.name,
  });

  factory CCElevenTimer.deserialize(List<int> bytes) {
    final nextTimeUnix =
        ByteData.sublistView(Uint8List.fromList(bytes.sublist(2, 10)))
            .getInt64(0, Endian.little);
    final typeByte = bytes[10];
    final type = CCElevenTimerType.values[typeByte & 0x7F];
    final active = (typeByte & 0x80) != 0;
    final offset = ByteData.sublistView(Uint8List.fromList(bytes.sublist(11, 12))).getInt8(0);
    final minute = bytes[12];
    final hour = bytes[13];
    final weekdays = bytes[14];

    /// Actual command struct
    final cDevices =
        ByteData.sublistView(Uint8List.fromList(bytes.sublist(15, 23)))
            .getUint64(0, Endian.little);
    final cpDevices = bytes.sublist(23, 31);
    final cmd = CPAvailableCommands.values[bytes[31]];

    final lift = ((bytes[32] | bytes[33] << 8) * 100) ~/ 0xFFFF;
    final tilt = ((bytes[34] | bytes[35] << 8) * 100) ~/ 0xFFFF;
        
    final evoPro = CCElevenEvoProfile.values[bytes[36]];
    /// End command struct
    
    final appId =
        ByteData.sublistView(Uint8List.fromList(bytes.sublist(37, 39)))
            .getUint16(0, Endian.little);

    final index = bytes.length >= 2 ? ByteData.sublistView(Uint8List.fromList(bytes.sublist(0, 2))).getUint16(0, Endian.little) : null;

    final name = String.fromCharCodes(bytes.sublist(39, 70).where((c) => c != 0)).trim();

    return CCElevenTimer(
      index: index,
      nextTime:
          DateTime.fromMillisecondsSinceEpoch(nextTimeUnix * 1000, isUtc: true),
      type: CCElevenTimerState(type: type, active: active),
      offset: offset,
      minute: minute,
      hour: hour,
      bitdays: weekdays,
      command: CCElevenTimerCommand(
        cDevices: cDevices,
        cpDevices: cpDevices,
        cmd: cmd,
        lift: lift,
        tilt: tilt,
        evoPro: evoPro,
      ),
      appId: appId,
      name: name,
    );
  }

  List<int> serialize() {
    final int moveToSlat32 = (0xFFFF * (command.tilt/ 100)).toInt();
    final moveToSlat = [moveToSlat32 & 0xFF, moveToSlat32 >> 8];

    final int moveTo32 = (0xFFFF * (command.lift / 100)).toInt();
    final moveTo = [moveTo32 & 0xFF, moveTo32 >> 8];

    int typeByte = type.type.index & 0x7F;
    if (type.active) typeByte |= 0x80;

    final cmd = command;
    return [
      ...(ByteData(2)..setUint16(0, index ?? 0, Endian.little)).buffer.asUint8List(),
      ...(List.filled(8, 0)),
      typeByte,
      offset & 0xFF,
      minute & 0xFF,
      hour & 0xFF,
      bitdays & 0xFF,
      ...(ByteData(8)..setUint64(0, cmd.cDevices, Endian.little))
          .buffer
          .asUint8List(),
      ...cmd.cpDevices,
      cmd.cmd.index,
      ...moveTo,
      ...moveToSlat,
      cmd.evoPro?.index ?? 0,
      ...(ByteData(2)..setUint16(0, appId, Endian.little)).buffer.asUint8List(),
      ...name.codeUnits,
      ...List.filled(32 - name.codeUnits.length, 0),
    ];
  }
}

class CCElevenTimerWithNum {
  final int num; // uint16_t
  final CCElevenTimer timer;

  CCElevenTimerWithNum({
    required this.num,
    required this.timer,
  });
}

class CCElevenTimersStat {
  final int used; // uint16_t
  final int max; // uint16_t

  CCElevenTimersStat({
    required this.used,
    required this.max,
  });

  /// Factory to create TimersStat from a 4-byte payload.
  factory CCElevenTimersStat.fromBytes(List<int> bytes) {
    final used = ByteData.sublistView(Uint8List.fromList(bytes.sublist(0, 2))).getUint16(0, Endian.little);
    final max = ByteData.sublistView(Uint8List.fromList(bytes.sublist(2, 4))).getUint16(0, Endian.little);
    return CCElevenTimersStat(used: used, max: max);
  }
}

class CCElevenGeoLocation {
  final double latitude;
  final double longitude;
  final double elevation;

  CCElevenGeoLocation({
    required this.latitude,
    required this.longitude,
    required this.elevation,
  });

  factory CCElevenGeoLocation.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    final latitude = ByteData.sublistView(data, 0, 8).getFloat64(0, Endian.little);
    final longitude = ByteData.sublistView(data, 8, 16).getFloat64(0, Endian.little);
    final elevation = ByteData.sublistView(data, 16, 24).getFloat64(0, Endian.little);
    return CCElevenGeoLocation(
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
    );
  }

  Uint8List toBytes() {
    final data = ByteData(24);
    data.setFloat64(0, latitude, Endian.little);
    data.setFloat64(8, longitude, Endian.little);
    data.setFloat64(16, elevation, Endian.little);
    return data.buffer.asUint8List();
  }
}

class CCElevenButtonInfoCommand {
  final int cii; // 64bit
  final int cPlusGroups; // 64bit
  final CPAvailableCommands cmd; // enum8
  final int pos; // u16
  final int tilt; // u16
  // final CCElevenEvoProfile evoProfile; // enum8

  CCElevenButtonInfoCommand({
    required this.cii,
    required this.cPlusGroups,
    required this.cmd,
    required this.pos,
    required this.tilt,
    // required this.evoProfile,
  });

  factory CCElevenButtonInfoCommand.fromBytes(List<int> bytes) {
    final cii = ByteData.sublistView(Uint8List.fromList(bytes.sublist(0, 8))).getUint64(0, Endian.little);
    final cPlusGroups = ByteData.sublistView(Uint8List.fromList(bytes.sublist(8, 16))).getUint64(0, Endian.little);
    final cmd = CPAvailableCommands.values[bytes[16]];
    final pos = ByteData.sublistView(Uint8List.fromList(bytes.sublist(17, 19))).getUint16(0, Endian.little);
    final tilt = ByteData.sublistView(Uint8List.fromList(bytes.sublist(19, 21))).getUint16(0, Endian.little);
    // final evoProfile = CCElevenEvoProfile.values[bytes[21]];
    return CCElevenButtonInfoCommand(
      cii: cii,
      cPlusGroups: cPlusGroups,
      cmd: cmd,
      pos: pos,
      tilt: tilt,
      // evoProfile: evoProfile,
    );
  }

  List<int> toBytes() {
    return [
      ...(ByteData(8)..setUint64(0, cii, Endian.little)).buffer.asUint8List(),
      ...(ByteData(8)..setUint64(0, cPlusGroups, Endian.little)).buffer.asUint8List(),
      cmd.index,
      ...(ByteData(2)..setUint16(0, pos, Endian.little)).buffer.asUint8List(),
      ...(ByteData(2)..setUint16(0, tilt, Endian.little)).buffer.asUint8List(),
      // evoProfile.index,
    ];
  }
}

class CCElevenButtonInfo {
  final CCElevenButtonId buttonId;
  final CCElevenButtonInfoCommand command;

  CCElevenButtonInfo({
    required this.buttonId,
    required this.command,
  });

  List<int> toBytes() {
    return [
      buttonId.index,
      ...command.toBytes(),
    ];
  }
}

class CCElevenTimerState {
  final CCElevenTimerType type;
  final bool active;

  CCElevenTimerState({
    required this.type,
    required this.active,
  });
}
