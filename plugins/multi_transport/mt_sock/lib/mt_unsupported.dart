import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';

class MTSockUnsupported extends MTInterface {
  static void registerWith() {}
}

class USBSockUnsupportedEndpoint extends MTEndpoint {
  USBSockUnsupportedEndpoint({
    required super.name,
    required super.info,
    required super.protocolName
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> write(List<int> data) {
    throw UnimplementedError();
  }
}