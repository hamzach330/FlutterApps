// part of 'routing.dart';

// class NodeSensorValueHistoryView extends StatelessWidget {
//   final String mac;
//   const NodeSensorValueHistoryView({super.key, required this.mac});


//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CPNodeProtocol>(
//       builder: (context, node, _) {
//         return SliverListWrap(
//           children: [
//             const CPNodeInfoView(),

//             const UICSpacer(),

//             Center(
//               child: IconButton(
//                 onPressed: () async {
//                   await Clipboard.setData(ClipboardData(text: node.logData.join("\n")));
//                 },
//                 icon: const Icon(Icons.copy_all),
//               ),
//             ),

//             const UICSpacer(),

//             if(node.isSensor) Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 for(final logval in node.logData)
//                   Text(logval)
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
