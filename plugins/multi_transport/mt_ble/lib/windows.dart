
import 'dart:async';
import 'dart:typed_data';

import 'package:win_ble/win_ble.dart';
import 'package:mt_interface/discovery.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:collection/collection.dart';
import 'package:mt_interface/multi_transport.dart';
import 'package:win_ble/win_file.dart';


class MTWinBLE extends MTInterface {
  static void registerWith() {
    print("MTWinBLE.registerWith");
    MTWinBLE();
  }
  
  MTWinBLE() {
    print("MTWinBLE()");
    MTInterface.transports.add(LEWinTransport(mt: this));
  }
}

class LEWinEndpoint extends MTEndpoint<BleDevice> {
  BleCharacteristic? txCharacteristic;
  BleCharacteristic? rxCharacteristic;

  DateTime lastSeen;

  final BleDevice? _scanResult;
  Stream<dynamic>? _valueStream;

  get rssi => _scanResult?.rssi;
  String? get remoteId  => _scanResult?.serviceUuids.first;

  StreamSubscription<BleState>? _stateSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<dynamic>? _valueSubscription;
  final BLEDiscoveryConfig configuration;
  LEWinServiceEndpoint? secondaryEndpoint;
  String? id;

  LEWinEndpoint({
    BleDevice? scanResult,
    required super.info,
    required super.name,
    required this.lastSeen,
    required super.protocolName,
    required this.configuration
  }) : _scanResult = scanResult;

  /// Connect to this device
  @override
  Future<void> openWith (MTReaderWriter readerWriter) async {
    final completer = Completer();
    await MTInterface.instance.stopScan();

    await super.openWith(readerWriter);
    final scanDuration = const Duration(seconds: 5);
    await _cancelSubscriptions();
    
    try {
      _connectionSubscription = WinBle.connectionStreamOf(info.address).listen((event) {
        if(event && completer.isCompleted == false) {
          completer.complete();
        } else if(event == false && connected == true) {
          close();
        }
      });
      await WinBle.connect(info.address);

      if(configuration.wantsPairing) {
        final canPair = await WinBle.canPair(info.address);
        final isPaired = await WinBle.isPaired(info.address);
        if(canPair && !isPaired) {
          await WinBle.pair(
            address: info.address,
            kind: configuration.pairingMethod ?? "",
            code: configuration.pairingPin ?? ""
          );
        }
      }
    } on TimeoutException catch (_) {
      close();
      throw TimeoutException("Connection timed out", scanDuration);
    } catch (e) {
      close();
      rethrow;
    }

    _stateSubscription = WinBle.bleState.listen((BleState state) {
      print("BLE STATE: $state");
      // Get BleState (On, Off, Unknown, Disabled, Unsupported)
    });

    connected = true;

    await _subscribe(readerWriter.read, completer);
    return completer.future;
  }

  Future<void> _cancelSubscriptions () async {
    await _stateSubscription?.cancel();
    await _valueSubscription?.cancel();
    await _connectionSubscription?.cancel();
  }

  /// Close bluetooth connection to this device
  /// Clear stream subscription
  @override
  Future<void> close () async {
    if(!connected) return;
    await super.close();
    await _cancelSubscriptions();
    try {
      await WinBle.unSubscribeFromCharacteristic(
        address: info.address,
        serviceId: configuration.primaryServiceId,
        characteristicId: rxCharacteristic?.uuid ?? ""
      );
      await WinBle.disconnect(info.address);
    } catch (e) {
      print("UNABLE TO DISCONNECT. ALREADY DISCONNECTED?");
    }
  }

  Future<void> _subscribe (MTEndpointReaderCallback cb, Completer completer) async {
    for (final serviceConfig in configuration.services) {
      if(serviceConfig.serviceId == configuration.primaryServiceId) {
        final characteristics = await WinBle.discoverCharacteristics(
          address: info.address,
          serviceId: configuration.primaryServiceId
        );
        for(final characteristic in characteristics) {
          if(characteristic.uuid == configuration.services.first.rx) {
            rxCharacteristic = characteristic;

            await WinBle.subscribeToCharacteristic(
              address: info.address,
              serviceId: configuration.primaryServiceId,
              characteristicId: rxCharacteristic!.uuid,
            );

            _valueStream = WinBle.characteristicValueStreamOf(
              address: info.address,
              serviceId: configuration.primaryServiceId,
              characteristicId: rxCharacteristic!.uuid
            );

            _valueSubscription = _valueStream?.listen((v) {
              cb(v.cast<int>());
            });
          } else if(characteristic.uuid == configuration.services.first.tx) {
            txCharacteristic = characteristic;
          }
        }
      } else {
        secondaryEndpoint = LEWinServiceEndpoint(
          info: info,
          name: name,
          protocolName: protocolName,
          service: serviceConfig.serviceId,
          parent: this,
          txCharacteristic: serviceConfig.tx,
          rxCharacteristic: serviceConfig.rx,
        );
      }
    }
  }

