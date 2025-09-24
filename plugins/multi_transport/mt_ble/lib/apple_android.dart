
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/discovery.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:collection/collection.dart';
import 'package:mt_interface/multi_transport.dart';


class MTBLE extends MTInterface {
  static void registerWith() {
    print("MTBLE.registerWith");
    MTBLE();
  }
  
  MTBLE() {
    print("MTBLE()");
    MTInterface.transports.add(LETransport(mt: this));
  }
}

class LEEndpoint extends MTEndpoint<BluetoothDevice> {
  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;

  LEServiceEndpoint? secondaryEndpoint;

  DateTime lastSeen;

  final ScanResult? _scanResult;
  Stream<List<int>>? _valueStream;

  get rssi => _scanResult?.rssi;
  String? get remoteId  => _scanResult?.device.servicesList.first.remoteId.str;

  List<BluetoothService>? _services;
  StreamSubscription? _notificationSubscription;
  StreamSubscription<BluetoothConnectionState>? _stateSubscription;
  StreamSubscription<BluetoothBondState>? _bondSubscription;
  final BLEDiscoveryConfig configuration;

  LEEndpoint({
    ScanResult? scanResult,
    required super.info,
    required super.name,
    required this.lastSeen,
    required super.protocolName,
    required this.configuration
  }) : _scanResult = scanResult;

  /// Connect to this device
  @override
  Future<void> openWith (MTReaderWriter readerWriter) async {
    
    await super.openWith(readerWriter);
    final scanDuration = const Duration(seconds: 10);
    final maxConTimeout = const Duration(seconds: 5);
    await _notificationSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _bondSubscription?.cancel();
    final connectedCompleter = Completer<void>();

    try {
      dev.log("Connecting to ${info.advName}", name: "LEEndpoint");
      await info.connect(/*mtu: 512*/timeout: maxConTimeout).timeout(maxConTimeout);
      dev.log("Connected to ${info.advName}", name: "LEEndpoint");
      connected = true;
    } on TimeoutException catch (_) {
      throw TimeoutException("Connection timed out", scanDuration);
    } on FlutterBluePlusException catch (e) {
      if(e.code == 14) {
        dev.log(e.description ?? "", name: "LEEndpoint");
        throw MTPairingException(e.description);
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }

    _services = await info.discoverServices();

    _stateSubscription = info.connectionState.listen((state) {
      dev.log("Connection state changed: $state", name: "LEEndpoint");
      if(state == BluetoothConnectionState.disconnected) {
        close();
      } else {
        connectionState.add(MTConnectionState.connected);
        _subscribe(readerWriter.read).then((_) {
          connectedCompleter.complete();
        });
      }
    });

    return connectedCompleter.future;
  }

  @override
  Future<void> close () async {
    await super.close();
    await _notificationSubscription?.cancel();
    await _stateSubscription?.cancel();
    try {
      await info.disconnect(androidDelay: 2000);
      await secondaryEndpoint?.closeChild();
    } catch(e) {
      dev.log("Error closing endpoint: $e", name: "LEEndpoint");
    }
  }

  Future<void> _subscribe (MTEndpointReaderCallback cb) async {
    for (final service in (_services ?? <BluetoothService>[])) {
      final serviceConfig = configuration.services.firstWhereOrNull((s) => s.serviceId == service.uuid.str128);
      if(serviceConfig != null) {
        if(service.uuid.str128 == configuration.primaryServiceId) {
          for(final characteristic in service.characteristics) {
            if(characteristic.uuid.str128 == serviceConfig.rx) {
              rxCharacteristic = characteristic;
              dev.log("Subscribing to notifications for characteristic: ${characteristic.uuid.str128}", name: "LEEndpoint");
              await rxCharacteristic?.setNotifyValue(true);
              dev.log("Subscribed to characteristic ${characteristic.uuid.str128}", name: "LEEndpoint");
              _valueStream = rxCharacteristic?.lastValueStream;
              _notificationSubscription = _valueStream?.listen(cb);
            } else if(characteristic.uuid.str128 == serviceConfig.tx) {
              txCharacteristic = characteristic;
              dev.log("Writing initial 0x00 to characteristic: ${characteristic.uuid.str128}", name: "LEEndpoint");
              await write([0x00]);
            }
          }
        } else {
          secondaryEndpoint = LEServiceEndpoint(
            info: info,
            name: name,
            protocolName: protocolName,
            service: service,
            parent: this,
            txCharacteristicName: serviceConfig.tx,
            rxCharacteristicName: serviceConfig.rx,
          );
        }
      }
    }
  }

  // Future<void> _subscribe (MTEndpointReaderCallback cb) async {
  //   for (final service in (_services ?? <BluetoothService>[])) {

  //     final serviceConfig = configuration.services.firstWhereOrNull((s) => s.serviceId == service.uuid.str128);
  //     if(serviceConfig != null) {
  //       if(service.uuid.str128 == configuration.primaryServiceId) {
  //         for(final characteristic in service.characteristics) {
  //           if(characteristic.uuid.str128 == serviceConfig.rx) {
  //             rxCharacteristic = characteristic;
  //             await characteristic.setNotifyValue(true);
  //             _valueStream = characteristic.lastValueStream;
  //             _notificationSubscription = _valueStream?.listen(cb);
  //           } else if(characteristic.uuid.str128 == serviceConfig.tx) {
  //             txCharacteristic = characteristic;
  //             write([0x00]);
  //           }
  //         }
  //       } else {
  //         secondaryEndpoint = LEServiceEndpoint(
  //           info: info,
  //           name: name,
  //           protocolName: protocolName,
  //           service: service,
  //           parent: this,
  //           txCharacteristicName: serviceConfig.tx,
  //           rxCharacteristicName: serviceConfig.rx,
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Future<void> write (List<int> data) async {
    try {
      const int chunkSize = 64;
      for (int i = 0; i < data.length; i += chunkSize) {
        final int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final List<int> chunk = data.sublist(i, end);
        await txCharacteristic?.write(chunk, withoutResponse: !configuration.services.first.txWithResponse);
      }
    } catch(e) {
      dev.log("Error writing data: $e", name: "LEEndpoint");
      close();
    }
  }
}

class LEServiceEndpoint extends MTEndpoint<BluetoothDevice> {
  final MTEndpoint parent;
  final BluetoothService service;
  final String rxCharacteristicName;
  final String txCharacteristicName;

