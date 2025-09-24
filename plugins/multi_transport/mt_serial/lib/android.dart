import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:mt_interface/discovery.dart';

class MTAndroid extends MTInterface {
  static void registerWith() {
    MTAndroid();
  }

  MTAndroid() {
    MTInterface.transports.add(USBAndroidTransport(mt: this));
  }
}

class USBAndroidEndpoint extends MTEndpoint<DeviceInfo> {
  final _flutterSerialCommunicationPlugin = FlutterSerialCommunication();

  USBAndroidEndpoint({
    required super.name,
    required super.info,
    required super.protocolName
  });

  @override
  Future<void> write (List<int> data) async {
    _flutterSerialCommunicationPlugin.write(Uint8List.fromList(data));
  }

  @override
  Future<void> openWith(MTReaderWriter protocol) async {
    await super.openWith(protocol);
    if((await _flutterSerialCommunicationPlugin.connect(info, 115200)) == false) {
      throw("Unable to connect to USB Device");
    }

    await _flutterSerialCommunicationPlugin.setDTR(true);
    await _flutterSerialCommunicationPlugin.setRTS(true);
    
    connectionState.add(MTConnectionState.connected);
    connected = true;

    final statusChannel = _flutterSerialCommunicationPlugin.getDeviceConnectionListener();
    statusChannel.receiveBroadcastStream().listen((e) async {
      if(e == false && connected){
        await close();
      }
    });
    setReader();
  }

  Future<void> setReader () async {
    readerSubscription?.cancel();
    final EventChannel readChannel = _flutterSerialCommunicationPlugin.getSerialMessageListener();
    readChannel.receiveBroadcastStream().cast<List<int>>();
    readerSubscription = readChannel.receiveBroadcastStream().cast<List<int>>().listen((v) => protocol?.read(v));
    readerSubscription?.onError((e) async => await close());
  }

  @override
  Future<void> close() async {
    if(!connected) return;
    await super.close();
    _flutterSerialCommunicationPlugin.disconnect();
  }
}

class USBAndroidTransport extends MTTransportInterface {
  USBAndroidTransport({required super.mt});

  final _flutterSerialCommunicationPlugin = FlutterSerialCommunication();
  Timer? _scanTimer;

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    final configurations = configuration.whereType<USBAndroidDiscoveryConfig>();
    print("CONFIGURATIONS: $configurations");

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if(endpoint != null) return;
      
      final mtPreviousScanResult = MTInterface.scanResults.whereType<USBAndroidEndpoint>().toList();
      final availablePorts = await _flutterSerialCommunicationPlugin.getAvailableDevices();
      final List<USBAndroidEndpoint> removedPorts = [];
      final List<USBAndroidEndpoint> newPorts = [];

      for(final mtPort in mtPreviousScanResult) {
        if(availablePorts.where((port) => port.deviceName == mtPort.name).isEmpty) {
          removedPorts.add(mtPort);
        }
      }

      String? protocol;
      for (final port in availablePorts) {
        for(final config in configurations) {
          if(config.usbProductId == port.productId && config.usbVendorId == port.vendorId) {
            protocol = config.protocolName;
          }
        }

        if(protocol != null) {
          bool isKnownPort = mtPreviousScanResult.where((ep) => ep.name == port.deviceName).isNotEmpty;
          if(!isKnownPort) {
            newPorts.add(USBAndroidEndpoint(
              name: port.deviceName,
              info: port,
              protocolName: protocol
            ));
            protocol = null;
          }
        }
      }

      // for (final port in availablePorts) {
      //   if(configurations.first.usbManufacturerNames.contains(port.manufacturerName)) {
      //     bool isKnownPort = mtPreviousScanResult.where((ep) => ep.name == port.deviceName).isNotEmpty;
      //     if(!isKnownPort) {
      //       newPorts.add(USBAndroidEndpoint(
      //         name: port.deviceName,
      //         info: port
      //       ));
      //     }
      //   }
      // }

      mt.updateEndpoints(
        remove: removedPorts,
        add: newPorts
      );

    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
  }
}

