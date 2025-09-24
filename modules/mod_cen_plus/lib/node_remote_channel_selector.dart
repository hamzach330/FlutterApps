part of 'module.dart';

class CPRemoteChannelSelector extends StatefulWidget {
  static const pathName = 'channel_selector';
  static const path = '${CPNodeAdminView.basePath}/:id/$pathName';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: const CPRemoteChannelSelector(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const CPRemoteChannelSelector({super.key});

  @override
  State<CPRemoteChannelSelector> createState() => _CPRemoteChannelSelectorState();
}

class _CPRemoteChannelSelectorState extends State<CPRemoteChannelSelector> {
  CentronicPlusNode get remote => Provider.of<CentronicPlus>(context, listen: false).nodes.firstWhereOrNull((element) => element.mac == GoRouterState.of(context).pathParameters['id'])!;
  CentronicPlus get centronicPlus => remote.cp;
  final List<CentronicPlusNode> selection = [];

  final colorRanges = {
    Colors.green:  [0, 3],
    Colors.red:    [4, 7],
    Colors.yellow: [8, 11],
    Colors.blue:   [12, 16],
  };

  Color wheelColor = Colors.green;
  int wheelSegment = 0;

  void getColorForChannel (int channel) {
    for(final entry in colorRanges.entries) {
      if(channel >= entry.value[0] && channel <= entry.value[1]) {
        wheelColor = entry.key;
        wheelSegment = channel % 4;
        return;
      }
    }

    wheelColor = colorRanges.entries.first.key;
    wheelSegment = channel % 4;
  }
  
  late final messenger = UICMessenger.of(context);
  late final scaffold = UICScaffold.of(context);
  late final navigator = Navigator.of(context);

  StreamSubscription? buttonEvents;
  int selectedChannel = 0;


  Map<int, List<CentronicPlusNode>> macAssignment = {};
  List<CentronicPlusNode> removedNodes = [];
  List<CentronicPlusNode> changedNodes = [];

  Completer<bool>? confirmCompleter;

  String? nodeId;

