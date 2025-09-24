import 'dart:async';
import 'package:mt_interface/message.dart';

/// Interface for a queue to manage [MTMessageInterface] listeners and completers
abstract class MTQueueInterface<MESSAGE_T> {

  /// The add method adds a new _MTMessage object to the end of the queue.
  void add (MESSAGE_T entry);
  void remove (MESSAGE_T entry);

  StreamController<T> addListener<T extends MESSAGE_T>({
    required int eventId,
    required MESSAGE_T Function() getMessage,
    String? mac,
    int? datatype
  });

  /// Implementations of this method should close all opened listeners with an error message.
  void wipe ({Exception? exception});

  bool unpack (List<int> telegram);
}
