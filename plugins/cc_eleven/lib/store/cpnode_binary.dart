part of 'store.dart';

/// Binary data entry for TYPE=1 (cpNode) according to new template
class CpNodeBinaryData {
  static const int ENTRY_SIZE = 97; // Total size per cpNode entry
  
  // Field sizes according to template
  static const int TYPE_SIZE = 1;
  static const int ID_SIZE = 8;
  static const int PAN_ID_SIZE = 4;
  static const int INITIATOR_SIZE = 1;
  static const int CP_GROUP_SIZE = 8;
  static const int C_GROUP_SIZE = 8;
  static const int COUPLED_SIZE = 1;
  static const int NAME_SIZE = 32;
  static const int SERIAL_SIZE = 5;
  static const int SEMVER_SIZE = 3;
  static const int BUILD_NO_SIZE = 1;
  static const int MANUFACTURER_SIZE = 1;
  static const int ART_ID_SIZE = 12;
  static const int PARENT_MAC_SIZE = 8;
  static const int STATUS_FLAGS_SIZE = 2;
  static const int BATTERY_POWERED_SIZE = 1;
  static const int VISIBLE_SIZE = 1;

  TableEntryType type;        // 1 byte - Always cpNode (1)
  List<int> id;              // 8 bytes - MAC address as ID
  List<int> panId;           // 4 bytes - PAN ID
  int initiator;             // 1 byte - Initiator enum
  List<int> cpGroup;         // 8 bytes - Centronic Plus Group
  List<int> cGroup;          // 8 bytes - C Group
  bool coupled;              // 1 byte - Coupled flag
  String name;               // 32 bytes - Node name
  String serial;             // 5 bytes - Serial number
  List<int> semVer;          // 3 bytes - Semantic version [major, minor, patch]
  int buildNo;               // 1 byte - Build number
  int manufacturer;          // 1 byte - Manufacturer
  String artId;              // 12 bytes - Article ID
  List<int> parentMac;       // 8 bytes - Parent MAC address
  List<int> statusFlags;     // 2 bytes - Status flags
  bool batteryPowered;       // 1 byte - Battery powered flag
  bool visible;              // 1 byte - Visible flag

  CpNodeBinaryData({
    required this.type,
    required this.id,
    required this.panId,
    required this.initiator,
    required this.cpGroup,
    required this.cGroup,
    required this.coupled,
    required this.name,
    required this.serial,
    required this.semVer,
    required this.buildNo,
    required this.manufacturer,
    required this.artId,
    required this.parentMac,
    required this.statusFlags,
    required this.batteryPowered,
    required this.visible,
  });

  /// Create from CentronicPlusNode
  factory CpNodeBinaryData.fromNode(CentronicPlusNode node) {
    return CpNodeBinaryData(
      type: TableEntryType.cpNode,
      id: macStringToBytes(node.mac),
      panId: panIdStringToBytes(node.panId ?? '0'),
      initiator: node.initiator?.value ?? 0,
      cpGroup: int64ToBytes(node.groupId), // Convert groupBit to cpGroup
      cGroup: List<int>.filled(8, 0), // TODO: Map from node if available
      coupled: node.coupled,
      name: (node.name ?? '').padRight(NAME_SIZE, '\x00').substring(0, NAME_SIZE),
      serial: (node.serial ?? '').padRight(SERIAL_SIZE, '\x00').substring(0, SERIAL_SIZE),
      semVer: node.semVer != null 
          ? [node.semVer!.major, node.semVer!.minor, node.semVer!.patch]
          : [0, 0, 0],
      buildNo: 0, // TODO: Map from node.build if available
      manufacturer: node.manufacturer ?? 0,
      artId: (node.artId ?? '').padRight(ART_ID_SIZE, '\x00').substring(0, ART_ID_SIZE),
      parentMac: node.parentMac != CP_EMPTY_MAC ? macStringToBytes(node.parentMac) : List<int>.filled(8, 0),
      statusFlags: node.statusFlags.raw, // TODO: Map from node.statusFlags if available
      batteryPowered: node.isBatteryPowered,
      visible: node.visible,
    );
  }

