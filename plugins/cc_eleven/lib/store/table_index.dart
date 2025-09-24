part of 'store.dart';

/// Index entry pointing to data in the table
class TableIndexEntry {
  static const int INDEX_ENTRY_SIZE = 21; // 1 + 8 + 4 + 8 bytes
  
  TableEntryType type;     // 1 byte - Entry type
  List<int> id;           // 8 bytes - Unique identifier (MAC for nodes)
  int offset;             // 4 bytes - Offset to data in table
  int lastUpdate;         // 8 bytes - Last update timestamp (milliseconds since epoch)
  bool _isDirty = false;  // Flag to track if entry needs to be written to device
  
  TableIndexEntry({
    required this.type,
    required this.id,
    required this.offset,
    int? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now().millisecondsSinceEpoch {
    _isDirty = true; // New entries are always dirty
  }
  
  /// Whether this entry has been modified and needs to be saved
  bool get isDirty => _isDirty;
  
  /// Mark entry as clean (saved to device)
  void markClean() => _isDirty = false;
  
  /// Mark entry as dirty (needs to be saved)
  void markDirty() => _isDirty = true;
  
  /// Serialize index entry to bytes
  List<int> serialize() {
    final data = <int>[];
    
    // enum(1) type
    data.add(type.value);
    
    // int(8) id
    if (id.length != 8) {
      throw ArgumentError('ID must be exactly 8 bytes, got ${id.length}');
    }
    data.addAll(id);
    
    // int(4) offset
    final offsetBytes = ByteData(4)..setUint32(0, offset, Endian.little);
    data.addAll(offsetBytes.buffer.asUint8List());
    
    // int(8) lastUpdate
    final lastUpdateBytes = ByteData(8)..setUint64(0, lastUpdate, Endian.little);
    data.addAll(lastUpdateBytes.buffer.asUint8List());
    
    return data;
  }
  
  /// Deserialize index entry from bytes (with backward compatibility)
  static TableIndexEntry deserialize(List<int> data) {
    // Support both old format (13 bytes) and new format (21 bytes)
    const int OLD_INDEX_ENTRY_SIZE = 13; // 1 + 8 + 4 bytes (without lastUpdate)
    
    if (data.length < OLD_INDEX_ENTRY_SIZE) {
      throw ArgumentError('Invalid index entry data length: ${data.length}');
    }

    int offset = 0;
    
    // enum(1) type
    final type = TableEntryType.fromValue(data[offset]);
    offset += 1;
    
    // int(8) id
    final id = data.sublist(offset, offset + 8);
    offset += 8;
    
    // int(4) offset
    final dataOffset = ByteData.sublistView(Uint8List.fromList(data.sublist(offset, offset + 4)))
        .getUint32(0, Endian.little);
    offset += 4;
    
    // int(8) lastUpdate (optional for backward compatibility)
    int lastUpdate;
    if (data.length >= INDEX_ENTRY_SIZE && offset + 8 <= data.length) {
      // New format with lastUpdate
      lastUpdate = ByteData.sublistView(Uint8List.fromList(data.sublist(offset, offset + 8)))
          .getUint64(0, Endian.little);
    } else {
      // Old format without lastUpdate - use current time as default
      lastUpdate = DateTime.now().millisecondsSinceEpoch;
    }
    
    final entry = TableIndexEntry(
      type: type,
      id: id,
      offset: dataOffset,
      lastUpdate: lastUpdate,
    );
    
    // Deserialized entries are clean (already on device)
    entry.markClean();
    
    return entry;
  }
  
  /// Convert ID bytes to string (for MAC addresses)
  String get idAsString {
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
  
  /// Convert lastUpdate timestamp to DateTime
  DateTime get lastUpdateDateTime {
    return DateTime.fromMillisecondsSinceEpoch(lastUpdate);
  }
  
  /// Update the lastUpdate timestamp to current time
  void updateTimestamp() {
    lastUpdate = DateTime.now().millisecondsSinceEpoch;
    markDirty(); // Mark as dirty when timestamp is updated
  }
  
  /// Check if this entry is newer than another entry
  bool isNewerThan(TableIndexEntry other) {
    return lastUpdate > other.lastUpdate;
  }
  
  @override
  String toString() {
    return 'TableIndexEntry(type: $type, id: $idAsString, offset: $offset, lastUpdate: ${lastUpdateDateTime.toIso8601String()})';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableIndexEntry &&
        other.type == type &&
        _listEquals(other.id, id) &&
        other.offset == offset &&
        other.lastUpdate == lastUpdate;
  }
  
  @override
  int get hashCode => Object.hash(type, Object.hashAll(id), offset, lastUpdate);
  
  /// Helper method to compare lists
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
