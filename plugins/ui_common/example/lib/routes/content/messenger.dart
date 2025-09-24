import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentMessenger extends StatelessWidget {
  static const route = '/contentmessenger';
  static Widget buildRoute(dynamic params) => const ContentMessenger();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);
  
  const ContentMessenger({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("Messenger popups"),
        
        const UICSpacer(),

        UICElevatedButton(
          onPressed: () {
            UICMessenger.of(context).addMessage(InfoMessage("Info message"));
          },
          child: const Text("Info message")
        ),
        
        const UICSpacer(),

        UICElevatedButton(
          style: UICColorScheme.warn,
          onPressed: () {
            UICMessenger.of(context).addMessage(WarningMessage("Warning message"));
          },
          child: const Text("Warn message")
        ),

        const UICSpacer(),

        UICElevatedButton(
          style: UICColorScheme.error,
          onPressed: () {
            UICMessenger.of(context).addMessage(ErrorMessage("Error message"));
          },
          child: const Text("Error message")
        ),

        const UICSpacer(),

        UICElevatedButton(
          style: UICColorScheme.success,
          onPressed: () {
            UICMessenger.of(context).addMessage(SuccessMessage("Success message"));
          },
          child: const Text("Success message")
        ),
      ],
    );
  }
}