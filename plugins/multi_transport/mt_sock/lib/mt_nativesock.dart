import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:mt_interface/discovery.dart';
// import 'package:multicast_dns/multicast_dns.dart';
import 'package:bonsoir/bonsoir.dart';
// import 'dart:io' show Platform;

class MTSocket extends MTInterface {
  static void registerWith([registrar]) {
    print("MTSocket.registerWith $registrar");
    MTSocket();
  }

  MTSocket() {
    print("MTSocket()");
    MTInterface.transports.add(MTSocketTransport(mt: this));
  }
}

class MTSocketEndpoint extends MTEndpoint<MTMDNSRecord> {
  MTSocketEndpoint({
    required super.name,
    required super.info,
    required super.protocolName,
    required this.lastSeen
  });

  Socket? _socket;
  DateTime lastSeen;

  @override
  Future<void> write (List<int> data) async {
    _socket?.add(data);
  }

  @override
  Future<void> openWith(MTReaderWriter protocol) async {
    await super.openWith(protocol);

    try {
      _socket = await Socket.connect(info.ip4, info.port ?? 80);
      connectionState.add(MTConnectionState.connected);
      connected = true;
    } catch(e) {
      await close();
      return;
    }

    _socket?.listen((Uint8List data) {
      print("Received data: $data");
      protocol.read(List<int>.from(data));
    }, onDone: () {
      print("Socket Done");
      close();
    }, onError: (e) {
      print("Socket Error: $e");
      close();
    });
  }

  @override
  Future<void> close () async {
    if(!connected) return;
    await super.close();
    _socket?.close();
  }
}

class MTMDNSRecord {
  String? domain;
  String? target;
  int? port;
  String? ip4;
  String? ip6;
  Map<String, String> txt = {};

  MTMDNSRecord({
    this.domain,
    this.target,
    this.port,
    this.ip4,
    this.ip6
  });


  @override
  String toString() {
    return "MTDNSRecord: $domain $target $port $ip4 $ip6 $txt";
  }
}

class MTSocketTransport extends MTTransportInterface {
  
  MTSocketTransport({required super.mt});
  BonsoirDiscovery discovery = BonsoirDiscovery(type: '_http._tcp');
  // final MDnsClient client = MDnsClient(
  //   // rawDatagramSocketFactory: (host, int port,
  //   //   {bool reuseAddress = true, bool reusePort = false, int ttl = 1}) {
  //   //     return RawDatagramSocket.bind(
  //   //       host, port,
  //   //       reuseAddress: reuseAddress,
  //   //       reusePort: !Platform.isWindows,
  //   //       ttl: ttl
  //   //     );
  //   //   }
  // );
  bool scanning = false;

  Future<List<MTMDNSRecord>> _lookup(String mdnsName) async {

    // discovery.eventStream!.listen((event) { // `eventStream` is not null as the discovery instance is "ready" !
    //   if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
    //     print('Service found : ${event.service.toJson()}')
    //     event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
    //   } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
    //     print('Service resolved : ${event.service.toJson()}')
    //   } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
    //     print('Service lost : ${event.service.toJson()}')
    //   }
    // });

    await for (final event in discovery.eventStream!) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('Service found : ${event.service?.toJson()}');
        event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        print('Service resolved : ${event.service?.toJson()}');
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost : ${event.service?.toJson()}');
      }
    }

    final records = <MTMDNSRecord>[];
    // final ptrResourceRecords = client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(mdnsName));
    // await for (final ptr in ptrResourceRecords) {
    //   final MTMDNSRecord record = MTMDNSRecord();
    //   record.domain = ptr.domainName;
    //   final srvResourceRecords = await client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName));
      
    //   await for(final srv in srvResourceRecords) {
    //     record.port = srv.port;
    //     record.target = srv.target;
    //     final ipAddressResourceRecords = await client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target));
        
    //     await for (final ip in ipAddressResourceRecords) {
    //       if(ip.address.type == InternetAddressType.IPv4) {
    //         record.ip4 = ip.address.address;
    //       } else if(ip.address.type == InternetAddressType.IPv6) {
    //         record.ip6 = ip.address.address;
    //       }
    //     }
    //   }

    //   final txtResourceRecords = await client.lookup<TxtResourceRecord>(ResourceRecordQuery.text(ptr.domainName));
    //   await for (final txt in txtResourceRecords) {
    //     final lines = txt.text.split('\n').where((line) => line.trim().isNotEmpty && line.contains("=")).toList();
    //     for (final line in lines) {
    //       final parts = line.split("=");
    //       final key = parts[0].trim();
    //       final value = parts[1].trim();
    //       record.txt[key] = value;
    //     }
    //   }
    //   if(records.where((element) => element.domain == record.domain).isEmpty) {
    //     records.add(record);
    //   }
    // }
    return records;
  }

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    final configurations = configuration.whereType<MDNSDiscoveryConfig>().toList();
    print("CONFIGURATIONS: $configurations");

    if(scanning) return;

    // await client.start();
    await discovery.ready;
    scanning = true;

    while(scanning) {
      final availablePorts = await _lookup("_http._tcp");
      print("Available Ports: $availablePorts");

      if(endpoint != null) return; // pause scan during active connection

      final mtPreviousScanResult = MTInterface.scanResults.whereType<MTSocketEndpoint>().toList();
      final List<MTSocketEndpoint> removedPorts = [];
      final List<MTSocketEndpoint> newPorts = [];

      /// Find Ports that are no longer available
      for(final mtPort in mtPreviousScanResult) {
        if(availablePorts.where((port) => port.ip4 == mtPort.info.ip4).isEmpty) {
          if(mtPort.lastSeen.difference(DateTime.now()).inSeconds > 30) {
            removedPorts.add(mtPort);
          }
        }
      }

      String? protocol;
      /// Add newly found ports
      for (final port in availablePorts) {
        for(final config in configurations) {
          port.port = config.mdnsPort;
          try {
            if(config.mdnsFilter?.call(port) == true) {
              protocol = config.protocolName;
            }
          } catch(e) {
            print("Port Error ($port): $e");
          }
        }

        if(protocol != null) {
          final knownPort = mtPreviousScanResult.where((ep) => ep.info.ip4 == port.ip4);
          if(knownPort.isEmpty) {
            newPorts.add(MTSocketEndpoint(
              name: port.ip4 ?? port.ip6 ?? "",
              info: port,
              lastSeen: DateTime.now(),
              protocolName: protocol
            ));
          } else {
            for(final port in knownPort) {
              port.lastSeen = DateTime.now();
            }
          }
          protocol = null;
        }
      }

      mt.updateEndpoints(
        remove: removedPorts,
        add: newPorts
      );

    }
  }

  @override
  Future<void> stopScan() async {
    scanning = false;
  }
}

