import 'dart:async';
import 'dart:developer';

import 'package:mt_interface/const.dart';
import 'package:mt_interface/discovery.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';

abstract class MTTransportInterface {
  MTInterface mt;
  MTEndpoint? endpoint;

  final StreamController<MTConnectionState> connectionState = StreamController.broadcast();
  
  Function(MTConnectionState state)? onConnectionStateChange;

  MTTransportInterface({required this.mt});

  Future<void> startScan(List<DiscoveryConfig> configuration);
  Future<void> stopScan();

  void onReaderError(dynamic error) {
    log("${MTLogTags.error} $error");
  }
  void onWriteError (dynamic error) {
    log("${MTLogTags.error} $error");
  }
}
