import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/transport.dart';
import 'package:mt_interface/discovery.dart';
import 'package:mt_sock/mt_nativesock.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
// import 'package:multicast_dns/multicast_dns.dart';
import 'package:bonsoir/bonsoir.dart';

class MTWebSocket extends MTInterface {
  static void registerWith([registrar]) {
    print("MTWebSocket.registerWith $registrar");
    MTWebSocket();
  }

  MTWebSocket() {
    print("MTWebSocket()");
    MTInterface.transports.add(MTWebSocketTransport(mt: this));
  }
}

class MTWebSocketEndpoint extends MTEndpoint<MTMDNSRecord> {
  String? cookie;
  String? url;

  MTWebSocketEndpoint({
    required super.name,
    required super.info,
    required super.protocolName,
    required this.lastSeen,
    this.cookie,
    this.url
  });

  WebSocket? _socket;

  int _id = 0;
  bool _registered = false; // Whether the client is registered.
  Completer? _completer;
  DateTime lastSeen;

  @override
  Future<void> write (List<int> data) async {
    if(_registered) {
      print("WRITE: $data");
      final _data = data.sublist(1, data.length - 1);
      final telegram = ascii.decode(_data);
      final message = '{"jsonrpc": "2.0", "method": "deviced.deviced_send_backend_command", "params": {"backend": "centronic-plus", "command": "send-telegram", "raw": "$telegram"}, "id": $_id}';
      List<int> payload = List<int>.from(ascii.encode(message))..add(0x00);
      _socket?.add(payload);
    } else {
      _socket?.add(data);
    }
    _id++;
  }

  @override
  Future<void> openWith(MTReaderWriter protocol) async {
    await super.openWith(protocol);

    print("CONNECTING TO: $url");
    print("CONNECTING TO: $url");
    print("CONNECTING TO: $url");

    try {
      _socket = await WebSocket.connect(
        url ?? 'ws://${info.ip4}/jrpc',
        headers: {
          "Sec-WebSocket-Protocol": "binary",
          "Origin": "https://gw.b-tronic.net",
          "Host": "gw.b-tronic.net",
          "Cookie": cookie ?? "",
          // "Token": _token,
        },
      );
    } catch(e) {
      print("ERROR: $e");
    }

    // await _socket?.ready;
    connected = true;

    _socket?.listen((data) {
      final strval = ascii.decode(data).substring(0, ascii.decode(data).length - 1);

      if(_registered) {
        final jsonData = json.decode(strval);
        print("JSON MESSAGE: $jsonData");
        if((jsonData["method"] ?? "") == "deviced.deviced_backend_passthrough_in") {
          final cpData = [0x02, ...ascii.encode(jsonData["params"]["raw"]), 0x03];
          protocol.read(cpData);
        }
        return;
      }

      if(_completer?.isCompleted == false) {
        _completer?.complete();
      }
    }, onDone: () {
      print("Socket Done");
      close();
    }, onError: (e) {
      print("Socket Error: $e");
      close();
    });

    _completer = Completer();
    String request = '{"jsonrpc": "2.0", "method": "rpc_client_register", "params": {"name": "PassThrough_${DateTime.now().millisecond}"}, "id": $_id}';
    List<int> payload = List<int>.from(ascii.encode(request))..add(0x00);
    write(payload);
    await _completer!.future;

    _completer = Completer();
    request = '{"jsonrpc": "2.0", "method": "rpc_client_subscribe", "params": {"pattern": "deviced.deviced_backend_passthrough_in"}, "id": $_id}';
    payload = List<int>.from(ascii.encode(request))..add(0x00);
    write(payload);
    await _completer!.future;

    _completer = Completer();
    request = '{"jsonrpc": "2.0", "method": "deviced.deviced_send_backend_command", "params": {"backend":  "centronic-plus", "command":  "passthrough-mode", "enabled":  true}, "id": $_id}';
    payload = List<int>.from(ascii.encode(request))..add(0x00);
    write(payload);
    await _completer!.future;

    _registered = true;
  }

  @override
  Future<void> close () async {
    if(!connected) return;
    await super.close();
    await _socket?.close();
  }
}

class MTWebSocketTransport extends MTTransportInterface {
  MTWebSocketTransport({required super.mt});
  bool scanning = false;

  MTWebSocketEndpoint? oldEndpoint;
  BonsoirDiscovery discovery = BonsoirDiscovery(type: '_http._tcp');
  bool discoveryReady = false;

  @override
  Future<void> startScan(List<DiscoveryConfig> configuration) async {
    final configurations = configuration.whereType<MDNSDiscoveryConfig>().toList();
    final config = configurations.firstOrNull;

    if(config == null) {
      return;
    }

    if(!discoveryReady) {
      await discovery.ready;
      discoveryReady = true;
    }

    if(scanning) {
      await discovery.stop();
    }

    scanning = true;
    discovery.eventStream!.listen((event) { // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('Service found : ${event.service?.toJson()}');
        event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        final service = event.service as ResolvedBonsoirService;
        final record = MTMDNSRecord(
          port: service.port,
          ip4: service.host,
          ip6: service.host,
          target: service.name,
        )..txt = service.attributes;
        
        final previousResults = MTInterface.scanResults.whereType<MTWebSocketEndpoint>().toList().where((element) => element.info.ip4 == record.ip4 || element.info.ip6 == record.ip6);
        if(previousResults.isEmpty) {
          if(config.mdnsFilter != null && !config.mdnsFilter!(record)) {
            return;
          }
          mt.updateEndpoints(
            remove: [],
            add: [MTWebSocketEndpoint(
              name: config.websocketAddress ?? "localhost",
              info: record,
              protocolName: config.protocolName,
              lastSeen: DateTime.now()
            )]
          );
          print('Service resolved : ${event.service?.toJson()}');
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost : ${event.service?.toJson()}');
      }
    });

    await discovery.start();
  }

  @override
  Future<void> stopScan() async {
    if(scanning == false) {
      await discovery.stop();
      discovery = BonsoirDiscovery(type: '_http._tcp');
    }
    scanning = false;
    discoveryReady = false;
  }
}

