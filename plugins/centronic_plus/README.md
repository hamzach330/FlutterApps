# centronic_plus

Connect to Becker Antriebe CentronicPLUS devices

## Getting Started

Example usage:
```
  try {
    final centronicPlus = CentronicPLUS.withTransportUSB();

    final ports = centronicPlus.getEndpoints();
    log("Ports: $ports");

    if (ports.isEmpty) {
      log("No CentronicPLUS stick found");
      exit(1);
    }

    for(final serialPort in ports) {
      centronicPlus.openPort(serialPort);

      final stickInfo = await centronicPlus.readPanId();
      log("StickInfo: $stickInfo");

      final stickVersion = await centronicPlus.readSWVersion();
      log("StickVersion: ${stickVersion.version}");

      final scanSubscription = (await centronicPlus.startReadAllNodes()).listener.stream.listen(onScanResult);
      (await centronicPlus.startReadRoutingTable()).listener.stream.listen(onScanResult);
      (await centronicPlus.startReadNeighborTable()).listener.stream.listen(onScanResult);

      await sleep(10);

      centronicPlus.stopReadAllNodes();
      scanSubscription.cancel();
      await sleep(1);
    }
  } catch (e) {
    log("Backend died: $e");
    exit(1);
  } finally {
    exit(0);
  }
```


## General concepts:
Every complete message starts with an ETX 0x02 and ends with an STX 0x03.
The first byte (called port internally) is always 0x07.