  @override
  Future<void> write (List<int> data) async {
    try {
      await WinBle.write(
        address: info.address,
        service: configuration.primaryServiceId,
        characteristic: txCharacteristic?.uuid ?? "",
        data: Uint8List.fromList(data),
        writeWithResponse: configuration.services.first.txWithResponse
      );
    } catch(e) {
      close();
    }
  }
}

class LEWinServiceEndpoint extends MTEndpoint<BleDevice> {
  final MTEndpoint parent;
  final String service;
  final String rxCharacteristic;
  final String txCharacteristic;
  Stream<dynamic>? _valueStream;

  StreamSubscription? _notificationSubscription;

  LEWinServiceEndpoint({
    required super.info,
    required super.name,
    required super.protocolName,
    required this.parent,
    required this.service,
    required this.rxCharacteristic,
    required this.txCharacteristic,
  });

  @override
  Future<void> openWith (MTReaderWriter readerWriter) async {
    await super.openWith(readerWriter);

    await WinBle.subscribeToCharacteristic(
      address: info.address,
      serviceId: service,
      characteristicId: rxCharacteristic
    );

    _valueStream = WinBle.characteristicValueStreamOf(
      address: info.address,
      serviceId: service,
      characteristicId: rxCharacteristic
    );

    _notificationSubscription = _valueStream?.listen((v) {
      readerWriter.read(v.cast<int>());
    });

    connected = true;
  }

  @override
  Future<void> write (List<int> data) async {
    try {
      await WinBle.write(
        address: info.address,
        service: service,
        characteristic: txCharacteristic,
        data: Uint8List.fromList(data),
        writeWithResponse: true
      );
    } catch(e) {
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

class LEWinTransport extends MTTransportInterface {
  
  LEWinTransport({required super.mt});
  
  bool _scanning = false;
  BLEDiscoveryConfig? configuration;
  StreamSubscription<BleDevice>? _scanListener;
  Timer? _scanTimer;
  List<BLEDiscoveryConfig> _configurations = [];
  bool _initialized = false;

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    if(_initialized == false) {
      await WinBle.initialize(serverPath: await WinServer.path());
      _initialized = true;
    }
    _configurations = configuration.whereType<BLEDiscoveryConfig>().toList();

    if(_scanning) return;
    _scanning = true;

    _scanListener ??= WinBle.scanStream.listen(onScanResult);
    WinBle.startScanning();
    _scanTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await stopScan();
      await startScan(configuration);
    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    if(_scanning == true) {
      WinBle.stopScanning();
    }
    _scanning = false;
  }

  void onScanResult(BleDevice result) {
    if(endpoint != null) return; // pause scan during active connection

    final mtPreviousScanResult = MTInterface.scanResults.whereType<LEWinEndpoint>().toList();
    // final availablePorts = SerialPort.availablePorts;
    final List<LEWinEndpoint> scanResults = [];


    List<String> serviceUuids = [];

    for(final serviceUuid in result.serviceUuids) {
      serviceUuids.add(serviceUuid.substring(1, serviceUuid.length - 1));
    }

    for(final config in _configurations) {
      // print("${config.blePrimaryService == serviceUuids.first} ${config.blePrimaryService} == ${serviceUuids.first}");
      int vendorId = 0;
      List<int> prodId = [];
      if(result.manufacturerData.length > 5) {
        vendorId = (result.manufacturerData[1] << 8) | result.manufacturerData[0];
        prodId = result.manufacturerData.sublist(2, result.manufacturerData.length);
      }

      final List<String> protocols = [];
      if(
        (vendorId == config.vendorId && prodId.equals(config.productId) == true) ||
        serviceUuids.contains(config.primaryServiceId)
      ) {
        protocols.add(config.protocolName);
        scanResults.add(LEWinEndpoint(
          name: result.name,
          info: result,
          lastSeen: DateTime.now(),
          protocolName: config.protocolName,
          configuration: config,
        )..id = result.address.replaceAll(":", "_"));
      }
    }

    final List<LEWinEndpoint> removedPorts = [];
    final List<LEWinEndpoint> newPorts = [];

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
      final knownPort = mtPreviousScanResult.firstWhereOrNull((ep) => ep.info.address == scanResult.info.address);
      bool isKnownPort = knownPort != null;
      if(!isKnownPort) {
        newPorts.add(scanResult);
      } else if(removedPorts.contains(knownPort) == false) {
        knownPort.lastSeen = DateTime.now();
      }
    }

    mt.updateEndpoints(
      remove: removedPorts,
      add: newPorts
    );
  }
}
