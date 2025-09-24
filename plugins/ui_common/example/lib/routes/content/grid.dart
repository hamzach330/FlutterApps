import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentGrid extends StatefulWidget {
  static const route = '/grid';
  static Widget buildRoute(dynamic params) => const ContentGrid();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentGrid({super.key});

  @override
  State<ContentGrid> createState() => _ContentGridState();
}

class _ContentGridState extends State<ContentGrid> {
  final List<UniqueKey> items = List.generate(100, (index) => UniqueKey());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: const UICTitle("UICGrid Example"),
            ),

            Expanded(
              child: UICGrid<UniqueKey>(
                onReorder: (oldIndex, newIndex) {
                  items.insert(newIndex, items.removeAt(oldIndex));
                },
                viewMode: UICGridViewMode.grid,
                items: items,
                builder: (context, item) => UICGridTile(
                  key: item,
                  // backgroundImage: const AssetImage("assets/images/devices/shutter.jpeg"),
                  backgroundImageOpacity: 0.5,
                  actions: [
                    UICGridTileAction(
                      onPressed: () {},
                      child: const Icon(Icons.wb_iridescent_rounded),
                    ),
                    
                    UICGridTileAction(
                      onPressed: () {},
                      style: UICColorScheme.success,
                      child: const Icon(Icons.thumb_up_rounded),
                    ),
                            
                    UICGridTileAction(
                      onPressed: () {},
                      style: UICColorScheme.warn,
                      tooltip: "Something unforseen happened",
                      child: const Icon(Icons.warning_rounded),
                    ),
                  ],
                  title: UICGridTileTitle(
                    title: Text("$item test test test test test test test test"),
                    leading: const Icon(Icons.ac_unit),
                  ),
                )
              ),
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
              setState(() => items.insert(3, UniqueKey()));
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
              setState(() => items.isNotEmpty ? items.removeAt(3) : null);
            },
            icon: const Icon(Icons.remove, size: 32),
          )
        )

      ],
    );
  }
}
