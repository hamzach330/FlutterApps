import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentAlertsOverlays extends StatelessWidget {
  static const route = '/alertsoverlays';
  static Widget buildRoute(dynamic params) => const ContentAlertsOverlays();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentAlertsOverlays({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(theme.defaultWhiteSpace),
      children: [
        const UICTitle("Alerts & Overlays"),
        
        const UICSpacer(),

        UICElevatedButton(
          onPressed: () async => UICMessenger.of(context).alert(UICSimpleAlert(
            title: "Simple alert",
            child: const Text("This is a simple adaptive alert dialog!")
          )),
          child: const Text("Simple platform adaptive dialog")
        ),
        
        const UICSpacer(),

        UICElevatedButton(
          onPressed: () async => UICMessenger.of(context).alert(UICSimpleAlert(
            useMaterial: true,
            title: "Simple alert (force material)",
            child: const Text("This is a simple adaptive alert dialog!")
          )),
          child: const Text("Simple dialog (force material)")
        ),

        const UICSpacer(),

        UICElevatedButton(
          onPressed: () async => UICMessenger.of(context).alert(UICSimpleQuestionAlert(
            title: "Simple question",
            child: const Text("Yes or no?"),
          )),
          child: const Text("Simple question dialog")
        )
      ],
    );
  }
}
