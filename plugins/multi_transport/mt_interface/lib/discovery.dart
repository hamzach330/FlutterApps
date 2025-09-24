abstract class DiscoveryConfig {
  final String protocolName;
  const DiscoveryConfig({required this.protocolName});
}

class BLEDiscoveryService {
  final String tx;
  final String rx;
  final String serviceId;
  final String protocolName;
  final bool txWithResponse;

  const BLEDiscoveryService({
    required this.protocolName,
    required this.tx,
    required this.rx,
    required this.serviceId,
    this.txWithResponse = true,
  });
}

class BLEDiscoveryConfig extends DiscoveryConfig {
  final int bleAdvertisementInterval;
  final String primaryServiceId;
  final List<BLEDiscoveryService> services;

  final int vendorId;
  final List<int> productId;

  final bool wantsPairing;
  final String? pairingPin;
  final String? pairingMethod;

  const BLEDiscoveryConfig({
    required super.protocolName,
    required this.primaryServiceId,
    required this.vendorId,
    required this.productId,
    this.bleAdvertisementInterval = 10000,
    required this.services,
    this.wantsPairing = false,
    this.pairingPin,
    this.pairingMethod,
  });
}

class USBDiscoveryConfig extends DiscoveryConfig {
  final String usbManufacturerName;
  final int usbProductId;
  final int usbVendorId;

  const USBDiscoveryConfig({
    required super.protocolName,
    this.usbManufacturerName = "",
    this.usbProductId = 0,
    this.usbVendorId = 0,
  });
}

class USBAndroidDiscoveryConfig extends DiscoveryConfig {
  final String usbManufacturerName;
  final int usbProductId;
  final int usbVendorId;

  const USBAndroidDiscoveryConfig({
    required super.protocolName,
    this.usbManufacturerName = "",
    this.usbProductId = 0,
    this.usbVendorId = 0,
  });
}

class MDNSDiscoveryConfig extends DiscoveryConfig {
  final String? mdnsName;
  final int? mdnsPort;
  final bool Function(dynamic record)? mdnsFilter;
  final String? websocketAddress;
  final int? websocketPort;

  const MDNSDiscoveryConfig({
    required super.protocolName,
    this.mdnsName,
    this.mdnsPort,
    this.mdnsFilter,
    this.websocketAddress,
    this.websocketPort,
  });
}
