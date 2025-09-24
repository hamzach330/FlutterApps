part of 'store.dart';

/// Binary data entry for TYPE=4 (string)
class StringBinaryData {
  // Field sizes (for transmission format)
  static const int TYPE_SIZE = 1;     // enum(1) type
  static const int ID_SIZE = 8;       // int(8) id  
  static const int LEN_SIZE = 1;      // int(1) len
  static const int MAX_STRING_LENGTH = 118; // Limit string content to 118 bytes
  
  // Note: No fixed ENTRY_SIZE - strings use variable length transmission

  TableEntryType type;        // 1 byte - Always string (4)
  List<int> id;              // 8 bytes - Unique string ID
  int length;                // 1 byte - Length of actual string content
  String content;            // Up to 118 bytes - String content (limited)

  StringBinaryData({
    required this.type,
    required this.id,
    required this.length,
    required this.content,
  });

  /// Create from string data (with automatic length calculation and truncation)
  factory StringBinaryData.fromString({
    required List<int> id,
    required String content,
  }) {
    // Truncate content to maximum length if necessary
    final truncatedContent = content.length > MAX_STRING_LENGTH 
        ? content.substring(0, MAX_STRING_LENGTH)
        : content;
    
    return StringBinaryData(
      type: TableEntryType.string,
      id: id,
      length: utf8.encode(truncatedContent).length,
      content: truncatedContent,
    );
  }

  /// Create from binary data (variable length format)
  factory StringBinaryData.deserialize(List<int> data) {
    if (data.length < TYPE_SIZE + ID_SIZE + LEN_SIZE) {
      throw ArgumentError('String entry must be at least ${TYPE_SIZE + ID_SIZE + LEN_SIZE} bytes, got ${data.length}');
    }

    int offset = 0;

    // Type (1 byte)
    final type = TableEntryType.fromValue(data[offset]);
    offset += TYPE_SIZE;

    // ID (8 bytes)
    final id = data.sublist(offset, offset + ID_SIZE);
    offset += ID_SIZE;

    // Length (1 byte)
    final length = data[offset];
    offset += LEN_SIZE;

    // Verify we have enough data for the string content
    if (data.length < offset + length) {
      throw ArgumentError('String entry incomplete: expected ${offset + length} bytes, got ${data.length}');
    }

    // String content (variable length, using length field)
    final stringBytes = data.sublist(offset, offset + length);
    final content = utf8.decode(stringBytes);

    return StringBinaryData(
      type: type,
      id: id,
      length: length,
      content: content,
    );
  }

  /// Serialize to binary data for transmission (variable length, no padding)
  List<int> serialize() {
    final result = <int>[];
    
    // Type (1 byte)
    result.add(type.value);
    
    // ID (8 bytes)
    result.addAll(id.length >= ID_SIZE ? id.sublist(0, ID_SIZE) : [...id, ...List<int>.filled(ID_SIZE - id.length, 0)]);
    
    // Get content bytes and limit to maximum
    final contentBytes = utf8.encode(content);
    final actualLength = contentBytes.length > MAX_STRING_LENGTH ? MAX_STRING_LENGTH : contentBytes.length;
    
    // Length (1 byte)
    result.add(actualLength);
    
    // String content (only actual string data, no padding)
    result.addAll(contentBytes.sublist(0, actualLength));
    
    return result;
  }

  /// Convert to readable string representation
  @override
  String toString() {
    return 'StringBinaryData(type: $type, id: ${_formatId(id)}, length: $length, content: "$content")';
  }

  /// Convert to hex string for debugging
  String toHex() {
    final data = serialize();
    return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  String _formatId(List<int> id) {
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
  }
}

/// Helper functions for string ID management
class StringIdHelper {
  /// Generate string ID from hash of content
  static List<int> generateIdFromContent(String content) {
    final hash = content.hashCode;
    final buffer = Uint8List(8).buffer.asByteData();
    buffer.setInt32(0, hash, Endian.little);
    buffer.setInt32(4, DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF, Endian.little);
    return buffer.buffer.asUint8List();
  }
  
  /// Generate sequential string ID
  static List<int> generateSequentialId(int sequence) {
    final buffer = Uint8List(8).buffer.asByteData();
    buffer.setInt32(0, sequence, Endian.little);
    buffer.setInt32(4, 0x53545220, Endian.little); // "STR " marker
    return buffer.buffer.asUint8List();
  }
  
  /// Convert string ID to human readable format
  static String formatStringId(List<int> id) {
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
  }
}
