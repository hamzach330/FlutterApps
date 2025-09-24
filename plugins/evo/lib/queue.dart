part of evo_protocol;

class EvoQueue implements MTQueueInterface<EvoMessage> {
  final List<EvoMessage> _entries = [];

  @override
  void add(EvoMessage entry) {
    entry.pack();
    _entries.add(entry);

    if(_entries.length == 1) {
      entry.slot.complete(); /// Instantly exec next slot if there's no previous one
    }
  }

  @override
  StreamController<T> addListener<T extends EvoMessage>({
    required int eventId,
    required EvoMessage Function() getMessage,
    String? mac,
    int? datatype
  }) => throw UnimplementedError();

  @override
  void remove(EvoMessage entry) {
    _entries.remove(entry);
  }

  @override
  bool unpack(List<int> telegram) {
    if(telegram.isEmpty || _entries.isEmpty) return false;
    final request = _entries.removeAt(0);
    request.unpack(telegram);
    dev.log("<<< ${request.packedResponse?.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))}");

    request.completer.complete(request);
    
    if(_entries.isNotEmpty) {
      _entries.first.slot.complete();
    }

    return true;
  }

  @override
  void wipe({Exception? exception}) {
    for(final entry in _entries) {
      if(!entry.completer.isCompleted) {
        entry.completer.completeError(exception ?? Exception("Queue wiped"));
      }
      
      if(!entry.slot.isCompleted) {
        entry.slot.completeError(exception ?? Exception("Queue wiped"));
      }
    }
    _entries.clear();
  }
}
