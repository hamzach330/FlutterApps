import 'dart:async';

import 'package:mt_interface/discovery.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/transport.dart';

class MTInterface {
  MTInterface();

  static final MTInterface _instance = MTInterface();
  static MTInterface get instance => _instance;
  static final List<MTTransportInterface> transports  = [];

  static final StreamController<List<MTEndpoint>> scanResult = StreamController.broadcast();
  static final StreamController<MTInterface> notifyer        = StreamController.broadcast();
  static final List<MTEndpoint> scanResults                  = [];
  
  notifyListeners() {
    scanResult.add(scanResults);
  }

  Future<void> startScan (List<DiscoveryConfig> configurations) async {
    scanResults.clear();
    notifyListeners();
    for(final transport in transports) {
      await transport.stopScan();
      await transport.startScan(configurations);
    }
  }
  
  Future<void> stopScan () async {
    for(final transport in transports) {
      await transport.stopScan();
    }
  }

  void updateEndpoints ({required List<MTEndpoint> remove, required List<MTEndpoint> add}) {
    for(final removed in remove) scanResults.remove(removed);
    scanResults.addAll(add);
    if(remove.isNotEmpty || add.isNotEmpty) {
      print("updateEndpoints: ${remove.length} REMOVED ${add.length} NEW");
      notifyListeners();
    }
  }
}
