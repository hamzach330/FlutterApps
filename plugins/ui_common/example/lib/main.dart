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
// import 'package:ui_common_example/routes/global/home.dart';
// import 'package:ui_common_example/routes/content/home.dart';
// import 'package:ui_common_example/routes/content/icons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Localization.loadTranslations();

  runApp(const IUCExample());
}

class IUCExample extends StatelessWidget {
  const IUCExample({super.key});

  @override
  Widget build(BuildContext context) {
    /// FIXME: Update this for modularization
    return Container();
    // return const UICApp(
    //   providers: [],
    //   routes: {
    //     HomeRoute.route: HomeRoute.buildRoute,
    //   },
    //   endDrawerRoutes: {
    //     EndDrawerHome.route: EndDrawerHome.buildRoute
    //   },
    //   contentRoutes: {
    //     ContentHome.route: ContentHome.buildRoute,
    //     ContentIcons.route: ContentIcons.buildRoute,
    //     ContentInput.route: ContentInput.buildRoute,
    //     ContentAlertsOverlays.route: ContentAlertsOverlays.buildRoute,
    //     ContentMessenger.route: ContentMessenger.buildRoute,
    //     ContentContainers.route: ContentContainers.buildRoute,
    //     ContentFatList.route: ContentFatList.buildRoute,
    //     ContentBigControls.route: ContentBigControls.buildRoute,
    //     AnnotatedList.route: AnnotatedList.buildRoute,
    //     ContentGrid.route: ContentGrid.buildRoute
    //   },
    //   appTitle: "Common UI Example",
    //   supportedLocales: [Locale("de")],
    // );
  }
}
