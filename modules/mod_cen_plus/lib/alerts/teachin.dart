part of '../module.dart';

class CPTeachinAlert extends UICAlert<List<CentronicPlusNode>> {
  static Future<List<CentronicPlusNode>?> open(BuildContext context, bool showOwnNodes) async {
    return await UICMessenger.of(context).alert(CPTeachinAlert(
      centronicPlus: Provider.of<CentronicPlus>(context, listen: false),
      extendedSettings: Provider.of<CPExpandSettings>(context, listen: false).expand,
      showOwnNodes: showOwnNodes,
    ));
  }

  final CentronicPlus centronicPlus;
  final bool extendedSettings;
  final bool showOwnNodes;
  final List<CentronicPlusNode> nodes = [];

  CPTeachinAlert({
    super.key,
    required this.centronicPlus,
    required this.extendedSettings,
    required this.showOwnNodes,
  });
  
  @override
  get title => "Empfänger hinzufügen".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 500;

  @override
  get backdrop => true;

  @override
  get dismissable => true;

  @override
  get closeAction => () {
    unawaited(centronicPlus.stopReadAllNodes());
    pop(nodes);
  };
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: centronicPlus.updateStream.stream,
          initialData: centronicPlus,
          updateShouldNotify: (_, __) => true,
        ),
      ],
      builder: (context, _) {
        return _TeachinPopover(
          addNode: (node) {
            nodes.add(node);
          },
          removeNode: (node) {
            nodes.remove(node);
          },
          showOwnNodes: showOwnNodes,
        );
      }
    );
  }
}

class _TeachinPopover extends StatefulWidget {
  final bool showOwnNodes;
  final Function(CentronicPlusNode) addNode;
  final Function(CentronicPlusNode) removeNode;

  const _TeachinPopover({
    required this.showOwnNodes,
    required this.addNode,
    required this.removeNode,
  });

  @override
  State<_TeachinPopover> createState() => _TeachinPopoverState();
}

class _TeachinPopoverState extends State<_TeachinPopover> {
  late final CentronicPlus centronicPlus;
  late final messenger = UICMessenger.of(context);
  final foreignNodesScrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    centronicPlus = context.read<CentronicPlus>();
    unawaited(asyncInit());
  }

  Future<void> asyncInit() async {
    centronicPlus.unselectNodes();

    unawaited(centronicPlus.readAllNodes());
    await Future.delayed(Duration(milliseconds: 500));
    unawaited(centronicPlus.updateMesh());

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      unawaited(centronicPlus.updateMesh());
    });
    
    centronicPlus.unselectNodes();
  }

  @override
  void dispose() {
    super.dispose();
    centronicPlus.notifyListeners();
    _timer?.cancel();
  }

  bool nodeFilter(CentronicPlusNode node) => node.visible == false && !node.isCentral && !node.isRemote;

  @override
  Widget build(BuildContext context) {
    return Consumer<CentronicPlus>(
      builder: (context, centronicPlus, _) {
        final theme = Theme.of(context);
        final filteredNodes = centronicPlus.getOwnNodes().where(nodeFilter);
        final foreignNetworks = centronicPlus.getForeignNetworks("");

        return CustomScrollView(
          primary: false,
          shrinkWrap: true,
          controller: foreignNodesScrollController,
          slivers: [
            if(widget.showOwnNodes) SliverMainAxisGroup(
              slivers: [
                if(filteredNodes.isNotEmpty) SliverPadding(
                  padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
                  sliver: SliverToBoxAdapter(
                    child: Text("Eigene Geräte".i18n, style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                    ), textAlign: TextAlign.start,),
                  ),
                ),
                if(filteredNodes.isNotEmpty) CPOwnNodes(
                  padding: EdgeInsets.zero,
                  showControls: true,
                  extraFilter: nodeFilter,
                  onSelect: (node) async {
                    if(node.selected) {
                      node.unselect();
                      widget.removeNode(node);
                      return;
                    }
                    node.select();
                    widget.addNode(node);
                    centronicPlus.notifyListeners();
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.only(
                bottom: theme.defaultWhiteSpace,
              )
            ),

            if(foreignNetworks.isEmpty) SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: filteredNodes.isEmpty ? 0 : theme.defaultWhiteSpace * 4),
                    child: Center(
                      child: UICProgressIndicator(
                        // color: theme.colorScheme.onTertiaryContainer,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                    child: Center(
                      child:
                        filteredNodes.isNotEmpty ?
                        Text("Suche weitere Geräte".i18n, textAlign: TextAlign.center) :
                        Text("Es wurden noch keine Geräte entdeckt".i18n, textAlign: TextAlign.center)
                    ),
                  ),
                ),
              ],
            ),
        
            for(final panId in foreignNetworks.keys) SliverMainAxisGroup(
              slivers: [
                DecoratedSliver(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(theme.defaultWhiteSpace * 2),
                  ),  
                  sliver: SliverPadding(
                    padding: EdgeInsets.all(theme.defaultWhiteSpace),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: foreignNetworks[panId]?.where((node) => node.coupled == true).isNotEmpty == true ? 
                            Padding(
                              padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
                              child: Text("${"Installation:".i18n} $panId", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
                            ) : 
                            Padding(
                              padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
                              child: Text("Werkszustand".i18n, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
                            )
                        ),
                        SliverGrid(
                          delegate: SliverChildBuilderDelegate((context, index) {
                              final node = foreignNetworks[panId]?[index];
                              if(node == null) return const SizedBox.shrink();
                              return CPForeignNodeTile(
                                key: ValueKey("set_couple_${node.mac}"),
                                node: node,
                              );
                            },
                            childCount: (foreignNetworks[panId]?.length ?? 0),
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: theme.defaultWhiteSpace,
                            crossAxisSpacing: theme.defaultWhiteSpace,
                            childAspectRatio: 4/3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: theme.defaultWhiteSpace * 2,
                  )
                ),
              ],
            ),

            if(foreignNetworks.isNotEmpty && centronicPlus.discovery) SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(theme.defaultWhiteSpace),
                    child: Center(
                      child: UICProgressIndicator(
                        color: theme.colorScheme.onTertiaryContainer,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(theme.defaultWhiteSpace),
                    child: Center(
                      child: Text("Suche weitere Geräte".i18n, textAlign: TextAlign.center)
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      }
    );
  }
}
