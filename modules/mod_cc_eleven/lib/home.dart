part of 'module.dart';

class CCElevenHome extends StatefulWidget {
  static const path = '/cc_eleven';

  static final route = GoRoute(
    path: CCElevenHome.path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: const CCElevenHome(),
    ),
  );

  static go (BuildContext context) {
    context.go(path);

  }

  const CCElevenHome({
    super.key,
  });

  @override
  State<CCElevenHome> createState() => _CCElevenHomeState();
}

class _CCElevenHomeState extends State<CCElevenHome> {
  late final cc = context.read<CCEleven>();
  late final cp = context.read<CentronicPlus>();
  late final store = cc.store;
  StreamSubscription<CCEleven>? subscription;

  @override
  void initState() {
    super.initState();
    unawaited(asyncInit());
  }

  Future<void> asyncInit() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      await cc.setTime(DateTime.now());
    } catch(e) {/* pass */}
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  bool visibleDevicesFilter(CentronicPlusNode node) => node.visible == true && !node.isCentral && !node.isRemote && !node.isSensor;
  bool visibleSensorsFilter(CentronicPlusNode node) => node.visible == true && !node.isCentral && node.isSensor;

  void startTeachin () async {
    final result = await CPTeachinAlert.open(context, true);
    if(result != null && result.isNotEmpty) {

      for(final node in result) {
        if(!node.isSensor && !node.isRemote && !node.isCentral && !node.isBatteryPowered) {
          await cp.stopReadAllNodes();
          unawaited(cp.nodeAssignGroupId(node));
          node.show();
        } else if(node.isSensor) {
          node.show();
        }
      }

      store.bulkStoreCpNodes(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffold = UICScaffold.of(context);

    return UICPage(
      padding: EdgeInsets.zero,
      slivers: [
        SliverMainAxisGroup(
          slivers: [
            UICPinnedHeader(
              pinned: false,
              floating: false,
              leading: IconButton.filledTonal(
                onPressed: () {
                  cc.closeEndpoint();
                },
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                icon: RotatedBox(
                  quarterTurns: 2,
                  child: const Icon(Icons.exit_to_app_rounded),
                ),
              ),

              trailing: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                      backgroundColor: theme.colorScheme.successVariant.primaryContainer,
                      foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
                      elevation: 2,
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text("Aktiv".i18n),
                        const UICSpacer(),
                        Icon(Icons.wb_sunny_outlined, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
                      ],
                    ),
                  ),

                  const UICSpacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                      backgroundColor: theme.colorScheme.successVariant.primaryContainer,
                      foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
                      elevation: 2,
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text("Aktiv".i18n),
                        const UICSpacer(),
                        Icon(Icons.access_time_rounded, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            UICPinnedHeader(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: UICTitle("Gruppen".i18n),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  elevation: 2,
                ),
                onPressed: () => CCElevenGroupView.go(context),
                child: Row(
                  children: [
                    Text("Neu".i18n),
                    UICSpacer(),
                    Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.onPrimaryContainer),
                  ],
                ),
              ),
            ),
            
            CCElevenGroupList(),
          ],
        ),

        SliverMainAxisGroup(
          slivers: [
            Consumer<CentronicPlus>(
              builder: (context, cp, _) {
                return UICPinnedHeader(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UICTitle("Meine Geräte".i18n),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      elevation: 2,
                    ),
                    onPressed: startTeachin,
                    child: Row(
                      children: [
                        Text("Hinzufügen".i18n),
                        UICSpacer(),
                        Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                );
              },
            ),

            Consumer<CentronicPlus>(
              builder: (context, cp, _) {
                final visibleDevices = cp.getOwnNodes().where(visibleDevicesFilter).toList();
                if (visibleDevices.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const UICSpacer(2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: startTeachin,
                              child: Text("Es sind noch keine Empfänger vorhanden.\nFügen Sie jetzt Ihren ersten Empfänger hinzu.".i18n, textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return CPOwnNodes(
                  showControls: true,
                  extraFilter: visibleDevicesFilter,
                );
              }
            ),
          ],
        ),
        
        SliverMainAxisGroup(
          slivers: [
            Consumer<CentronicPlus>(
              builder: (context, cp, _) {
                final visibleRemotes = cp.getOwnNodes().where(visibleSensorsFilter).toList();
                if (visibleRemotes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                
                return UICPinnedHeader(
                  height: 60.0,
                  leading: UICTitle("Sensoren".i18n),
                );
              },
            ),
            
            Consumer<CentronicPlus>(
              builder: (context, cp, _) {
                final visibleRemotes = cp.getOwnNodes().where(visibleSensorsFilter).toList();
                if (visibleRemotes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return CPOwnNodes(
                  showControls: true,
                  extraFilter: visibleSensorsFilter,
                );
              }
            ),
          ],
        ),
        
        // Sensoren section
      ],
    );
  }
}
