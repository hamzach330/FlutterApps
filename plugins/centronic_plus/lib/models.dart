part of 'centronic_plus.dart';

class CPReadPanResult {
  final String pan;
  final String mac;
  final bool coupled;
  final List<int> index;
  final int qualifier;

  CPReadPanResult({
    required this.pan,
    required this.mac,
    required this.coupled,
    required this.index,
    required this.qualifier,
  });

  factory CPReadPanResult.fromV2Message(V2Message message) {
    return CPReadPanResult(
      mac : message.macAddress,
      coupled : Mutators.toBool(message.payload[12]),
      pan : Mutators.toHexString(message.payload.sublist(8, 12)),
      index: message.payload.sublist(13, 15),
      qualifier : message.payload[15]
    );
  }
}


class CPNodeEEPROM {
  final String? artId;
  final Version? version;
  final String serial;
  final String build;
  final String deviceType;
  final CPInitiator initiator;
  final String mac;

  CPNodeEEPROM({
    required this.artId,
    required this.version,
    required this.serial,
    required this.build,
    required this.deviceType,
    required this.initiator,
    required this.mac,
  });

  factory CPNodeEEPROM.fromV2Message(V2Message message) {
    final payload = message.payload;

    String? artId;
    Version? version;
    if(payload.length >  32) {
      version = Version(payload[31], payload[32], payload[33]);
    }

    if(payload.length > 37) {
      final artLo = Mutators.toHexString(payload.sublist(19, 21));
      final artHi = Mutators.toHexString(payload.sublist(34, 36));
      final artMid = Mutators.toHexString(payload.sublist(36, 38));
      artId = "$artHi${artMid.substring(1)}$artLo";
    }

    return CPNodeEEPROM(
      mac: message.macAddress,
      initiator: message.initiator,
      deviceType: message.initiator.name,
      serial: Mutators.toHexString(payload.sublist(25, 30)),
      build: Mutators.toHexString(payload.sublist(22, 24)),
      version: version,
      artId: artId,
    );
  }
}

class CPNodePage1Data {
  final StatusFlags flags;
  final int version;
  final int manufacturer;
  final CPInitiator initiator;

  CPNodePage1Data({
    required this.flags,
    required this.version,
    required this.manufacturer,
    required this.initiator,
  });

  factory CPNodePage1Data.fromV2Message(V2Message message) {
    final payload = message.payload;

    return CPNodePage1Data(
      flags: StatusFlags(raw: payload.sublist(18, 20)),
      version: payload[17],
      manufacturer: message.manufacturer,
      initiator: message.initiator,
    );
  }
}