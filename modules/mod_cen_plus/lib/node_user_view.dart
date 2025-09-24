part of 'module.dart';

class CPNodeUserView extends StatefulWidget {
  static const basePath = '${CPHome.path}/node/user';
  static const path = '$basePath/:id';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final node = context.read<CentronicPlusNode>();
      return CustomTransitionPage(
        key: ValueKey("$path/${node.mac}"),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        child: CPNodeUserView(node: node),
      );
    }
  );

  static go(BuildContext context, CentronicPlusNode node) async {
    UICScaffold.of(context).showSecondaryBody();
    context.go('$basePath/${node.mac}');
  }

  final CentronicPlusNode node;

  const CPNodeUserView({
    super.key,
    required this.node,
  });

  @override
  State<CPNodeUserView> createState() => _CPNodeUserViewState();
}

class _CPNodeUserViewState extends State<CPNodeUserView> {
  late final CentronicPlusNode node = widget.node;
  late final CentronicPlus centronicPlus = context.read<CentronicPlus>();
  late final messenger = UICMessenger.of(context);
  late UICScaffoldState scaffold = UICScaffold.of(context);
  
  final GlobalKey<TooltipState> tipFlyScreen = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> tipAntiFreeze = GlobalKey<TooltipState>();
  
  bool macAssignActive = false;
  StreamSubscription? remoteSubscription;
  Completer<bool>? remoteButtonCompleter;

  @override
  initState() {
    super.initState();
    init();
  }

  void init () {
    if(!node.isRemote && !node.isBatteryPowered) {
      node.updateState();
      if(node.name == null) {
        node.updateInfo();
      }
    } else if(node.isRemote || node.isBatteryPowered) {
      remoteSubscription = node.simpleDigitalEvents.stream.listen(onRemoteButtonPressed);
    }
  }

  @override
  void dispose() {
    remoteSubscription?.cancel();
    super.dispose();
  }

