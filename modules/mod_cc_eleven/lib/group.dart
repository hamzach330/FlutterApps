part of 'module.dart';

class CCElevenGroupView extends StatefulWidget {
  static const path = '${CCElevenHome.path}/group/:id';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final isNew = state.pathParameters['id'] == 'new';
      final groupId = int.tryParse(state.pathParameters['id'] ?? '');
      return CustomTransitionPage(
        key: ValueKey('${CCElevenHome.path}/group/${groupId ?? 'new'}'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        child: CCElevenGroupView(isNew: isNew, groupId: groupId),
      );
    }
  );

  static void go (BuildContext context) {
    UICScaffold.of(context).showSecondaryBody();
    context.go("${CCElevenHome.path}/group/new");
  }

  static void goToGroup (BuildContext context, CCGroup group) {
    UICScaffold.of(context).showSecondaryBody();
    context.go("${CCElevenHome.path}/group/${group.id}");
  }

  final bool isNew;
  final int? groupId;

  const CCElevenGroupView({
    super.key,
    required this.isNew,
    this.groupId,
  });

  @override
  State<CCElevenGroupView> createState() => _CCElevenGroupViewState();
}

class _CCElevenGroupViewState extends State<CCElevenGroupView> {
  late final cp = context.read<CentronicPlus>();
  late final cc = context.read<CCEleven>();
  late final store = cc.store;
  List<CentronicPlusNode> selectedNodes = [];
  final nameController = TextEditingController();
  bool invalidName = false;
  int nextId = 0;
  CCGroup? group;
  bool isNew = false;

  _CCElevenGroupViewState();

  @override
  void initState() {
    super.initState();
    isNew = widget.isNew;
    unawaited(asyncInit());
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<CPAvailableCommands> availableCommands = [];

  Future<void> asyncInit() async {
    /// FIXME: This should really be handled in cc?
    final allGroups = cc.groups;
    if(isNew == false) {
      group = allGroups.firstWhereOrNull((g) => g.id == (widget.groupId ?? 1));
      if(group != null) {
        selectedNodes = cp.getNodesFrom64BitMask(group!.cpGroup);
        nameController.text = group!.name;
        nextId = group!.id;
        dev.log("BITMASK: ${group!.cpGroupAsInt}", name: "CCElevenGroupView.asyncInit");
      }
    } else {
      nameController.text = "";
      selectedNodes = [];
      nextId = findLowestUnusedId(allGroups);
      setState(() {});
      dev.log("New group ID $nextId", name: "CCElevenGroupView.asyncInit");
    }

    availableCommands = cc.getSharedCommands(selectedNodes);

    setState(() {});
  }

  int findLowestUnusedId(List<CCGroup> groups) {
    final allIds = groups.map((g) => g.id).toSet();
    int gId = 1;
    while (allIds.contains(gId)) {
      gId++;
    }
    return gId;
  }

  Future<void> save() async {
    final scaffold = UICScaffold.of(context);

    final group = CCGroup(
      cpGroup: cp.getPage64FromGroupIds(selectedNodes.map((node) => node.groupId).toList()),
      cGroup: [0],
      id: nextId,
      name: nameController.text.trim()
    );

    final success = await store.storeGroup(
      cpGroup: group.cpGroup,
      cGroup: group.cGroup,
      id: group.id,
      name: group.name
    );

    if(isNew) {
      cc.groups.add(group);
      isNew = false;
    } else {
      cc.groups
        ..removeWhere((g) => g.id == group.id)
        ..add(group);
    }

    cc.notifyListeners();

    if(success) {
      scaffold.hideSecondaryBody();
    }

    dev.log("Storing group returned: $success", name: "CCElevenGroupView.save");
  }

  void _checkName(String v) {
    setState(() {
      try {
        Mutators.fromUtf8String(nameController.text, 32);
        invalidName = false;
      } catch (e) {
        invalidName = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      //Todo : FIXME : the pop functionality.
      //pop: () => UICScaffold.of(context).hideSecondaryBody(),
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            tooltip: "Zurück".i18n,
            onPressed: () {
              UICScaffold.of(context).hideSecondaryBody();
            },
          ),
          // body: UICTitle(isNew ? "Gruppe anlegen".i18n : "Gruppe bearbeiten".i18n, crossAxisAlignment: CrossAxisAlignment.center),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
              backgroundColor: theme.colorScheme.successVariant.primaryContainer,
              foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
            ),
            onPressed: save,
            child: Row(
              children: [
                Text("Speichern".i18n),
                const UICSpacer(),
                Icon(Icons.save_rounded, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
              ],
            ),
          ),
        ),

        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UICSpacer(),

                UICBigName(
                  initialValue: nameController.text,
                  placeholder: "Unbenannte Gruppe".i18n,
                  onEditingComplete: (v) => nameController.text = v,
                  onChanged: (v) => nameController.text = v,
                ),

                if(availableCommands.isNotEmpty) const UICSpacer(4),
                if(availableCommands.isNotEmpty) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(availableCommands.contains(CPAvailableCommands.up) && availableCommands.contains(CPAvailableCommands.down) && availableCommands.contains(CPAvailableCommands.stop)) UICBigMove(
                      onUp: () {
                        final pageData = cp.getPage32FromPage64(group?.cpGroup ?? List.filled(8, 0));
                        for(final groupCode in pageData) {
                          cp.multicast.sendUpCommand(group: groupCode);
                        }
                      },
                      onStop: () {
                        final pageData = cp.getPage32FromPage64(group?.cpGroup ?? List.filled(8, 0));
                        for(final groupCode in pageData) {
                          cp.multicast.sendStopCommand(group: groupCode);
                        }
                      },
                      onDown: () {
                        final pageData = cp.getPage32FromPage64(group?.cpGroup ?? List.filled(8, 0));
                        for(final groupCode in pageData) {
                          cp.multicast.sendDownCommand(group: groupCode);
                        }
                      },
                    ),
                    if(availableCommands.contains(CPAvailableCommands.on) && availableCommands.contains(CPAvailableCommands.off)) UICBigSwitch(
                      switchOn: () async {
                        final pageData = cp.getPage32FromPage64(group?.cpGroup ?? List.filled(8, 0));
                        for(final groupCode in pageData) {
                          cp.multicast.sendUpCommand(group: groupCode);
                        }
                      },
                      switchOff: () async {
                        final pageData = cp.getPage32FromPage64(group?.cpGroup ?? List.filled(8, 0));
                        for(final groupCode in pageData) {
                          cp.multicast.sendStopCommand(group: groupCode);
                        }
                      }
                    ),
                  ],
                ),

