import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class EndDrawerHome extends StatelessWidget {
  static const route = '/drawerhome';
  static Widget buildRoute(dynamic params) => const EndDrawerHome();
  static void open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const EndDrawerHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      primary: true,
      children: [
        UICElevatedButton(
          onPressed: () => EndDrawerHome.open(context),
          child: const Text("Go")
        )
      ],
    );
  }
}


