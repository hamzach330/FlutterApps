import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';
import 'package:ui_common_example/routes/content/icons.dart';

class ContentHome extends StatelessWidget {
  static const route = '/';
  static Widget buildRoute(dynamic params) => const ContentHome();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("UIC Buttons"),
        
        const UICSpacer(),

        UICTextButton(
          style: UICColorScheme.error,
          onPressed: () => ContentIcons.open(context),
          text: "Error style"
        ),

        const UICSpacer(),

        UICTextButton(
          style: UICColorScheme.warn,
          onPressed: () => ContentIcons.open(context),
          text: "Warn style"
        ),

        const UICSpacer(),

        UICTextButton(
          style: UICColorScheme.success,
          onPressed: () => ContentIcons.open(context),
          text: "Success style"
        ),

        const UICSpacer(),

        UICTextButton(
          onPressed: () => ContentIcons.open(context),
          text: "Default style"
        ),

        const UICSpacer(),

        const UICTitle("UIC Elevated Buttons"),

        const UICSpacer(),

        Center(
          child: UICElevatedButton(
            style: UICColorScheme.error,
            onPressed: () => ContentIcons.open(context),
            child: const Text("Error style")
          ),
        ),

        const UICSpacer(),

        UICElevatedButton(
          style: UICColorScheme.warn,
          onPressed: () => ContentIcons.open(context),
          trailing: const Icon(BeckerIcons.back),
          child: const Text("Warn style with icon after")
        ),

        const UICSpacer(),

        UICElevatedButton(
          style: UICColorScheme.success,
          onPressed: () => ContentIcons.open(context),
          leading: const Icon(BeckerIcons.back),
          child: const Text("Success style with icon before")
        ),

        const UICSpacer(),

        UICElevatedButton(
          onPressed: () => ContentIcons.open(context),
          child: const Text("Default style")
        ),

        const UICSpacer(),

        for(int i = 0; i < 100; i++) const Text("Fill")
      ]
    );
  }
}