  StreamSubscription? _notificationSubscription;

  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;

  LEServiceEndpoint({
    required super.info,
    required super.name,
    required super.protocolName,
    required this.parent,
    required this.service,
    required this.rxCharacteristicName,
    required this.txCharacteristicName,
  });

  @override
  Future<void> openWith (MTReaderWriter readerWriter) async {
    await super.openWith(readerWriter);
    for(final characteristic in service.characteristics) {
      if(characteristic.uuid.str128 == rxCharacteristicName) {
        rxCharacteristic = characteristic;
      } else if(characteristic.uuid.str128 == txCharacteristicName) {
        txCharacteristic = characteristic;
        dev.log("Writing 0x02, 0x03 to characteristic: ${characteristic.uuid.str128}", name: "LEServiceEndpoint");
        await write([0x02, 0x03]);
        dev.log("Subscribing to notifications for characteristic: ${characteristic.uuid.str128}", name: "LEServiceEndpoint");
        await rxCharacteristic?.setNotifyValue(true);
        dev.log("Subscribed to characteristic ${characteristic.uuid.str128}", name: "LEServiceEndpoint");
        _valueStream = rxCharacteristic?.lastValueStream;
        _notificationSubscription = _valueStream?.listen(readerWriter.read);
      }
    }
    connected = true;
  }

  Stream<List<int>>? _valueStream;