  void onRemoteButtonPressed (CPRemoteActivity event) async {
    if(remoteButtonCompleter?.isCompleted == false) {
      remoteButtonCompleter?.complete(true);
    }

    if(node.name == null) {
      node.updateInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamProvider<CentronicPlusNode>.value(
      value: node.updateStream.stream,
      initialData: node,
      updateShouldNotify: (_, __) => true,
      builder: (context, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) async {
            node.unselect();
            scaffold.hideSecondaryBody();
          },
          canPop: false,
          child: Consumer<CentronicPlusNode>(
            builder: (context, node, _) {
              return UICPage(
                //Todo FIXME : the below lines.
                //showAppBar: false,
                //backgroundColor: theme.colorScheme.surfaceContainerLow,
                slivers: [
                  UICPinnedHeader(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 28),
                      tooltip: "Zurück".i18n,
                      onPressed: () {
                        node.unselect();
                        scaffold.hideSecondaryBody();
                      },
                    ),

                    trailing: !node.updating ? IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 28),
                      tooltip: "Geräteinformationen aktualisieren".i18n,
                      onPressed: () => node.updateInfo(),
                    ) : Padding(
                      padding: EdgeInsets.only(right: theme.defaultWhiteSpace),
                      child: UICProgressIndicator.small(),
                    ),
                  ),

                  UICConstrainedSliverList(
                    maxWidth: 400,
                    children: [
                      const UICSpacer(),
                      
                      CPNodeName(node: node, simpleMode: true,),

                      const UICSpacer(2),
                          
                      if(node.isSensor) const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UICSpacer(),
                          SensorValuesView(),
                          UICSpacer(),
                        ],
                      ),
                  
                      if(node.isSwitch || node.isLC120) Column(
                        children: [
                          const UICSpacer(4),
                          UICBigSwitch(
                            state: node.analogValues?.values["value"] == null ? null : node.analogValues?.values["value"]! > 0 ? true : false,
                            switchOn: () async {
                              node.sendUpCommand();
                              node.analogValues?.values["value"] = 100;
                              node.notifyListeners();
                            },
                            switchOff: () async {
                              node.sendStopCommand();
                              node.analogValues?.values["value"] = 0;
                              node.notifyListeners();
                            }
                          ),
                        ]
                      ),
                          
                      if(node.isSwitch || node.isLC120) const UICSpacer(),
                          
                      if(node.initiator == CPInitiator.actImpulseLight) Column(
                        children: [
                          const UICSpacer(4),
                          UICBigSwitch(
                            state: false,
                            switchOn: node.sendUpCommand,
                          ),
                        ]
                      ),
                  
                      if(node.initiator == CPInitiator.actImpulseLight) const UICSpacer(),
                  
                      if(node.isDrive) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(node.statusFlags.setupComplete == true && node.initiator != CPInitiator.actSwitchDim) Column(
                            spacing: theme.defaultWhiteSpace,
                            children: [
                              UICBigSlider(
                                value: node.analogValues?.values["value"] ?? 0,
                                onChangeEnd: (v) {
                                  node.sendPositionCommand(v);
                                },
                                onChanged: (v) => node.analogValues?.values["value"] = v,
                              ),
                              const Icon(Icons.swap_vert_rounded, size: 32),
                            ],
                          ),
                          
                          if(node.statusFlags.setupComplete == true && node.initiator != CPInitiator.actSwitchDim) const UICSpacer(2),
                          
                          Column(
                            spacing: theme.defaultWhiteSpace,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Opacity(
                                opacity: 0,
                                child: Text("0%")
                              ),
                              UICBigMove(
                                onUp: node.sendUpCommand,
                                onStop: node.sendStopCommand,
                                onDown: node.sendDownCommand,
                              ),
                          
                              const Icon(Icons.height_rounded, size: 32),
                            ],
                          ),
                  
                          if(node.statusFlags.setupComplete == true && node.initiator == CPInitiator.sunDriveJal) const UICSpacer(2),
                          
                          if(node.statusFlags.setupComplete == true && node.initiator == CPInitiator.sunDriveJal) Column(
                            spacing: theme.defaultWhiteSpace,
                            children: [
                              UICBigSlider(
                                width: 60,
                                value: node.analogValues?.values['slat'] ?? 0,
                                onChangeEnd: (slat) {
                                  node.sendSlatPositionCommand(slat);
                                },
                                onChanged: (v) => node.analogValues?.values['slat'] = v,
                              ),
                              const Icon(Icons.line_weight_rounded, size: 32,),
                            ],
                          ),

                        ],
                      ),

                      if(node.isDrive) const UICSpacer(),

                      if(node.isDrive) Center(
                        child: Text("Zwischenpositionen".i18n)
                      ),
                      
                      if(node.isDrive) const UICSpacer(),
                      
                      if(node.isDrive) Center(
                        child: SizedBox(
                          width: 110,
                          child: UICElevatedButton(
                            onPressed: () {
                              node.movePreset1();
                            },
                            child: const Icon(BeckerIcons.one, size: 16,)
                          ),
                        ),
                      ),
                  
                      if(node.isDrive) const UICSpacer(),
                    
                      if(node.isDrive) Center(
                        child: SizedBox(
                          width: 110,
                          child: UICElevatedButton(
                            onPressed: () {
                              node.movePreset2();
                            },
                            child: const Icon(BeckerIcons.two, size: 16,)
                          ),
                        ),
                      ),

                      const UICSpacer(4),

                      Center(
                        child: UICElevatedButton(
                          onPressed: () async {
                            final answer = await messenger.alert(UICSimpleConfirmationAlert(
                              title: "Ausblenden",
                              child: Text("Soll das Gerät ausgeblendet werden? Zuordnungen zu Gruppen und Uhren werden aufgehoben."),
                            ));
                        
                            if(answer == true) {
                              unawaited(centronicPlus.nodeUnassignGroupId(node));
                              node.remove();
                              scaffold.hideSecondaryBody();
                            }
                          },
                          leading: const Icon(Icons.visibility_off_rounded),
                          child: Text("Ausblenden".i18n),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        );
      }
    );
  }
}
