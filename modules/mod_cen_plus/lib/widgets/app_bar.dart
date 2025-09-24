part of '../module.dart';

class CPAppBar extends UICAppBar {
  const CPAppBar({
    super.key,
    super.title = ""
  });
  
  @override
  get title => "Vorhandene Centronic PLUS Geräte".i18n;
  
  // @override
  // get ending => Consumer<SelectionProvider>(
  //   builder: (context, selectionProvider, _) {
  //     final theme = Theme.of(context);
  //     return Row(
  //       spacing: theme.defaultWhiteSpace,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         SizedBox(
  //           width: 200,
  //           child: UICTextInput(
  //             controller: selectionProvider.ownNodesFilter,
  //             hintText: "Filtern nach Name".i18n,
  //             label: "Filter".i18n,
  //             onClear: () {
  //               selectionProvider.setOwnNodeFilter("");
  //             },
  //             onEditingComplete: () {
  //               selectionProvider.setOwnNodeFilter(selectionProvider.ownNodesFilter.text);
  //             },
  //           ),
  //         ),
      
  //         if(UICScaffold.of(context).breakPointLXLXXL) UICGridTileAction(
  //           onPressed: () {
  //           },
  //           child: Icon(
  //             selectionProvider.viewMode == UICGridViewMode.list ? Icons.list_outlined : Icons.grid_view
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  // );
}