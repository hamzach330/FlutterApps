// import 'package:centronic_plus_protocol/centronic_plus.dart';


// final transport = MtultiTransportDesktop();
// bool endpointFound = false;
// CPProtocol? cplus;

// endpointListener (ep) async {
//   if(endpointFound == true || ep.isEmpty) return;
//   endpointFound = true;
//   transport.stopScan();
    
//   await ep.first.open();
//   cplus = CPProtocol(endpoint: ep.first);
//   cplus?.initEndpoint(readMesh: true);
//   await Future.delayed(Duration(seconds: 30));

//   print("Found ${cplus?.nodes.length} nodes");
//   for(final node in cplus?.nodes ?? []) {
//     print("FOUND NODE: ${node.name}");
//   }
    
//   transport.closeEndpoint();
// }

// scan () async {
//   transport.startScan();
//   transport.scanResult.stream.listen(endpointListener);
//   print("Scan complete");
// }

// main() {
//   scan();
// }

// // import 'dart:developer' show log;
// // import 'dart:io' show exit;

// // import 'package:centronic_plus/centronic_plus.dart';

// // Future<void> sleep (int seconds) async {
// //   log("Waiting $seconds seconds...");
// //   await Future.delayed(Duration(seconds: seconds));
// // }

// // Future<void> onScanResult (ReadNodeEvent scanResult) async {
// //   log("Scan Result: ${scanResult.mac}");
// // }

// // void main () async {
// //   try {
// //     final centronicPlus = CPMultiTransport(transport: CPUSBTransport());

// //     await centronicPlus.startScan();

// //     bool endpointFound = false;

// //     centronicPlus.scanResult.stream.listen((ep) async {
// //       if(endpointFound == true || ep.isEmpty) return;
// //       endpointFound = true;

// //       centronicPlus.openEndpoint(ep.first);
// //       final stickInfo = await centronicPlus.readPanId();
// //       log("StickInfo: $stickInfo");

// //       final stickVersion = await centronicPlus.readStickVersion();
// //       log("StickVersion: ${stickVersion?.version}");

// //       await centronicPlus.startReadAllNodes();

// //       final stream = centronicPlus.subscribe<ReadNodeEvent>();
// //       stream?.stream.listen(onScanResult);

// //       await sleep(10);

// //       centronicPlus.stopReadAllNodes();
// //       exit(0);
// //     });
// //   } catch (e) {
// //     log("Backend died: $e");
// //     exit(1);
// //   } finally {
// //     // exit(0);
// //   }
// // }

