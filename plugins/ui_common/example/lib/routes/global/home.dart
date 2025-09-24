import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';
// import 'package:ui_common_example/routes/content/alerts_overlays.dart';
// import 'package:ui_common_example/routes/content/annotated_list.dart';
// import 'package:ui_common_example/routes/content/big_controls.dart';
// import 'package:ui_common_example/routes/content/containers.dart';
// import 'package:ui_common_example/routes/content/fat_list.dart';
// import 'package:ui_common_example/routes/content/grid.dart';
// import 'package:ui_common_example/routes/content/input.dart';
// import 'package:ui_common_example/routes/content/messenger.dart';
// import 'package:ui_common_example/routes/end_drawer/home.dart';
// import 'package:ui_common_example/routes/content/home.dart';
// import 'package:ui_common_example/routes/content/icons.dart';

class HomeRoute extends StatelessWidget {
  static const route = '/';
  static Widget buildRoute(dynamic parameters) => const HomeRoute();
  static open (BuildContext context) => UICApp.of(context).navigator?.pushNamed(route);

  const HomeRoute({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    /// FIXME: Update this for modularization
    return Container();
    // return UICScaffold(
    //   appBar: const UICAppBar(title: "UIC Example"),
    //   endDrawer: const UICEndDrawer(
    //     initialRoute: EndDrawerHome.route,
    //   ),
    //   drawer: (context) => UICDrawer(
    //     leading: Container(
    //       padding: const EdgeInsets.all(20),
    //       color: theme.colorScheme.secondary,
    //       child: Container(
    //         height: 150,
    //         decoration: const BoxDecoration(
    //           image: DecorationImage(
    //             image: AssetImage("assets/images/uic.png"),
    //             fit: BoxFit.contain,
    //           ),
    //         ),
    //       ),
    //     ),
    //     trailing: ListTile(
    //       leading: const Icon(Icons.close),
    //       onTap: () => ContentHome.open(context),
    //       title: const Text("Beenden"),
    //     ),
    //     children: [
    //       UICInfo(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             const Text("Info Container"),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text("Version", style: theme.bodyMediumMuted),
    //                 Text("0", style: theme.bodyMediumMuted),
    //               ],
    //             )
    //           ],
    //         ),
    //       ),
          
    //       const UICSpacer(),
          
    //       UICDrawerTile(
    //         leading: const Icon(Icons.touch_app_rounded),
    //         onPressed: ContentHome.open,
    //         title: Text("Buttons".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.account_tree_rounded),
    //         onPressed: ContentIcons.open,
    //         title: Text("Icons".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.input),
    //         onPressed: ContentInput.open,
    //         title: Text("Input".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.speaker_notes_rounded),
    //         onPressed: ContentAlertsOverlays.open,
    //         title: Text("Alerts & Overlays".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.announcement_rounded),
    //         onPressed: ContentMessenger.open,
    //         title: Text("Messenger".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.check_box_outline_blank_rounded),
    //         onPressed: ContentContainers.open,
    //         title: Text("Containers".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.list_alt_rounded),
    //         onPressed: ContentFatList.open,
    //         title: Text("Fat List".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.swipe_up_rounded),
    //         onPressed: ContentBigControls.open,
    //         title: Text("Big Controls".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.error),
    //         onPressed: (context) { UICScaffold.of(context).contentNavigator?.pushNamed("nonsense");},
    //         title: Text("404".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.list),
    //         onPressed: AnnotatedList.open,
    //         title: Text("Annotated List".i18n),
    //       ),

    //       UICDrawerTile(
    //         leading: const Icon(Icons.list),
    //         onPressed: ContentGrid.open,
    //         title: Text("Annotated List".i18n),
    //       ),
    //     ]
    //   )
    // );
  }
}
