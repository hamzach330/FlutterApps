
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentFatList extends StatefulWidget {
  static const route = '/contentfatlist';
  static Widget buildRoute(dynamic params) => const ContentFatList();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentFatList({super.key});

  @override
  State<ContentFatList> createState() => _ContentFatListState();
}

class _ContentFatListState extends State<ContentFatList> {
  final List<int> data = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: const UICTitle("UICFatList Example"),
            ),

            Expanded(
              child: UICFatList(
                title: "UICFatList",
                subTitle: "No elements yet",
                items: data,
                itemBuilder: (context, item, animation) {
                  return UICFatListTile(
                    onTap: () async { },
                    animation: animation,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundImage: const AssetImage("assets/images/uic.png"),
                      radius: 40,
                    ),
                    title: "FatListTile title $item".i18n,
                    subtitle: "Fatlist subtitle",
                  );
                }
              )
            ),
          ],
        ),

        Positioned(
          right: theme.defaultWhiteSpace,
          bottom: theme.defaultWhiteSpace,
          child: IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.green),
            color: Colors.white,
            onPressed: () {
              setState(() => data.add(data.isEmpty ? 0 : data.last + 1));
            },
            icon: const Icon(Icons.add, size: 32),
          )
        ),

        Positioned(
          left: theme.defaultWhiteSpace,
          bottom: theme.defaultWhiteSpace,
          child: IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.red),
            color: Colors.white,
            onPressed: () {
              setState(() => data.isNotEmpty ? data.removeLast() : null);
            },
            icon: const Icon(Icons.remove, size: 32),
          )
        )
      ],
    );
  }
}
