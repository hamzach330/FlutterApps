part of '../module.dart';

class CPForeignNodes extends StatefulWidget {

  const CPForeignNodes({super.key});

  @override
  State<CPForeignNodes> createState() => _CPForeignNodesState();
}

class _CPForeignNodesState extends State<CPForeignNodes> {
  final foreignNodesScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CentronicPlus>(
      builder: (context, centronicPlus, _) {
        final foreignNetworks = centronicPlus.getForeignNetworks("");
        return Column(
          children: [
            if(!centronicPlus.discovery) Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: UICElevatedButton(
                style: UICColorScheme.success,
                onPressed: () async => await centronicPlus.readAllNodes(),
                trailing: const Icon(Icons.add_box_rounded),
                child: Text("Neue Geräte finden und hinzufügen".i18n),
              ),
            ),

            if(centronicPlus.discovery) Padding(
              padding: EdgeInsets.only(
                top: theme.defaultWhiteSpace,
                left: theme.defaultWhiteSpace,
                right: theme.defaultWhiteSpace,
              ),
              child: UICElevatedButton(
                style: UICColorScheme.warn,
                onPressed: () async => await centronicPlus.stopReadAllNodes(),
                trailing: const Icon(Icons.close_rounded),
                leading: UICProgressIndicator(color: theme.colorScheme.warnVariant.onPrimaryContainer,),
                child: Text("Hinzufügen beenden".i18n),
              )
            ),

            // if(centronicPlus.discovery) const UICSpacer(),

            if(centronicPlus.discovery) Container(
              margin: EdgeInsets.all(theme.defaultWhiteSpace),
              clipBehavior: Clip.antiAlias,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(theme.defaultWhiteSpace * 3)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(foreignNetworks.isEmpty) Padding(
                    padding: EdgeInsets.all(theme.defaultWhiteSpace),
                    child: Center(
                      child: Text("Es wurden noch keine Geräte entdeckt".i18n, textAlign: TextAlign.center, style: TextStyle(
                        color: theme.colorScheme.warnVariant.primary
                      ))
                    ),
                  ),
                  if(foreignNetworks.isNotEmpty) Theme(
                    data: theme.copyWith(
                      scrollbarTheme: const ScrollbarThemeData(
                        trackVisibility: WidgetStatePropertyAll(true),
                        thumbVisibility: WidgetStatePropertyAll(true),
                      )
                    ),
                    child: Scrollbar(
                      thumbVisibility: false,
                      trackVisibility: false,
                      controller: foreignNodesScrollController,
                      child: Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent) {
                            foreignNodesScrollController.jumpTo(foreignNodesScrollController.offset + event.scrollDelta.dy);
                          }
                        },
                      
                        child: SingleChildScrollView(
                          controller: foreignNodesScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: theme.defaultWhiteSpace,
                              top: theme.defaultWhiteSpace,
                              bottom: theme.defaultWhiteSpace
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for(final panId in foreignNetworks.keys) Container(
                                  padding: EdgeInsets.only(
                                    right: theme.defaultWhiteSpace,
                                    bottom: theme.defaultWhiteSpace
                                  ),
                                  margin: EdgeInsets.only(left: theme.defaultWhiteSpace),
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: theme.colorScheme.surface, width: 2),
                                    borderRadius: BorderRadius.circular(theme.defaultWhiteSpace * 2),
                                    color: theme.colorScheme.surface,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: theme.defaultWhiteSpace * 2,
                                          top: theme.defaultWhiteSpace / 2,
                                          bottom: theme.defaultWhiteSpace / 2,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: 
                                            foreignNetworks[panId]?.where((node) => node.coupled == true).isNotEmpty == true ? [
                                              Text("Installation:".i18n, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
                                              Text(" $panId", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
                                            ] : [
                                              Text("Werkszustand".i18n, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer))
                                            ]
                                        )
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for(final node in foreignNetworks[panId] ?? <CentronicPlusNode>[]) CPForeignNodeTile(
                                            node: node,
                                            key: Key(node.mac)
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        );
      }
    );

  }
}
