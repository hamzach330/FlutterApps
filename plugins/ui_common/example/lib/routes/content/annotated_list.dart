import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class AnnotatedList extends StatefulWidget {
  static const route = '/annotatedlist';
  static Widget buildRoute(dynamic params) => const AnnotatedList();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const AnnotatedList({super.key});

  @override
  State<AnnotatedList> createState() => _AnnotatedListState();
}

class _AnnotatedListState extends State<AnnotatedList> {
  bool _annotation = true;
  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 5),
      (timer) => setState(() => _annotation = !_annotation)
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedSwitcher(
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            child: child
          ),
          duration: const Duration(milliseconds: 300),
          child: !_annotation ?  const SizedBox() : Container(
            margin: EdgeInsets.all(theme.defaultWhiteSpace),
            padding: EdgeInsets.all(theme.defaultWhiteSpace),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
              color: theme.colorScheme.primaryContainer
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for(int i = 0; i < 5; i ++) const Text("test")],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(
            top: theme.defaultWhiteSpace,
            left: theme.defaultWhiteSpace,
            right: theme.defaultWhiteSpace
          ),
          child: const UICTitle("test"),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(theme.defaultWhiteSpace),
            children: List.filled(200, const Text("test")),
          ),
        )
      ],
    );
  }
}
