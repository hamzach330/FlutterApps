part of 'module.dart';

class CPNodeEndPositionsView extends StatefulWidget {
  static const pathName = 'end_positions';
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
      child: const CPNodeEndPositionsView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const CPNodeEndPositionsView({super.key});

  @override
  State<CPNodeEndPositionsView> createState() => _CPNodeEndPositionsViewState();
}

class _CPNodeEndPositionsViewState extends State<CPNodeEndPositionsView> {
  final runtimeTextController = TextEditingController();
  final pulsetimeTextController = TextEditingController();
  final turntimeTextController = TextEditingController();
  late final node = Provider.of<CentronicPlusNode>(context, listen: false);
  late final scaffold = UICScaffold.of(context);
  late final UICMessengerState messenger;

  @override
  initState() {
    super.initState();
    unawaited(getRuntimeConfiguration());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger =  UICMessenger.of(context);
    });
  }

  Future<void> getRuntimeConfiguration() async {
    final runtime = await node.getRuntime();

    runtimeTextController.text = ((runtime?.values['runtime'] ?? 100.0) / 1000).toString();
    turntimeTextController.text = ((runtime?.values['turntime'] ?? 100.0) / 1000).toString();
    pulsetimeTextController.text = ((runtime?.values['pulsetime'] ?? 100.0) / 1000).toString();
  }

  Future<void> setRuntimeConfiguration() async {
    await node.setRuntime(
      pulseTime: max(min(double.parse(pulsetimeTextController.text.replaceAll(RegExp(r','), '.')), 600), 0),
      turnTime: max(min(double.parse(turntimeTextController.text.replaceAll(RegExp(r','), '.')), 600), 0),
      runTime: max(min(double.parse(runtimeTextController.text.replaceAll(RegExp(r','), '.')), 600), 0),
    );

    await Future.delayed(const Duration(seconds: 1));

    await getRuntimeConfiguration();
  }

  invertRotaryDirection (CentronicPlusNode node) async {
    final confirm = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: "Drehrichtung ändern".i18n,
      child: Text("Die Änderung der Drehrichtung kann nur ausgelöst werden, wenn die Endlagen im entsprechenden Gerät noch nicht gesetzt sind.".i18n)
    ));

    if(confirm == true) {
      node.invertRotaryDirection();
      node.updateProperties();
    }
  }

  Future<bool?> confirm() async => await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
    title: "Endlage(n) löschen".i18n,
    child: Text("Sollen die Endlagen gelöscht werden?".i18n)
  ));

  deleteEndposition (CentronicPlusNode node) async {
    if(await confirm() == true) {
      node.deleteEndposition();
      await Future.delayed(const Duration(seconds: 1));
      await node.updateProperties();
    }
  }

  setUpperEndposition (CentronicPlusNode node) async {
    node.setUpperEndposition();
    await Future.delayed(const Duration(seconds: 1));
    await node.updateProperties();
    await Future.delayed(const Duration(seconds: 1));
    await getRuntimeConfiguration();
  }

  setLowerEndposition (CentronicPlusNode node) async {
    node.setLowerEndposition();
    await Future.delayed(const Duration(seconds: 1));
    await node.updateProperties();
    await Future.delayed(const Duration(seconds: 1));
    await getRuntimeConfiguration();
  }

  void sendStopCommand () {
    node.sendStopCommand();
  }

  Future<bool> copyRuntimeConfiguration(CentronicPlusNode selection) async {
    final confirm = await messenger.alert(UICSimpleQuestionAlert(
      title: "Laufzeit übertragen".i18n,
      child: Text("Soll die Laufzeit von %s auf %s übertragen werden?".i18n.fill([node.name?.trim() ?? '', selection.name?.trim() ?? '']))
    ));

    if(confirm == true) {
      selection.setRuntime(
        pulseTime: double.parse(pulsetimeTextController.text.replaceAll(RegExp(r','), '.')),
        turnTime: double.parse(turntimeTextController.text.replaceAll(RegExp(r','), '.')),
        runTime: double.parse(runtimeTextController.text.replaceAll(RegExp(r','), '.')),
      );
    }

    return confirm ?? false;
  }

  Future close (BuildContext context) async {
    scaffold.hideSecondaryBody();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          body: UICTitle("Endlagen".i18n),
        ),
        Consumer<CentronicPlusNode>(
          builder: (context, node, _) {
            return UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                CPNodeInfo(),

                UICSpacer(),
                
                if(node.initiator != CPInitiator.actSwitchDim) Column(
                  children: [
                    if(!node.isLightControl || !node.isVC180) IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          UICBigMove(
                            onUp: node.sendUpCommand,
                            onStop: node.sendStopCommand,
                            onDown: node.sendDownCommand,
                            onRelease: () async {
                              sendStopCommand();
                            },
                          ),
                          
                          const UICSpacer(),
                      
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                UICElevatedButton(
                                  shrink: false,
                                  style: UICColorScheme.variant,
                                  onPressed: () => setUpperEndposition(node),
                                  leading: const Icon(Icons.arrow_upward_rounded),
                                  child: Text("Endlage oben setzen".i18n)
                                ),
                                                    
                                const UICSpacer(),
                                                      
                                UICElevatedButton(
                                  shrink: false,
                                  style: UICColorScheme.error,
                                  onPressed: () => deleteEndposition(node),
                                  leading: const Icon(Icons.remove_circle_outline_rounded),
                                  child: Text("Endlage löschen".i18n)
                                ),
                            
                                const UICSpacer(),
                                                    
                                UICElevatedButton(
                                  shrink: false,
                                  style: UICColorScheme.variant,
                                  onPressed: () => setLowerEndposition(node),
                                  leading: const Icon(Icons.arrow_downward_rounded),
                                  child: Text("Endlage unten setzen".i18n)
                                ),
                                                    
                                if(node.statusFlags.setupComplete != true) const UICSpacer(),
                                                      
                                if(node.statusFlags.setupComplete != true) UICElevatedButton(
                                  shrink: false,
                                  style: UICColorScheme.warn,
                                  onPressed: () => invertRotaryDirection(node),
                                  leading: const Icon(Icons.refresh),
                                  child: Text("Drehrichtung ändern".i18n)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if(node.isVenetian) const UICSpacer(),
                    if(node.isVenetian) const Divider(),
                    if(node.isVenetian) const UICSpacer(),
                    if(node.isVenetian) Row(
                      children: [
                        Icon(Icons.info, color: theme.colorScheme.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text("Bitte setzen Sie zuerst du untere Endlage. Fahren Sie die Jalousie danach in die maximale Wendung (volle Öffnung der Lamellen) und setzen Sie nochmals die untere Endlage. Dann fahren Sie die Jalousie komplett auf und setzen Sie die obere Endlage. Damit ist die Programmierung abgeschlossen und der individuelle Wendungsweg Ihrer Jalousie ist eingestellt.".i18n)
                        ),
                      ],
                    ),
                    
                    if(!node.isVC180 || !node.isLightControl) Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UICSpacer(),
                        Row(
                          children: [
                            Icon(Icons.info, color: theme.colorScheme.secondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text("Die Änderung der Drehrichtung ist nur bei gelöschten Endlagen möglich.".i18n)
                            ),
                          ],
                        ),
                        const UICSpacer(),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.warnVariant.primaryContainer),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text("Wird die \"Endlagen löschen\"-Funktion in einer der beiden Endlagen stehend aufgerufen, so wird nur diese Endlage gelöscht.".i18n),
                            )
                          ],
                        )
                      ]
                    ),
                  ]
                ),
            
                if(node.isVarioControl && node.matchVersion(min: Version(1, 82, 0))) const UICSpacer(),
                if(node.isVarioControl && node.matchVersion(min: Version(1, 82, 0))) const Divider(),
                if(node.isVarioControl && node.matchVersion(min: Version(1, 82, 0))) const UICSpacer(),

                if(node.isVarioControl && node.matchVersion(min: Version(1, 82, 0))) Column(
                  children: [
                    if(node.isVarioControl || node.initiator == CPInitiator.actSwitchDim || node.initiator == CPInitiator.actWayLight) Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text("Laufzeit".i18n)),
                        SizedBox(
                          width: 100,
                          child: UICTextInput(
                            labelSide: UICTextInputLabelSide.left,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            hintText: "Sekunden".i18n,
                            label: "Sekunden".i18n,
                            controller: runtimeTextController,
                            onEditingComplete: () async {
                              await setRuntimeConfiguration();
                              if(mounted) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            }
                          ),
                        ),
                      ],
                    ),
                    
                    if(node.isVarioControl && node.isVenetian) const UICSpacer(),
                
                    if(node.isVarioControl && node.isVenetian) Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text("Wendungszeit".i18n)),
                        SizedBox(
                          width: 100,
                          child: UICTextInput(
                            labelSide: UICTextInputLabelSide.left,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            hintText: "Sekunden".i18n,
                            label: "Sekunden".i18n,
                            controller: turntimeTextController,
                          ),
                        ),
                      ],
                    ),
                
                    if(node.isVC180 || node.isLightControl) const UICSpacer(),
                
                    if(node.isLightControl && node.initiator == CPInitiator.actImpulseLight) Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: UICTextInput(
                              labelSide: UICTextInputLabelSide.left,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              hintText: "Impulszeit".i18n,
                              label: "Impulszeit".i18n,
                              controller: pulsetimeTextController,
                            ),
                          ),
                        ),
                      ],
                    ),
                
                    if(node.isVC180 || node.isVarioControl || node.isLightControl) const UICSpacer(),
                
                    if(node.isVC180 || node.isVarioControl || node.isLightControl) UICElevatedButton(
                      shrink: false,
                      style: UICColorScheme.success,
                      leading: const Icon(Icons.save_rounded),
                      child: Text("Laufzeit speichern".i18n),
                      onPressed: () async {
                        await setRuntimeConfiguration();
                      }
                    ),
                    
                    if(node.isVC180 || node.isVarioControl || node.isLightControl) const UICSpacer(),
                
                    if(node.isVC180 || node.isVarioControl || node.isLightControl) UICElevatedButton(
                      shrink: false,
                      style: UICColorScheme.error,
                      leading: const Icon(Icons.cancel_rounded),
                      child: Text("Laufzeit löschen".i18n),
                      onPressed: () async {
                        runtimeTextController.text = "0.0";
                        await setRuntimeConfiguration();
                      }
                    )
                  ],
                )
              ],
            );
          }
        ),
      ],
    );
  }
}
