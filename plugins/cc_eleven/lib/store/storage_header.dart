part of 'store.dart';

/// Storage header containing metadata about the binary storage
class StorageHeader {
  static const int HEADER_SIZE = 36; // Total header size in bytes (20 + 16 for UUID)
  
  List<int> uuid;              // 16 bytes - Unique database identifier (UUID v4)
  bool lock;                   // 1 byte - Lock flag
  int lastUpdate;              // 8 bytes - Timestamp of last update
  int lengthOfIndex;           // 4 bytes - Number of index entries
  int lengthOfTable;           // 4 bytes - Total size of table data
  int versionMajor;            // 1 byte - SemVer major version
  int versionMinor;            // 1 byte - SemVer minor version  
  int versionPatch;            // 1 byte - SemVer patch version
  
  StorageHeader({
    required this.uuid,
    required this.lock,
    required this.lastUpdate,
    required this.lengthOfIndex,
    required this.lengthOfTable,
    required this.versionMajor,
    required this.versionMinor,
    required this.versionPatch,
  });
  
  /// Create empty header with default version 1.0.0 and new UUID
  factory StorageHeader.empty(String cacheId) {
    return StorageHeader(
      uuid: utf8.encode(cacheId).take(16).toList(),
      lock: false,
      lastUpdate: 0,
      lengthOfIndex: 0,
      lengthOfTable: 0,
      versionMajor: 1,
      versionMinor: 0,
      versionPatch: 0,
    );
  }
  
  /// Serialize header to bytes
  List<int> serialize() {
    final data = <int>[];
    
    // List<int>(16) uuid
    if (uuid.length != 16) {
      throw ArgumentError('UUID must be exactly 16 bytes, got ${uuid.length}');
    }
    data.addAll(uuid);
    
    // bool(1) lock
    data.add(lock ? 1 : 0);
    
    // int(8) lastUpdate
    final lastUpdateBytes = ByteData(8)..setUint64(0, lastUpdate, Endian.little);
    data.addAll(lastUpdateBytes.buffer.asUint8List());
    
    // int32(4) lengthOfIndex
    final lengthOfIndexBytes = ByteData(4)..setUint32(0, lengthOfIndex, Endian.little);
    data.addAll(lengthOfIndexBytes.buffer.asUint8List());
    
    // int32(4) lengthOfTable
    final lengthOfTableBytes = ByteData(4)..setUint32(0, lengthOfTable, Endian.little);
    data.addAll(lengthOfTableBytes.buffer.asUint8List());
    
    // int(1) versionMajor
    data.add(versionMajor);
    
    // int(1) versionMinor
    data.add(versionMinor);
    
    // int(1) versionPatch
    data.add(versionPatch);
    
    return data;
  }
  
  /// Deserialize header from bytes
  static StorageHeader deserialize(List<int> data) {
    if (data.length < HEADER_SIZE) {
      throw ArgumentError('Invalid header data length: ${data.length}');
    }
    
    int offset = 0;
    
    // List<int>(16) uuid
    final uuid = data.sublist(offset, offset + 16);
    offset += 16;
    
    // bool(1) lock
    final lock = data[offset] != 0;
    offset += 1;
    
    // int(8) lastUpdate
    final lastUpdate = ByteData.sublistView(Uint8List.fromList(data.sublist(offset, offset + 8)))
        .getUint64(0, Endian.little);
    offset += 8;
    
    // int32(4) lengthOfIndex
    final lengthOfIndex = ByteData.sublistView(Uint8List.fromList(data.sublist(offset, offset + 4)))
        .getUint32(0, Endian.little);
    offset += 4;
    
    // int32(4) lengthOfTable
    final lengthOfTable = ByteData.sublistView(Uint8List.fromList(data.sublist(offset, offset + 4)))
        .getUint32(0, Endian.little);
    offset += 4;
    
    // int(1) versionMajor
    final versionMajor = data[offset];
    offset += 1;
    
    // int(1) versionMinor  
    final versionMinor = data[offset];
    offset += 1;
    
    // int(1) versionPatch
    final versionPatch = data[offset];
    
    return StorageHeader(
      uuid: uuid,
      lock: lock,
      lastUpdate: lastUpdate,
      lengthOfIndex: lengthOfIndex,
      lengthOfTable: lengthOfTable,
      versionMajor: versionMajor,
      versionMinor: versionMinor,
      versionPatch: versionPatch,
    );
  }
  
  /// Update timestamp to current time
  void updateTimestamp() {
    lastUpdate = DateTime.now().millisecondsSinceEpoch;
  }
  
  /// Get UUID as formatted string (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
  String get uuidString {
    final hex = uuid.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
  
  /// Get UUID as short hex string (first 8 characters)
  String get uuidShort {
    return uuid.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
  
  @override
  String toString() {
    return 'StorageHeader(uuid: $uuidString, lock: $lock, lastUpdate: $lastUpdate, lengthOfIndex: $lengthOfIndex, lengthOfTable: $lengthOfTable, version: $versionMajor.$versionMinor.$versionPatch)';
  }
  
  /// Get version as string (SemVer format)
  String get versionString => '$versionMajor.$versionMinor.$versionPatch';
}
