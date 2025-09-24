
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentContainers extends StatelessWidget {
  static const route = '/contentcontainers';
  static Widget buildRoute(dynamic params) => const ContentContainers();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentContainers({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("UIC Containers"),
        
        const UICSpacer(),

        UICOptionList(
          dividers: true,
          children: [
            for(int i = 0; i < 10; i++)
              const Text("test"),
          ]
        )
      ],
    );
  }
}