                if(availableCommands.isNotEmpty) const UICSpacer(4),

                Row(
                  children: [
                    Text("Empfänger".i18n, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        elevation: 2,
                      ),
                      onPressed: () async {
                        cp.unselectNodes();
                        selectedNodes = await UICMessenger.of(context).alert(CCElevenSelectDevices(
                          centronicPlus: cp,
                          selection: selectedNodes,
                        )) ?? [];
                        availableCommands = cc.getSharedCommands(selectedNodes);
                        setState((){});
                      },
                      child: Row(
                        children: [
                          Text("Auswahl".i18n),
                          const UICSpacer(),
                          Icon(Icons.list_alt, size: 16, color: theme.colorScheme.onPrimaryContainer),
                        ],
                      ),
                    ),

                  ],
                ),

                UICSpacer(),
                
                Column(
                  spacing: theme.defaultWhiteSpace,
                  children: [
                    for(final node in selectedNodes) Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(theme.defaultWhiteSpace * 1.5),
                        border: Border.all(color: theme.colorScheme.secondary, width: 1.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(theme.defaultWhiteSpace),
                        child: Row(
                          children: [
                            node.getIcon(theme.colorScheme.secondary),
                            const UICSpacer(),
                            Text(node.name ?? node.mac),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),

            const UICSpacer(),
            
            if(!isNew) const UICSpacer(4),

            if(!isNew) Center(
              child: UICElevatedButton(
                onPressed: () async {
                  final answer = await  UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
                    title: "Gruppe löschen".i18n,
                    child: Text("Möchten Sie %s wirklich löschen?".i18n.fill([group?.name ?? ""])),
                  ));
              
                  if(answer == true) {
                    await cc.store.removeGroupById([...List.filled(7,0), group?.id ?? 0]);
                    cc.groups.removeWhere((g) => g.id == group?.id);
                    cc.notifyListeners();
                  }
                },
                leading: const Icon(Icons.remove_circle_outline_rounded),
                child: Text("Gruppe löschen".i18n),
              ),
            ),
          ],
        )
      ],
    );
  }
}
