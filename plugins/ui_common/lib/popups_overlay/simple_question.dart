part of ui_common;

// Future<bool> uicSimpleQuestion ({
//   required BuildContext context,
//   required List<Widget> children,
//   required String title,
//   required String confirmText,
//   required String dismissText
// }) async {
//   final result = await uicAlert(
//     dismissable: true,
//     title: title,
//     children: children,
//     context: context,
//     actions: [
//       UICAlertAction(
//         text: confirmText,
//         onPressed: () => Navigator.of(context, rootNavigator: true).pop(true)
//       ),
//       UICAlertAction(
//         text: dismissText,
//         onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
//         isDestructiveAction: true
//       ),
//     ]
//   );

//   return result == true;
// }