  @override
  initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      buttonEvents = remote.simpleDigitalEvents.stream.listen(onRemoteButtonPressed);
      await readChannelAssignment();
      startChannelAssign();
    });
  }

  @override
  dispose() {
    buttonEvents?.cancel();
    super.dispose();
  }

  void onRemoteButtonPressed (CPRemoteActivity event) {
    confirmCompleter?.complete(true);
    confirmCompleter = null;
  }

  void _onSelect (CentronicPlusNode node) {
    macAssignment.putIfAbsent(selectedChannel, () => []);

    if(changedNodes.contains(node) == false) {
      changedNodes.add(node);
    }

    if((macAssignment[selectedChannel]?.contains(node) ?? false) == false) {
      macAssignment[selectedChannel]?.add(node);
    } else {
      macAssignment[selectedChannel]?.remove(node);
    }

    selection..clear()..addAll(macAssignment[selectedChannel] ?? []);
    setState(() {});
  }

  Future<void> readChannelAssignment () async {
    await centronicPlus.stopReadAllNodes();
    macAssignment = await remote.loadGroups();
  }

  Future<void> startChannelAssign () async {
    await centronicPlus.stopReadAllNodes();

    final currentChannelAssignment = macAssignment[selectedChannel] ?? [];
    selection..clear()..addAll(currentChannelAssignment);

    setState(() {});
  }

  Future<bool?> abort () async {
    if(changedNodes.isNotEmpty) {
      return await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
        title: "Ungespeicherte Änderungen".i18n,
        child: Text("Sollen die Änderungen gespeichert werden?".i18n)
      ));
    }
    return false;
  }

  save() async {
    OverlayEntry? barrier;
    if(remote.isBatteryPowered) {
      confirmCompleter = Completer<bool>();
      barrier = await messenger.createBarrier(
        title: "Warte auf Handsender".i18n,
        abortable: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text("Drücken Sie jetzt eine Taste an Ihrem Handsender".i18n),
        ),
        onAbort: () {
          confirmCompleter?.complete(false);
          confirmCompleter = null;
        }
      );
      
      final result = await confirmCompleter?.future;
      barrier?.remove();

      if(result == false) {
        return;
      }

      barrier = await messenger.createBarrier(
        title: "Speichern".i18n,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text("Die Handsenderkonfiguration wird gespeichert. Dies kann einen Moment in Anspruch nehmen.".i18n),
        )
      );
    }

    for(final node in changedNodes) {
      final assignedChannels = macAssignment.entries
        .where((entry) => entry.value.contains(node))
        .map((entry) => entry.key)
        .toList();

      if(assignedChannels.isEmpty) {
        await node.unassignGroups(remote);
        await remote.unassignGroups(node);
      } else {
        await node.assignGroups(remote, assignedChannels);
        await remote.assignGroups(node, assignedChannels);
      }
    }

    changedNodes.clear();
    barrier?.remove();
  }

  void pop () async {
    final navigator = Navigator.of(context);
    bool? answer = await abort();

    if(answer == true) {
      await save();
    }

    if(context.mounted) {
      navigator.pop();
    }
  }

  Future close (BuildContext context) async {
    final scaffold = UICScaffold.of(context);
    bool? answer = await abort();

    if(answer == true) {
      await save();
    }

    scaffold.hideSecondaryBody();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = Provider.of<CentronicPlusNode>(context, listen: true);
    final items = centronicPlus.getOwnNodes().where((node) => node.isDrive || node.isLightControl || node.isSwitch || node.isVarioControl);

    return UICPage(
      // backgroundColor: theme.colorScheme.surfaceContainerLow,
      // appBarActions: [
      //   ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
      //       backgroundColor: theme.colorScheme.successVariant.primaryContainer,
      //       foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
      //     ),
      //     onPressed: save,
      //     child: Row(
      //       children: [
      //         Text("Speichern".i18n),
      //         const UICSpacer(),
      //         Icon(Icons.save_rounded, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
      //       ],
      //     ),
      //   ),

      //   const UICSpacer(),
      // ],
      // pop: pop,
      // close: close,
      // title: "Kanalbelegung".i18n, -> added 
      loading: node.loading,
      slivers: [

        //Todo FIXME : Empty Header figure out the above code as well.
        UICPinnedHeader(
          leading: UICTitle("Kanalbelegung".i18n),
          body: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: theme.defaultWhiteSpace * 1.5,
                vertical: theme.defaultWhiteSpace,
              ),
              backgroundColor:
                  theme.colorScheme.successVariant.primaryContainer,
              foregroundColor:
                  theme.colorScheme.successVariant.onPrimaryContainer,
            ),
            onPressed: save,
            child: Row(
              children: [
                Text("Speichern".i18n),
                const UICSpacer(),
                Icon(
                  Icons.save_rounded,
                  size: 16,
                  color: theme.colorScheme.successVariant.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              if(node.isSensor) const UICSpacer(),

              if(node.isSensor) Text("Um einen Sensor zuzuordnen oder eine bestehende Zuordnung zu löschen, tippen Sie bitte das gewünschte Gerät an.".i18n, textAlign: TextAlign.center,),
              
              if(node.isSensor) const UICSpacer(),
        
              if(!node.isSensor) Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  UICGridTileAction(
                    child: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => setState(() {
                      selectedChannel = max(selectedChannel - 1, 0);
                      getColorForChannel(selectedChannel);
                      startChannelAssign();
                    }),
                  ),
        
                  const UICSpacer(),
        
                  DropdownMenu<int?>(
                    width: 100,
                    label: Text("Kanal".i18n),
                    // alignmentOffset: getDropdownPosition(),
                    initialSelection: selectedChannel,
                    onSelected: (int? channel) async {
                      setState(() {
                        selectedChannel = channel ?? 0;
                        getColorForChannel(selectedChannel);
                        startChannelAssign();
                      });
                    },
                    dropdownMenuEntries: [
                      for(int i = 0; i < remote.remoteChannelCount; i++) DropdownMenuEntry<int>(
                        value: i,
                        label: (i + 1).toString()
                      )
                    ]
                  ),
        
                  const UICSpacer(),
        
                  UICGridTileAction(
                    child: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => setState(() {
                      selectedChannel = min(selectedChannel + 1, remote.remoteChannelCount - 1);
                      getColorForChannel(selectedChannel);
                      startChannelAssign();
                    }),
                  ),

                  const UICSpacer(3),
        
                  CPChannelSelector(
                    repeat: false,
                    segment: wheelSegment,
                    gradient: [
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      Colors.grey.shade900,
                      wheelColor,
                      wheelColor,
                      Colors.grey.shade900,
                    ],
                  ),

                ],
              ),
            ]
          )
        ),

        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return StreamProvider.value(
              key: ValueKey(("assign_${node.mac}")),
              updateShouldNotify: (_, __) => true,
              initialData: items.elementAt(index),
              value: items.elementAt(index).updateStream.stream,
              builder: (context, _) {
                return Consumer<CentronicPlusNode>(
                  builder: (context, node, _) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
                      child: UICGridTile(
                        viewMode: UICGridViewMode.list,
                        opacity: (selection.contains(node) == false) || node.online == false ? 0.5 : 1,
                        borderWidth: (selection.contains(node)) ? 4 : 2,
                        borderColor: (selection.contains(node)) ? theme.colorScheme.successVariant.primaryContainer : null,
                        onTap: () => _onSelect(node),
                        title: UICGridTileTitle(
                          leading: node.getIcon(),
                          title: Text(node.name ?? node.mac),
                        ),
                        backgroundImage: DecorationImage(
                          alignment: Alignment.center,
                          opacity: .75,
                          fit: BoxFit.cover,
                          image: node.getImage(),
                        ),
                        actions: [
                          if(!node.isBatteryPowered) UICGridTileAction(
                            style: UICColorScheme.variant,
                            onPressed: node.identify,
                            tooltip: "Gerät identifizieren".i18n,
                            child: const Icon(Icons.wb_iridescent_rounded),
                          )
                          else if(node.indicateActivity == null) const SizedBox(width: 44, height: 44),
                              
                          if(node.indicateActivity == CPRemoteActivity.stop) UICGridTileAction(
                            style: UICColorScheme.success,
                            child: const Icon(Icons.stop_rounded),
                          ),
                                  
                          if(node.indicateActivity == CPRemoteActivity.up) UICGridTileAction(
                            style: UICColorScheme.success,
                            child: Transform.scale(
                              scale: 2,
                              child: const RotatedBox(
                                quarterTurns: 2,
                                child: Icon(Icons.arrow_drop_down_rounded)
                              ),
                            ),
                          ),
                          
                          if(node.indicateActivity == CPRemoteActivity.down) UICGridTileAction(
                            style: UICColorScheme.success,
                            child: Transform.scale(
                              scale: 2,
                              child: const Icon(Icons.arrow_drop_down_rounded))
                          ),
                      
                          if(node.wantsAttention) const CPNodeStatusIcon(),
                      
                          if(node.loading) UICGridTileAction(
                            style: UICColorScheme.variant,
                            child: UICProgressIndicator(color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ]
                      ),
                    );
                  }
                );
              }
            );
          },
        ),
      ]
    );
  }
}
