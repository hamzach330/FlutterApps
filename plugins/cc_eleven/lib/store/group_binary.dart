part of 'store.dart';

/// Binary data entry for TYPE=3 (group)
class CCGroup {
  static const int ENTRY_SIZE = 50; // Total size per group entry (fits in 128-byte block)
  
  // Field sizes
  static const int TYPE_SIZE = 1;
  static const int ID_SIZE = 1;
  static const int NAME_SIZE = 32;
  static const int CP_GROUP_SIZE = 8;
  static const int C_GROUP_SIZE = 8;

  TableEntryType type;       // 1 byte   - Always group (3)
  int id;                    // 1 byte   - Unique group ID
  String name;               // 32 bytes - Group name
  List<int> cpGroup;         // 8 bytes  - Centronic Plus Group
  List<int> cGroup;          // 8 bytes  - C Group

  CCGroup({
    this.type = TableEntryType.group,
    required this.id,
    required this.name,
    required this.cpGroup,
    required this.cGroup,
  });

  final updateStream = StreamController<CCGroup>.broadcast();

  void notifyListeners() {
    updateStream.add(this);
  }

  /// Serialize to bytes according to template
  List<int> serialize() {
    final data = <int>[];
    
    // enum(1) type (group)
    data.add(type.value);
    
    // int(8) id
    data.addAll([id]);
    
    // char(32) name
    data.addAll(_stringToBytes(name, NAME_SIZE));
    
    // int(8) cpGroup
    data.addAll(_padOrTruncate(cpGroup, CP_GROUP_SIZE));
    
    // int(8) cGroup
    data.addAll(_padOrTruncate(cGroup, C_GROUP_SIZE));
    
    if (data.length != ENTRY_SIZE) {
      throw StateError('Serialized group data size (${data.length}) does not match expected size ($ENTRY_SIZE)');
    }
    
    return data;
  }

  /// Deserialize from bytes
  static CCGroup deserialize(List<int> data) {
    if (data.length < ENTRY_SIZE) {
      throw ArgumentError('Invalid group data length: ${data.length}');
    }
    
    int offset = 0;
    
    // enum(1) type
    final type = TableEntryType.fromValue(data[offset]);
    if (type != TableEntryType.group) {
      throw ArgumentError('Expected group type, got $type');
    }
    offset += TYPE_SIZE;
    
    // int id
    final id = data[offset];
    offset += ID_SIZE;
    
    // char(32) name
    final name = _bytesToString(data.sublist(offset, offset + NAME_SIZE));
    offset += NAME_SIZE;
    
    // int(8) cpGroup
    final cpGroup = data.sublist(offset, offset + CP_GROUP_SIZE);
    offset += CP_GROUP_SIZE;
    
    // int(8) cGroup
    final cGroup = data.sublist(offset, offset + C_GROUP_SIZE);
    
    return CCGroup(
      type: type,
      id: id,
      name: name,
      cpGroup: cpGroup,
      cGroup: cGroup,
    );
  }

  /// Helper: Convert string to bytes with padding/truncation
  static List<int> _stringToBytes(String str, int size) {
    final bytes = utf8.encode(str);
    if (bytes.length >= size) {
      return bytes.sublist(0, size);
    }
    final padding = size - bytes.length;
    return [...bytes, ...List<int>.filled(padding, 0)];
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

  /// Convert ID bytes to string
  String get idAsString {
    return id.toString();
  }

  /// Convert cpGroup bytes to int64
  int get cpGroupAsInt {
    return ByteData.sublistView(Uint8List.fromList(cpGroup)).getUint64(0, Endian.little);
  }

  /// Convert cGroup bytes to int64
  int get cGroupAsInt {
    return ByteData.sublistView(Uint8List.fromList(cGroup)).getUint64(0, Endian.little);
  }

  /// Create ID from int64
  static List<int> int64ToId(int value) {
    final bytes = ByteData(8)..setUint64(0, value, Endian.little);
    return bytes.buffer.asUint8List().toList();
  }

  /// Create group bytes from int64
  static List<int> int64ToGroupBytes(int value) {
    final bytes = ByteData(8)..setUint64(0, value, Endian.little);
    return bytes.buffer.asUint8List().toList();
  }

  @override
  String toString() {
    return 'GroupBinaryData(id: $idAsString, name: $name, cpGroup: $cpGroupAsInt, cGroup: $cGroupAsInt)';
  }
}
