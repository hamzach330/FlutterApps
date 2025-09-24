import 'dart:async';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/message.dart';
import 'package:mt_interface/protocol.dart';
import 'package:meta/meta.dart';

typedef MTEndpointReaderCallback = void Function(List<int>); 

abstract class MTEndpoint<IMPL_T> {
  final List<Completer>                                 _outgoing = [];
  final List<MTMessageInfoInterface>                         _log = [];
  final StreamController<MTEndpoint<IMPL_T>>             notifyer = StreamController.broadcast();
  final StreamController<List<MTMessageInfoInterface>> messageLog = StreamController.broadcast();
  final StreamController<MTConnectionState>       connectionState = StreamController.broadcast();
  final List<StreamSubscription>                    subscriptions = [];
  String                                                protocolName;
  String?                                                     name;
  final IMPL_T                                               info;
  bool                                                  connected = false;
  StreamSubscription<List<int>>?               readerSubscription;
  MTReaderWriter?                                        protocol;
  List<MTMessageInfoInterface> get logData => _log;
  String? id;

  Function ()? onClose;

  MTEndpoint({
    required this.name,
    required this.info,
    required this.protocolName,
  });


  @mustCallSuper
  Future<void> openWith (MTReaderWriter protocol) async {
    this.protocol = protocol;
    protocol.endpoint = this;
  }

  Future<void> write (List<int> data);
  

  @mustCallSuper
  void notifyListeners() => notifyer.add(this);

  @mustCallSuper
  void use({required MTReaderWriter protocol}) {
    this.protocol = protocol;
    protocol.endpoint = this;
  }

  @mustCallSuper
  logMessage({required String message, List<MTMessageChunk>? chunks, required String tag, String? name}) {
    _log.add(MTMessageInfoInterface(
      telegram: message,
      time: DateTime.now(),
      chunks: chunks,
      tag: tag,
      name: name
    ));
    messageLog.add(_log);
  }

  @mustCallSuper
  Future<void> close () async {
    onClose?.call();
    connected = false;
    connectionState.add(MTConnectionState.disconnected);
    readerSubscription?.cancel();
  }

  @mustCallSuper
  void onReaderError(dynamic onError) async {
    _log.add(MTMessageInfoInterface(
      telegram: onError,
      time: DateTime.now(),
      tag: MTLogTags.error,
    ));
    await close();
  }

  @mustCallSuper
  void onWriteError(String message) async {
    // await close();
  }

  @mustCallSuper
  Future<void> settle([
    Duration duration = const Duration(milliseconds: 300)
  ]) async {
    final completer = Completer();
    _outgoing.add(completer);
    if(_outgoing.length > 1 && !_outgoing[_outgoing.length - 2].isCompleted) {
      await _outgoing[_outgoing.length - 2].future;
    }

    Future.delayed(duration).then((_) {
      completer.complete();
      _outgoing.remove(completer);
    });
  }

  @mustCallSuper
  clearLog() {
    _log.clear();
    notifyListeners();
  }


}
