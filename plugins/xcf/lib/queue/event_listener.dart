part of xcf_protocol;

class _EventListener<MESSAGE_T extends XCFMessage> {
  final int eventId;
  final String? mac;
  final int? datatype;
  final XCFMessage Function() getMessage;
  final StreamController<MESSAGE_T> streamController = StreamController<MESSAGE_T>.broadcast();

  _EventListener({
    required this.eventId,
    required this.getMessage,
    this.mac,
    this.datatype
  });
}