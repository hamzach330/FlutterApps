import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';

class MTBLE extends MTInterface {
  static void registerWith() {}
}

class LEEndpoint extends MTEndpoint {
  LEEndpoint({
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

