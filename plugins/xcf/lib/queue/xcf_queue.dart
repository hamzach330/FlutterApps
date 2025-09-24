part of xcf_protocol;
class _XCFQueue implements MTQueueInterface<XCFMessage> {
  final List<XCFMessage> _entries = [];

  @override
  Future<void> add(XCFMessage entry) async {
    entry.pack();
    _entries.add(entry);
    // Wait for the previous message to be sent and answered
    // This is pretty much all there is to queueing messages
    if(_entries.length > 1) {
      await _entries[_entries.length - 2].slot.future;
    }
  }

  @override
  StreamController<T> addListener<T extends XCFMessage>({
    required int eventId,
    required XCFMessage Function() getMessage,
    String? mac,
    int? datatype
  }) => throw UnimplementedError();

  @override
  void remove(XCFMessage entry) {
    _entries.remove(entry);
  }

  @override
  bool unpack(List<int> telegram) {
    if(_entries.isEmpty) return false;

    final entry = _entries.first;
    remove(entry);
    entry.unpack(telegram);
    return true;
  }

  @override
  void wipe({Exception? exception}) {
    _entries.clear();
  }
}
