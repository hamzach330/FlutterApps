import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:mt_interface/discovery.dart';
import 'package:mt_interface/multi_transport.dart';

class MTDesktop extends MTInterface {
  static void registerWith() {
    print("INIT DESKTOP ENDPOINT");
    MTDesktop();
  }
  
  MTDesktop() {
    print("CONSTRUCT DESKTOP ENDPOINT");
    MTInterface.transports.add(USBDesktopTransport(mt: this));
  }
}

class USBDesktopEndpoint extends MTEndpoint<SerialPort> {
  USBDesktopEndpoint({
    required super.name,
    required super.info,
    required super.protocolName,
  });

  @override
  Future<void> write (List<int> data) async {
    try {
      info.write(Uint8List.fromList(data), timeout: 0);
    } catch(e) {
      await close();
    }
  }

  @override
  Future<void> openWith (MTReaderWriter protocol) async {
    await super.openWith(protocol);

    connectionState.add(MTConnectionState.connecting);
    if(Platform.isMacOS || Platform.isLinux) {
      info..open(mode: SerialPortMode.read)
          ..close();
    }

    if (info.openReadWrite() != true) {
      await close();
      throw MTEndpointException(SerialPort.lastError?.message);
    }

    if(Platform.isWindows) {
      /// If the baudrate isn't set it won't work on windows.
      info.config = SerialPortConfig()
        ..baudRate = 9600;
    } else if (Platform.isMacOS) {
      info.config = SerialPortConfig()
        ..baudRate = 9600;
    }
    connectionState.add(MTConnectionState.connected);
    connected = true;

    setReader();
  }

  Future<void> setReader () async {
    readerSubscription?.cancel();
    readerSubscription = SerialPortReader(info).stream.listen((cb) => protocol?.read(List<int>.from(cb)))
      ..onError((err) async {
        await close();
      });
  }

  @override
  Future<void> close () async {
    if(!connected) return;
    await super.close();
    info.close();
    // info.dispose(); // ???
  }
}

/// [USBDesktopTransport] is the [libserialport] implementation of [MTTransportInterface].
/// 
/// Use this transport to connect to CentronicPLUS devices by USB Serial
/// 
class USBDesktopTransport extends MTTransportInterface {
  USBDesktopTransport({required super.mt});
  Timer? _scanTimer;

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    final configurations = configuration.whereType<USBAndroidDiscoveryConfig>().toList();
    print("CONFIGURATIONS: $configurations");

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if(endpoint != null) return; // pause scan during active connection

      final mtPreviousScanResult = MTInterface.scanResults.whereType<USBDesktopEndpoint>().toList();
      final availablePorts = SerialPort.availablePorts;
      final List<USBDesktopEndpoint> removedPorts = [];
      final List<USBDesktopEndpoint> newPorts = [];

      /// Find Ports that are no longer available
      for(final mtPort in mtPreviousScanResult) {
        if(availablePorts.where((port) => port == mtPort.name).isEmpty) {
          removedPorts.add(mtPort);
        }
      }

      String? protocol;
      /// Add newly found ports
      for (final port in availablePorts) {
        final serialPort = SerialPort(port);
        if(port.toLowerCase().contains("bluetooth") == false) {
          for(final config in configurations) {
            try {
              if(config.usbProductId == serialPort.productId && config.usbVendorId == serialPort.vendorId) {
                protocol = config.protocolName;
              }
            } catch(e) {
              print("Port Error ($port): $e");
            }
          }
        }

        if(protocol != null) {
          bool isKnownPort = mtPreviousScanResult.where((ep) => ep.name == port).isNotEmpty;
          if(!isKnownPort) {
            newPorts.add(USBDesktopEndpoint(
              name: port,
              info: serialPort,
              protocolName: protocol
            ));
          }
          protocol = null;
        }

        // if(configurations.first.usbManufacturerNames.contains(serialPort.manufacturer)) {
        //   bool isKnownPort = mtPreviousScanResult.where((ep) => ep.name == port).isNotEmpty;
        //   if(!isKnownPort) {
        //     newPorts.add(USBDesktopEndpoint(
        //       name: port,
        //       info: serialPort
        //     ));
        //   }
        // }
      }

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
