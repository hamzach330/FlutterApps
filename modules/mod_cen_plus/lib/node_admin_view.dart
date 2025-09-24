part of 'module.dart';

class CPNodeAdminView extends StatefulWidget {
  static const basePath = '${CPHome.path}/node/admin';
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
        child: CPNodeAdminView(node: node),
      );
    }
  );

  static go(BuildContext context, CentronicPlusNode node) async {
    UICScaffold.of(context).showSecondaryBody();
    context.go('$basePath/${node.mac}');
  }

  final CentronicPlusNode node;

  const CPNodeAdminView({
    super.key,
    required this.node,
  });

  @override
  State<CPNodeAdminView> createState() => _CPNodeAdminViewState();
}

class _CPNodeAdminViewState extends State<CPNodeAdminView> {
  late final CentronicPlusNode node;
  late final CentronicPlus centronicPlus = context.read<CentronicPlus>();
  late final UICScaffoldState scaffold = UICScaffold.of(context);
  late final CPExpandSettings extendedSettings = context.read<CPExpandSettings>();
  late final messenger = UICMessenger.of(context);

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

  void init () async {
    node = widget.node;
    if(!node.isRemote && !node.isBatteryPowered) {
      // if(node.name == null) {
      //   await node.updateInfo();
      // }
      node.updateState();
    } else if(node.isBatteryPowered) {
      remoteSubscription?.cancel();
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

    if(node.name == null || node.readError) {
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
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          node.unselect();
          scaffold.hideSecondaryBody();
        },
        canPop: false,
        child: UICPage(
          // backgroundColor: theme.colorScheme.surfaceContainerLow,
          // close: (context) {
          //   scaffold.hideSecondaryBody();
          // },
          // pop: () => Navigator.of(context).maybePop(),
          // appBarActions: [
          //   if(!node.isCentral && !node.isBatteryPowered) IconButton(
          //     icon: const Icon(Icons.wb_iridescent_outlined, size: 28),
          //     tooltip: "Gerät identifizieren".i18n,
          //     onPressed: () => node.identify(),
          //   ) else Container(),
          //   Selector<CentronicPlusNode, bool>(
          //     selector: (_, node) => node.loading || node.updating,
          //     builder: (context, loading, __) {
          //       return Padding(
          //         padding: const EdgeInsets.only(right: 8.0),
          //         child: IconButton(
          //           icon: node.loading || node.updating
          //             ? UICProgressIndicator(size: 14,)
          //             : const Icon(Icons.refresh_rounded, size: 28),
          //           tooltip: "Geräteinformationen aktualisieren".i18n,
          //           onPressed: () => node.updateInfo(),
          //         ),
          //       );
          //     }
          //   ),
          // ],
          // title: "Einstellungen".i18n,
          slivers: [
            UICPinnedHeader(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              body: UICTitle("Einstellungen".i18n),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(!node.isCentral && !node.isBatteryPowered)
                    IconButton(
                      icon: const Icon(Icons.wb_iridescent_outlined, size: 28),
                      tooltip: "Gerät identifizieren".i18n,
                      onPressed: () => node.identify(),
                    ),
                  Selector<CentronicPlusNode, bool>(
                    selector: (_, node) => node.loading || node.updating,
                    builder: (context, loading, __) {
                      return IconButton(
                        icon: loading
                          ? UICProgressIndicator(size: 14)
                          : const Icon(Icons.refresh_rounded, size: 28),
                        tooltip: "Geräteinformationen aktualisieren".i18n,
                        onPressed: () => node.updateInfo(),
                      );
                    }
                  ),
                ],
              ),
            ),
            Consumer<CentronicPlusNode>(
              builder: (context, node, _) {
                return UICConstrainedSliverList(
                  maxWidth: 400,
                  children: [
                    const CPNodeInfo(),

                    // if(extendedSettings.expand) const UICSpacer(),
                    // if(extendedSettings.expand) RssiGraphWidget(),
                    
                    const CPNodeStatus(),

                    const UICSpacer(),

                    if(node.isSensor) const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SensorValuesView(),
                      ],
                    ),
                
                    if(node.isSwitch || node.isLC120) Column(
                      children: [
                        const UICSpacer(),
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
                    if(node.isSwitch || node.isLC120) const Divider(),
      
                    if(node.initiator == CPInitiator.actImpulseLight) Column(
                      children: [
                        Text("Bedienung".i18n, style: theme.bodyLargeMuted),
                        const UICSpacer(),
                        UICBigSwitch(
                          state: false,
                          switchOn: node.sendUpCommand,
                        ),
                      ]
                    ),
                
                    if(node.initiator == CPInitiator.actImpulseLight) const UICSpacer(),
                    if(node.initiator == CPInitiator.actImpulseLight) const Divider(),
                
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
      
                        if(node.statusFlags.setupComplete == true && node.initiator != CPInitiator.actSwitchDim) const UICSpacer(),
                        
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
                
                        if(node.statusFlags.setupComplete == true && node.initiator == CPInitiator.sunDriveJal) const UICSpacer(),
      
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
                            const Icon(Icons.line_weight_rounded, size: 32),
                          ],
                        ),
                      ],
                    ),
                
                    if(node.isDrive) const UICSpacer(),
                    if(node.isDrive) const Divider(),
                
                    if((node.isDrive && node.supportsSpecialFunctions) || node.isVC180) Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          key: tipFlyScreen,
                          triggerMode: TooltipTriggerMode.manual,
                          showDuration: const Duration(seconds: 0),
                          message: node.isVC180
                            ? "Schaltet die Geräte-LED dauerhaft ein um nachts eine Orientierung im Raum zu ermöglichen.".i18n
                            : !node.isFlyScreenProtected
                            ? "Aktivierbar, wenn die obere Endlage auf Anschlag eingestellt ist. Bei erreichen der oberen Endlage wird die Bremse kurz geöffnet um eine dauerhafte Belastung des Behangs zu verhindern.".i18n
                            : "Der Antrieb reagiert im oberen Bereich des Verfahrwegs deutlich früher auf Hindernisse. So wird die Beschädigung von Insektenschutztüren verhindert, die unmittelbar unter der oberen Endlage montiert sind.".i18n,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.info, color: theme.colorScheme.secondary),
                          ),
                        ),
                        if(node.isVC180) Expanded(child: Text("Nachtlicht".i18n))
                        else if(!node.isFlyScreenProtected) Expanded(child: Text("Tuchentlastung".i18n))
                        else Expanded(child: Text("Fliegengitterschutz".i18n)),
                        
                        UICSwitch(
                          // enabled: node.statusFlags.inUpperEndPosition == true,
                          value: node.statusFlags.flyScreenEnabled,
                          onChanged: () {
                            node.setEnableFlyscreen();
                          }
                        ),
                      ],
                    ),
                              
                    if((node.isDrive && node.supportsSpecialFunctions) || node.isVC180) const UICSpacer(),
                    if((node.isDrive && node.supportsSpecialFunctions) || node.isVC180) Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          key: tipAntiFreeze,
                          triggerMode: TooltipTriggerMode.manual,
                          showDuration: const Duration(seconds: 0),
                          message: node.isVC180
                            ? "Zeigt den aktuellen Schaltzustand (ein/aus) über die Geräte-LED an.".i18n
                            : !node.isFlyScreenProtected
                            ? "Den gewünschten Reversierpunkt anfahren und die Funktion aktivieren um den Antrieb automatisch nach Erreichen der Endlage in die programmierte Position zurückfahren lassen. Zum Löschen die Funktion in der Reversierposition stehend wieder deaktivieren.".i18n
                            : "Aktivierbar, wenn die obere Endlage auf Anschlag eingestellt ist. Der Behang fährt nicht gegen den oberen Anschlag, sondern bleibt kurz vorher stehen um ein Anfrieren (bspw. bei Verwendung einer Winkelendleiste) zu verhindern.".i18n,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.info, color: theme.colorScheme.secondary),
                          ),
                        ),
                              
                        if(node.isVC180) Expanded(child: Text("Status LED".i18n))
                        else if(!node.isFlyScreenProtected) Expanded(child: Text("Automatische Tuchspannung".i18n))
                        else Expanded(child: Text("Festfrierschutz".i18n)),
                        
                        UICSwitch(
                          // enabled: node.statusFlags.inUpperEndPosition == true,   
                          value: node.statusFlags.freezeProtectEnabled,
                          onChanged: () {
                            node.setEnableFrost();
                          }
                        ),
                      ],
                    ),
                    
                    if((node.isDrive && node.supportsSpecialFunctions) || node.isVC180) const Divider(),
                    if((node.isDrive && node.supportsSpecialFunctions) || (node.isVarioControl && node.isDrive)) Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          triggerMode: TooltipTriggerMode.longPress,
                          showDuration: const Duration(seconds: 0),
                          message: "Aktiviert oder deaktiviert die automatische Sonnenschutzüberwachung. Das gewählte Gerät muss mit einem entsprechenden Sensor verbunden sein.".i18n,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.info, color: theme.colorScheme.secondary),
                          ),
                        ),
                              
                        Expanded(child: Text("Sonnenschutzautomatik".i18n)),
                        
                        UICSwitch(
                          value: node.statusFlags.sunAutoEnabled,
                          onChanged: () {
                            node.setEnableSunProtection(!(node.statusFlags.sunAutoEnabled));
                          }
                        ),
                      ],
                    ),
                              
                    if((node.isDrive && node.supportsSpecialFunctions) || (node.isVarioControl && node.isDrive)) const UICSpacer(),
                    if((node.isDrive && node.supportsSpecialFunctions) || (node.isVarioControl && node.isDrive)) Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          triggerMode: TooltipTriggerMode.manual,
                          showDuration: const Duration(seconds: 0),
                          message: "Aktiviert oder deaktiviert die Memo-Funktion im gewählten Gerät. Memo-Zeiten können mit geeigneten Handsendern programmiert werden indem zum gewünschten Zeitpunkt die Fahrtaste länger als 5 Sekunden gedrückt wird. Die Fahrbewegung wird dann alle 24 Stunden wiederholt.".i18n,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.info, color: theme.colorScheme.secondary),
                          ),
                        ),
                              
                        Expanded(child: Text("Memo-Funktion".i18n)),
                        
                        UICSwitch(
                          value: node.statusFlags.memoAutoEnabled,
                          onChanged: () {
                            node.setEnableMemoryFunction(!(node.statusFlags.memoAutoEnabled));
                          }
                        ),
                      ],
                    ),
                              
                    if((node.isDrive && node.supportsSpecialFunctions) || (node.isVarioControl && node.isDrive)) const Divider(),
                    if((node.isDrive && node.supportsSpecialFunctions) || (node.isVarioControl && node.isDrive)) const UICSpacer(),
                    
                    if((node.isRemote || node.isSensor || node.isCentral) && node.version != null) const UICSpacer(),
                    if((node.isRemote || node.isSensor || node.isCentral) && node.version != null) UICElevatedButton(
                      shrink: false,
                      onPressed: () {
                        CPRemoteChannelSelector.go(context, node);
                      },
                      leading: const Icon(Icons.settings_remote),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: node.isSensor ? Text("Sensorzuordnung".i18n) : Text("Kanalbelegung".i18n),
                    ),
      
                    if((node.isRemote || node.isSensor) && node.isBatteryPowered && node.version != null) const UICSpacer(),
      
                    if((node.isRemote || node.isSensor) && node.isBatteryPowered && node.version != null) UICElevatedButton(
                      shrink: false,
                      style: UICColorScheme.error,
                      onPressed: () async {
                        final scaffold = UICScaffold.of(context);
                        remoteButtonCompleter = Completer();      
                        OverlayEntry? barrier = await UICMessenger.of(context).createBarrier(
                          title: "Warte auf Handsender".i18n,
                          abortable: true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text("Drücken Sie jetzt eine Taste an Ihrem Handsender".i18n),
                          ),
                          onAbort: () {
                            remoteButtonCompleter?.complete(false);
                            remoteButtonCompleter = null;
                          }
                        );
      
                        final result = await remoteButtonCompleter?.future;
                        barrier?.remove();
      
                        if(result == true) {
                          scaffold.hideSecondaryBody();
                          node.scFactoryResetAll();
                          await node.cp.restartReadAllNodes();
                        }
      
                      },
                      leading: const Icon(Icons.highlight_remove_rounded),
                      child: Text("Alle Funkzuordnungen löschen".i18n)
                    ),
      
                    if(node.isDrive) const UICSpacer(),
                              
                    if(node.isDrive) UICElevatedButton(
                      shrink: false,
                      onPressed: () => CPNodeSunProtectionView.push(context, node),
                      leading: const Icon(Icons.wb_sunny_rounded),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: Text("Sonnenschutz".i18n),
                    ),
                              
                    if((node.isVarioControl || node.isLightControl) && !node.isRemote && !node.isVC180) const UICSpacer(),
                              
                    if((node.isVarioControl || node.isLightControl) && !node.isRemote && !node.isVC180) UICElevatedButton(
                      shrink: false,
                      onPressed: () => CPNodeOperationModeView.go(context, node),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: Text("Betriebsart".i18n),
                    ),
                              
                    if((node.isDrive || node.isLightControl || node.isVarioControl) && !node.isVC421) const UICSpacer(),
                              
                    if((node.isDrive || node.isLightControl || node.isVarioControl) && !node.isVC421) UICElevatedButton(
                      shrink: false,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: ((node.isVC180 || node.isLightControl || (node.isVarioControl && (node.initiator == CPInitiator.actSwitchDim || node.initiator == CPInitiator.oneTwo))) || node.initiator == CPInitiator.actImpulseLight) ? Text("Laufzeit".i18n) : Text("Endlagen".i18n),
                      onPressed: () => CPNodeEndPositionsView.go(context, node)
                    ),
                              
                    if(node.isDrive) const UICSpacer(),
                              
                    if(node.isDrive) UICElevatedButton(
                      shrink: false,
                      onPressed: () => CPNodePresetsView.go(context, node),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: Text("Zwischenpositionen".i18n),
                    ),
                              
                    if(node.isEvo) const UICSpacer(),
                              
                    if(node.isEvo) UICElevatedButton(
                      shrink: false,
                      onPressed: () => CPNodeEvoConfigurationView.go(context, node),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: Text("Fahrprofile".i18n),
                    ),
      
                    if(!node.isCentral && node.initiator != null) const UICSpacer(),
                              
                    if((!node.isCentral && node.initiator != null && !node.isRemote && !node.isBatteryPowered) || node.initiator == CPInitiator.oneTwo || node.initiator == CPInitiator.sunDuskWind) UICElevatedButton(
                      shrink: false,
                      onPressed: () => NodeAdvancedSettingsView.go(context, node),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      leading: const Icon(Icons.settings_rounded),
                      child: Text("Erweiterte Einstellungen".i18n),
                    ),

                    if(!node.isBatteryPowered) const UICSpacer(),

                    if(extendedSettings.expand) UICElevatedButton(
                      shrink: false,
                      onPressed: () => CPNodeSessionInfo.go(context, node),
                      leading: const Icon(Icons.code_rounded),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      child: Text("Entwickler".i18n),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
