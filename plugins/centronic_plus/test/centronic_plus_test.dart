// import 'dart:developer';

// import 'package:test/test.dart';
// import 'package:centronic_plus/centronic_plus.dart';
// import 'dart:async';

// final centronicPlus = CPMultiTransport(transport: CPUSBTransport());

// String? pan = "";
// void main() {

//   test("End to end", () async{
    
//     final ports = await centronicPlus.getEndpoints();
//     StreamController<ReadNodeEvent>? readNodeController;

//     expect(ports?.length, greaterThan(0));

//     for(final serialPort in ports ?? []) {

//       centronicPlus.openEndpoint(serialPort);
//       centronicPlus.messageLog.stream.listen((event) {
//         log(event.last.telegram);
//       });

//       final stickInfo = await centronicPlus.readPanId();
//       pan = stickInfo?.panId;
//       expect(stickInfo, const TypeMatcher<ReadPanId>());

//       final stickVersion = await centronicPlus.readStickVersion();
//       expect(stickVersion, const TypeMatcher<ReadStickVersion>());
//       expect(stickVersion?.version, isNotNull);
      
//       readNodeController = centronicPlus.subscribe<ReadNodeEvent>();
//       readNodeController?.stream.listen(_nodeFound);
//       await centronicPlus.startReadAllNodes();

//       await Future.delayed(const Duration(seconds: 60));

//       centronicPlus.closeEndpoint();
//     }
//   });

//   test("ReadSWVersion.unpack", () async {
//     final readSWVersion = ReadStickVersion();
//     final telegram = [0x01, 0x1E, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x01, 0x06, 0x03, 0x34];
//     readSWVersion.unpack(telegram);

//     // expect(readSWVersion.port, equals(HEX.encode([0x01])));
//     // expect(readSWVersion.accid, equals(HEX.encode([0x1E])));
//     // expect(readSWVersion.blnr, equals(HEX.encode([0x02])));
//     // expect(readSWVersion.blen, equals(HEX.encode([0x03])));
//     expect(readSWVersion.version, equals("163"));
//   });
// }

// List<String> knownNodes = [];
// void _nodeFound(ReadNodeEvent event) async {
//   if(knownNodes.isEmpty) {
//     knownNodes.add(event.mac!);
    
//     // final foo = await centronicPlus.sendRawCommand(mac: event.macAdress, cmd: [0x40, 0x00]);
//     centronicPlus.sendDownCommand(mac: event.mac!);
//     await Future.delayed(const Duration(seconds: 1));
    
//     centronicPlus.sendStopCommand(mac: event.mac!);
//     await Future.delayed(const Duration(seconds: 1));
    
//     centronicPlus.sendUpCommand(mac: event.mac!);
//     await Future.delayed(const Duration(seconds: 1));
    
//     centronicPlus.sendStopCommand(mac: event.mac!);
//     await Future.delayed(const Duration(seconds: 1));
//   }
// }

// // 07 01 01 1a a0 dc 04 ff fe 01 00 37 01 01 34 00 00 00 00 00 20 00 40 00 00 00 0b 00 05 01
// // 07 01 01 1A A0 DC 04 FF FE 01 00 37 01 01 34 00 00 00 00 00 20 00 40 00 00 00 0B 00 05 01
