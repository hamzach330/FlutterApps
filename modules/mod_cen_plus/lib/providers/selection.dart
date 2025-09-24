part of '../module.dart';

// class SelectionInterceptor {
//   UICAlert<bool> alert;

//   SelectionInterceptor({
//     required this.alert,
//   });
// }

// class SelectionProvider extends ChangeNotifier {
//   double screenWidth = 0;

//   TextEditingController ownNodesFilter = TextEditingController();

//   GlobalKey<NavigatorState>? nodeViewNavigator;

//   /// Whether the node configuration view is visible
//   bool showNode = false;

//   /// The currently selected node inside the node configuration menu
//   CentronicPlusNode? selection;

//   bool multiSelect = false;
//   List<CentronicPlusNode> multiSelection = [];
//   Future<bool> Function(CentronicPlusNode)? _multiSelectOnSelect;
//   CentronicPlusNode? _multiSelectionInitialSelection;
//   Widget? multiSelectHint;

//   UICGridViewMode _viewMode = UICGridViewMode.grid;
//   UICGridViewMode get viewMode => _viewMode;

//   UICAlert Function(dynamic)? _selectionInterceptor;

//   set viewMode(UICGridViewMode mode) {
//     _viewMode = mode;
//     _postFrameNotify();
//   }

//   setMultiselection(List<CentronicPlusNode> newSelection) {
//     multiSelection = newSelection;
//     _postFrameNotify();
//   }

//   void _postFrameNotify () {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       notifyListeners();
//     });
//   }

//   /// Select the node to be displayed in the node configuration menu and open the view
//   /// Returns true if the selection has changed from deselect to select
//   Future<bool> select(CentronicPlusNode node, BuildContext context) async {
//     if(_selectionInterceptor != null) {
//       await UICMessenger.of(context).alert(_selectionInterceptor!(node));
//       _postFrameNotify();
//       return false;
//     }

//     if(multiSelect) {
//       if(_multiSelectionInitialSelection != node) {
//         if(_multiSelectOnSelect != null) {
//           if(await _multiSelectOnSelect!(node) == true) {
//             final _node = multiSelection.firstWhereOrNull((element) => node.mac == element.mac);

//             for(final _node in multiSelection) {
//               dev.log("Node mac: ${_node.mac} == ${node.mac} ? ${_node.mac == node.mac}");
//             }

//             dev.log("test $_node");

//             if(_node != null) {
//               multiSelection.remove(_node);
//               _postFrameNotify();
//               return false;
//             } else {
//               multiSelection.add(node);
//               _postFrameNotify();
//               return true;
//             }
//           }
//         } else {
//           if(multiSelection.contains(node)) {
//             multiSelection.remove(node);
//             _postFrameNotify();
//             return false;
//           } else {
//             multiSelection.add(node);
//             _postFrameNotify();
//             return true;
//           }
//         }
//       }
//     } else if(selection != node) {
//       selection = node;
//       _postFrameNotify();
//       return true;
//     }

//     return false;
//   }

//   deselect() {
//     selection = null;
//     nodeViewNavigator = null;
//     showNode = false;
//     _postFrameNotify();
//   }

//   startMultiSelection({
//     required Widget hint,
//     CentronicPlusNode? initialSelection,
//     bool Function(CentronicPlusNode)? filter,
//     Future<bool> Function(CentronicPlusNode)? onSelect,
//   }) {
//     _multiSelectOnSelect = onSelect;
//     _multiSelectionInitialSelection = initialSelection;
//     initialSelection?.cp.setCondidionalNodeFilter(filter);

//     multiSelectHint = hint;
//     multiSelection.clear();
//     multiSelect = true;
//     if(initialSelection != null) {
//       multiSelection.add(initialSelection);
//     }

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _postFrameNotify();
//     });
//   }

//   stopMultiSelection () {
//     unsetSelectionInterceptor();
//     _multiSelectionInitialSelection?.cp.setCondidionalNodeFilter(null);
//     _multiSelectionInitialSelection = null;
//     multiSelection.clear();
//     multiSelect = false;
//     multiSelectHint = null;
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _postFrameNotify();
//     });
//   }

//   setSelectionInterceptor(UICAlert Function(dynamic) interceptor) {
//     _selectionInterceptor = interceptor;
//   }

//   unsetSelectionInterceptor() {
//     _selectionInterceptor = null;
//   }

//   setOwnNodeFilter(String text) {
//     ownNodesFilter.text = text;
//     _postFrameNotify();
//   }

// }