  /// Convert to CentronicPlusNode
  CentronicPlusNode toNode(CentronicPlus cp) {
    final parentMacString = parentMac.any((b) => b != 0) ? macBytesToString(parentMac) : null;
    
    final node = CentronicPlusNode(
      cp: cp,
      mac: macBytesToString(id),
      panId: panIdBytesToString(panId),
      initiator: CPInitiator.values.firstWhere(
        (e) => e.value == initiator,
        orElse: () => CPInitiator.easy,
      ),
      coupled: coupled,
      parentMac: parentMacString,
    );
    
    // Set optional fields
    node.groupId = bytesToInt64(cpGroup); // Convert cpGroup back to groupBit
    node.name = name.replaceAll('\x00', '').trim();
    node.serial = serial.replaceAll('\x00', '').trim();
    node.version = 0; // Not in new template
    node.manufacturer = manufacturer;
    node.statusFlags = StatusFlags(raw: statusFlags);
    node.semVer = semVer[0] > 0 || semVer[1] > 0 || semVer[2] > 0
        ? Version(semVer[0], semVer[1], semVer[2])
        : null;
    node.artId = artId.replaceAll('\x00', '').trim();
    node.build = buildNo.toString(); // Map buildNo to build
    node.isBatteryPowered = batteryPowered;
    node.visible = visible;
    
    return node;
  }

  /// Serialize to bytes according to template
  List<int> serialize() {
    final data = <int>[];
    
    // enum(1) type (cpNode)
    data.add(type.value);
    
    // int(8) id
    data.addAll(_padOrTruncate(id, ID_SIZE));
    
    // int(4) panId
    data.addAll(_padOrTruncate(panId, PAN_ID_SIZE));
    
    // enum(1) initiator
    data.add(initiator);
    
    // int(8) cpGroup
    data.addAll(_padOrTruncate(cpGroup, CP_GROUP_SIZE));
    
    // int(8) cGroup
    data.addAll(_padOrTruncate(cGroup, C_GROUP_SIZE));
    
    // bool(1) coupled
    data.add(coupled ? 1 : 0);
    
    // char(32) name
    data.addAll(_stringToBytes(name, NAME_SIZE));
    
    // char(5) serial
    data.addAll(_stringToBytes(serial, SERIAL_SIZE));
    
    // int(3) semVer
    data.addAll(_padOrTruncate(semVer, SEMVER_SIZE));
    
    // int(1) buildNo
    data.add(buildNo);
    
    // int(1) manufacturer
    data.add(manufacturer);
    
    // char(12) artId
    data.addAll(_stringToBytes(artId, ART_ID_SIZE));
    
    // char(8) parentMac
    data.addAll(_padOrTruncate(parentMac, PARENT_MAC_SIZE));
    
    // int(2) statusFlags
    data.addAll(_padOrTruncate(statusFlags, STATUS_FLAGS_SIZE));
    
    // bool(1) batteryPowered
    data.add(batteryPowered ? 1 : 0);
    
    // bool(1) visible
    data.add(visible ? 1 : 0);
    
    if (data.length != ENTRY_SIZE) {
      throw StateError('Serialized data size (${data.length}) does not match expected size ($ENTRY_SIZE)');
    }
    
    return data;
  }

  /// Deserialize from bytes
  static CpNodeBinaryData deserialize(List<int> data) {
    if (data.length < ENTRY_SIZE) {
      throw ArgumentError('Invalid cpNode data length: ${data.length}');
    }
    
    int offset = 0;
    
    // enum(1) type
    final type = TableEntryType.fromValue(data[offset]);
    if (type != TableEntryType.cpNode) {
      // throw ArgumentError('Expected cpNode type, got $type');
    }
    offset += TYPE_SIZE;
    
    // int(8) id
    final id = data.sublist(offset, offset + ID_SIZE);
    offset += ID_SIZE;
    
    // int(4) panId
    final panId = data.sublist(offset, offset + PAN_ID_SIZE);
    offset += PAN_ID_SIZE;
    
    // enum(1) initiator
    final initiator = data[offset];
    offset += INITIATOR_SIZE;
    
    // int(8) cpGroup
    final cpGroup = data.sublist(offset, offset + CP_GROUP_SIZE);
    offset += CP_GROUP_SIZE;
    
    // int(8) cGroup
    final cGroup = data.sublist(offset, offset + C_GROUP_SIZE);
    offset += C_GROUP_SIZE;
    
    // bool(1) coupled
    final coupled = data[offset] != 0;
    offset += COUPLED_SIZE;
    
    // char(32) name
    final name = _bytesToString(data.sublist(offset, offset + NAME_SIZE));
    offset += NAME_SIZE;
    
    // char(5) serial
    final serial = _bytesToString(data.sublist(offset, offset + SERIAL_SIZE));
    offset += SERIAL_SIZE;
    
    // int(3) semVer
    final semVer = data.sublist(offset, offset + SEMVER_SIZE);
    offset += SEMVER_SIZE;
    
    // int(1) buildNo
    final buildNo = data[offset];
    offset += BUILD_NO_SIZE;
    
    // int(1) manufacturer
    final manufacturer = data[offset];
    offset += MANUFACTURER_SIZE;
    
    // char(12) artId
    final artId = _bytesToString(data.sublist(offset, offset + ART_ID_SIZE));
    offset += ART_ID_SIZE;
    
    // char(8) parentMac
    final parentMac = data.sublist(offset, offset + PARENT_MAC_SIZE);
    offset += PARENT_MAC_SIZE;
    
    // int(2) statusFlags
    final statusFlags = data.sublist(offset, offset + STATUS_FLAGS_SIZE);
    offset += STATUS_FLAGS_SIZE;
    
    // bool(1) batteryPowered
    final batteryPowered = data[offset] != 0;
    offset += BATTERY_POWERED_SIZE;
    
    // bool(1) visible
    final visible = data[offset] != 0;
    
    return CpNodeBinaryData(
      type: type,
      id: id,
      panId: panId,
      initiator: initiator,
      cpGroup: cpGroup,
      cGroup: cGroup,
      coupled: coupled,
      name: name,
      serial: serial,
      semVer: semVer,
      buildNo: buildNo,
      manufacturer: manufacturer,
      artId: artId,
      parentMac: parentMac,
      statusFlags: statusFlags,
      batteryPowered: batteryPowered,
      visible: visible,
    );
  }

