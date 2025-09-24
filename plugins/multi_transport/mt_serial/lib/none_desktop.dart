import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/multi_transport.dart';

class MTDesktop extends MTInterface {
  static void registerWith() {
    print("INIT DESKTOP ENDPOINT");
    MTDesktop();
  }
}

class USBDesktopEndpoint extends MTEndpoint {
  USBDesktopEndpoint({
    required super.name,
    required super.info,
    required super.protocolName,
  });
  
  @override
  Future<void> write(List<int> data) {
    throw UnimplementedError();
  }
}