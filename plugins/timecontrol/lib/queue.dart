part of timecontrol_protocol;

class TimecontrolQueue implements MTQueueInterface<TimecontrolMessage> {
  final List<TimecontrolMessage> _entries = [
    // TimecontrolMessage([])
  ];

  @override
  void add(TimecontrolMessage entry) {
    entry.pack();
    _entries.add(entry);

    if(_entries.length == 1) {
      entry.slot.complete();
      if(entry.withResponse == false) {
        Future.delayed(const Duration(milliseconds: 200), () {
          unpack([]);
        });
      }
    }
  }

  @override
  StreamController<T> addListener<T extends TimecontrolMessage>({
    required int eventId,
    required TimecontrolMessage Function() getMessage,
    String? mac,
    int? datatype
  }) => throw UnimplementedError();

  @override
  void remove(TimecontrolMessage entry) {
    _entries.remove(entry);
  }

  @override
  bool unpack(List<int> telegram) {
    if(_entries.isEmpty) return false;
    _entries.first.packedResponse = telegram;
    _entries.first.unpack(telegram);
    remove(_entries.first);

    if(_entries.isNotEmpty) {
      _entries.first.slot.complete();

      if(_entries.first.withResponse == false) {
        Future.delayed(const Duration(milliseconds: 200), () {
          unpack([]);
        });
      }
    }

    return true;
  }

  @override
  void wipe({Exception? exception}) {
    _entries.clear();
  }
}
