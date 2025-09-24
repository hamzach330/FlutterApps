abstract class MTLogTags {
  static const String warning   = "[!]";
  static const String error     = "[X]";
  static const String info      = "[i]";
  static const String unhandled = "[?]";
  static const String event     = "[#]";
  static const String response  = "[<]";
  static const String outgoing  = "[>]";
  static const String invalid   = "[-]";
  static const String dropped   = "[-]";
}

enum MTConnectionState {
  connecting, connected, disconnected, unknown
}

class MTEndpointException implements Exception {
  String? message;
  MTEndpointException(this.message);
}

class MTWriteException implements Exception {
  String? message;
  MTWriteException(this.message);
}

class MTReadException implements Exception {
  String? message;
  MTReadException(this.message);
}

class MTConvertException implements Exception {
  String? message;
  MTConvertException(this.message);
}

class MTPairingException implements Exception {
  String? message;
  MTPairingException(this.message);
}

enum MTPlatform {
  win, mac, linux, android, ios, web
}