  /// Helper: Convert string to bytes with padding/truncation
  static List<int> _stringToBytes(String str, int size) {
    final bytes = utf8.encode(str);
    if (bytes.length >= size) {
      return bytes.sublist(0, size);
    }
    return [...bytes, ...List<int>.filled(size - bytes.length, 0)];
  }

  /// Helper: Convert bytes to string, removing null terminators
  static String _bytesToString(List<int> bytes) {
    final nullIndex = bytes.indexOf(0);
    final validBytes = nullIndex >= 0 ? bytes.sublist(0, nullIndex) : bytes;
    return utf8.decode(validBytes);
  }

  /// Helper: Pad or truncate list to specific size
  static List<int> _padOrTruncate(List<int> list, int size) {
    if (list.length >= size) {
      return list.sublist(0, size);
    }
    return [...list, ...List<int>.filled(size - list.length, 0)];
  }

  /// Convert MAC string to 8 bytes
  static List<int> macStringToBytes(String mac) {
    if (mac.length != 16) {
      throw ArgumentError('MAC address must be 16 characters long');
    }
    
    final bytes = <int>[];
    for (int i = 0; i < 16; i += 2) {
      final hex = mac.substring(i, i + 2);
      bytes.add(int.parse(hex, radix: 16));
    }
    return bytes;
  }

  /// Convert 8 bytes to MAC string
  static String macBytesToString(List<int> bytes) {
    if (bytes.length != 8) {
      throw ArgumentError('MAC bytes must be exactly 8 bytes long');
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convert PAN ID string to 4 bytes
  static List<int> panIdStringToBytes(String panId) {
    // PAN ID is typically hex format (e.g., "aabbccdd")
    final id = int.parse(panId, radix: 16);
    final bytes = ByteData(4)..setUint32(0, id, Endian.little);
    return bytes.buffer.asUint8List().toList();
  }

  /// Convert 4 bytes to PAN ID string
  static String panIdBytesToString(List<int> bytes) {
    if (bytes.length != 4) {
      throw ArgumentError('PAN ID bytes must be exactly 4 bytes long');
    }
    final id = ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.little);
    return id.toRadixString(16).padLeft(8, '0');
  }

  /// Convert int64 to 8 bytes
  static List<int> int64ToBytes(int value) {
    final bytes = ByteData(8)..setUint64(0, value, Endian.little);
    return bytes.buffer.asUint8List().toList();
  }

  /// Convert 8 bytes to int64
  static int bytesToInt64(List<int> bytes) {
    if (bytes.length != 8) {
      throw ArgumentError('Bytes must be exactly 8 bytes long');
    }
    return ByteData.sublistView(Uint8List.fromList(bytes)).getUint64(0, Endian.little);
  }

  @override
  String toString() {
    return 'CpNodeBinaryData(id: ${macBytesToString(id)}, name: $name, panId: ${panIdBytesToString(panId)})';
  }
}