  @override
  Future<void> write (List<int> data) async {
    try {
      const int chunkSize = 64;
      for (int i = 0; i < data.length; i += chunkSize) {
        final int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final List<int> chunk = data.sublist(i, end);
        await txCharacteristic?.write(chunk, withoutResponse: false);
      }
    } catch(e) {
      dev.log("Error writing data: $e", name: "LEServiceEndpoint");
      close();
    }
  }

  Future<void> closeChild () async {
    await _notificationSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await super.close();
    parent.close();
  }
}

class LETransport extends MTTransportInterface {
  
  LETransport({required super.mt});
  
  bool _scanning = false;
  BLEDiscoveryConfig? configuration;
  StreamSubscription<List<ScanResult>>? _scanListener;
  Timer? _scanTimer;
  List<BLEDiscoveryConfig> _configurations = [];

  bool bleOn = false;
  StreamSubscription<BluetoothAdapterState>? _adapterStateListener;

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
    _configurations = configuration.whereType<BLEDiscoveryConfig>().toList();

    if(_scanning) return;
    _scanning = true;

    _scanListener ??= FlutterBluePlus.scanResults.listen(onScanResult);

    _adapterStateListener = FlutterBluePlus.adapterState.listen((state) {
      if(state == BluetoothAdapterState.on) {
        print("Adapter is on");
        bleOn = true;
        _scan(configuration);
      } else if(state == BluetoothAdapterState.off) {
        print("Adapter is off");
        bleOn = false;
      }
    });

    _scan(configuration);
  }

  Future<void> _scan(List<DiscoveryConfig> configuration) async {
    if(bleOn) {
      _adapterStateListener?.cancel();
      FlutterBluePlus.startScan();
      _scanTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        await stopScan();
        await startScan(configuration);
      });
    }
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    if(_scanning == true) {
      await FlutterBluePlus.stopScan();
    }
    _scanning = false;
  }

  void onScanResult(List<ScanResult> results) {
    if(endpoint != null) return; // pause scan during active connection

    final mtPreviousScanResult = MTInterface.scanResults.whereType<LEEndpoint>().toList();
    // final availablePorts = SerialPort.availablePorts;
    final List<LEEndpoint> scanResults = [];
    for(final result in results) {

      for(final config in _configurations) {
        final List<String> protocols = [];
        if(
          (result.advertisementData.manufacturerData[config.vendorId] != null && result.advertisementData.manufacturerData[config.vendorId]?.equals(config.productId) == true) ||
          (result.advertisementData.serviceUuids.map((v) => v.str128).contains(config.primaryServiceId))
        ) {
          protocols.add(config.protocolName);
          scanResults.add(LEEndpoint(
            name: result.device.advName.isNotEmpty
              ? result.device.advName
              : result.device.platformName,
            info: result.device,
            lastSeen: DateTime.now(),
            protocolName: config.protocolName,
            configuration: config,
          )..id = result.device.remoteId.str);
        }
      }
    }

    final List<LEEndpoint> removedPorts = [];
    final List<LEEndpoint> newPorts = [];

    /// Find Ports that are no longer available
    for(final mtPort in mtPreviousScanResult) {
      if(scanResults.where((port) => port == mtPort.name).isEmpty) {
        if(DateTime.now().difference(mtPort.lastSeen).inSeconds > mtPort.configuration.bleAdvertisementInterval / 1000) {
          removedPorts.add(mtPort);
        }
      }
    }

    /// Add newly found ports
    for (final scanResult in scanResults) {
      final knownPort = mtPreviousScanResult.firstWhereOrNull((ep) => ep.info.remoteId == scanResult.info.remoteId);
      bool isKnownPort = knownPort != null;
      if(!isKnownPort) {
        newPorts.add(scanResult);
      } else if(removedPorts.contains(knownPort) == false) {
        knownPort.lastSeen = DateTime.now();
      }
    }

    if(removedPorts.isNotEmpty || newPorts.isNotEmpty) {
      mt.updateEndpoints(
        remove: removedPorts,
        add: newPorts
      );
    }
  }
}
