part of 'module.dart';

class CPNodeSunProtectionView extends StatefulWidget {
  static const pathName = 'solar_protection';
  static const path = '${CPNodeAdminView.basePath}/:id/$pathName';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final node = context.read<CentronicPlusNode>();
      return CustomTransitionPage(
        key: ValueKey("${CPNodeAdminView.basePath}/${node.mac}/$pathName"),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            key: ValueKey("$path/${node.mac}"),
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        child: CPNodeSunProtectionView(
          userMode: (state.extra as bool?) ?? false,
          node: node,
        ),
      );

    }
  );

  static push (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }
  
  static go (BuildContext context, CentronicPlusNode node) async {
    node.selectUnique();
    UICScaffold.of(context).showSecondaryBody();
    context.go("${CPNodeAdminView.basePath}/${node.mac}/$pathName", extra: true);
  }

  final bool userMode;
  final CentronicPlusNode node;

  const CPNodeSunProtectionView({
    super.key,
    this.userMode = false,
    required this.node,
  });

  @override
  State<CPNodeSunProtectionView> createState() => _CPNodeSunProtectionViewState();
}

class _CPNodeSunProtectionViewState extends State<CPNodeSunProtectionView> {
  late final CentronicPlusNode node = widget.node;
  late final CentronicPlus centronicPlus = context.read<CentronicPlus>();
  late final scaffold = UICScaffold.of(context);
  final GlobalKey<TooltipState> tipWinterMode = GlobalKey<TooltipState>();

  double sunThresLo = 5;
  double sunThresHi = 6;
  double sunDelayLo = 480;
  double sunDelayHi = 480;
  double windThres  = 6;
  CPMatrixMode role = CPMatrixMode.none;
  bool   modeWinter = false;
  bool   picker     = false;
  int    matrix     = 0;
  bool   _update    = false;

  Map<String, dynamic>? analogValues;

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    analogValues = (await node.readSunProfile())?.analog.values;
    setState(() {
      if(analogValues != null) {
        sunThresLo = AnalogValues.toSunLevel(analogValues?['sun-thres-lo'] ?? 5).toDouble();
        sunThresHi = AnalogValues.toSunLevel(analogValues?['sun-thres-hi'] ?? 6).toDouble();
        windThres  = AnalogValues.toWindLevel(analogValues?['wind-thres-hi'] ?? 6).toDouble();
        sunDelayLo = (analogValues?['sun-delay-lo'] ?? 480).toDouble();
        sunDelayHi = (analogValues?['sun-delay-hi'] ?? 480).toDouble();
      }
    });

    final int matrix = analogValues?['matrix'];

    if(matrix == 1 || matrix == 5 || matrix == 6 || matrix == 17) {
      role = CPMatrixMode.none;
    } else if(matrix == 2 || matrix == 7 || matrix == 9 || matrix == 18) {
      role = CPMatrixMode.sunProtection;
    } else if(matrix == 4 || matrix == 8 || matrix == 10 || matrix == 19) {
      role = CPMatrixMode.rainProtection;
    } else {
      role = CPMatrixMode.none;
    }

    modeWinter = node.statusFlags.locked;
  }
  
  toggleAction (int actionId) async {
    if(actionId == 0) {
      role = CPMatrixMode.sunProtection;
    } else if(actionId == 1) {
      role = CPMatrixMode.none;
    } else if(actionId == 2) {
      role = CPMatrixMode.rainProtection;
    }
    update();
    setState(() { });
  }

  toggleModeWinter () async {
    modeWinter = !modeWinter;
    update();
    setState(() { });
  }

  confirm () async {
    if(_update) {
      final answer = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
        title: "Ungespeicherte Änderungen".i18n,
        child: Text("Sollen die Änderungen gespeichert werden?".i18n)
      ));
      if(answer == true) {
        await save();
      }
    }
  }

  Future<void> close (BuildContext context) async {
    final router = GoRouter.of(context);
    await confirm();
    router.go(CPNodeAdminView.basePath);
    scaffold.hideSecondaryBody();
  }

  void pop () async {
    if(widget.userMode) {
      centronicPlus.unselectNodes();
      close(context);
    } else {
      final router = GoRouter.of(context);
      await confirm();
      if(context.mounted) {
        router.pop();
      }
    }
  }

  update () {
    _update = true;
  }

  save() async {
    await node.writeSunProfile(
      sunDelayHi: sunDelayHi.toInt(),
      sunDelayLo: sunDelayLo.toInt(),
      sunThresHi: sunThresHi.toInt(),
      sunThresLo: sunThresLo.toInt(),
      windThresLo: windThres.toInt(),
      winterMode: modeWinter,
      matrix: node.getMatrixValueFor(role)
    );

    _update = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamProvider<CentronicPlusNode>.value(
      value: node.updateStream.stream,
      initialData: node,
      updateShouldNotify: (_, __) => true,
      builder: (_, __) {
        return UICPage(
          //backgroundColor: theme.colorScheme.surfaceContainerLow,
          slivers: [
            UICPinnedHeader(
              height: 70.0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
                tooltip: "Zurück".i18n,
                onPressed: () {
                  pop();
                },
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UICTitle(node.name ?? "Unbenannter Empfänger".i18n),
                ],
              ),
              // trailing: ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
              //     backgroundColor: theme.colorScheme.successVariant.primaryContainer,
              //     foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
              //     elevation: 2,
              //   ),
              //   onPressed: save,
              //   child: Row(
              //     children: [
              //       Text("Speichern".i18n),
              //       const UICSpacer(),
              //       Icon(Icons.save_rounded, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
              //     ],
              //   ),
              // ),
              trailing: ElevatedButton(
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
            ),

            Consumer<CentronicPlusNode>(
              builder: (context, node, _) => UICConstrainedSliverList(
                maxWidth: 400,
                children: [
                  if(!widget.userMode) CPNodeInfo(
                    readOnly: true,
                  ),

                  if(!widget.userMode) UICSpacer(),

                  Text("Hinweis: Änderungen der Schwellwerte versetzen das Gerät für 3 Minuten in den Testmodus. Während der Testmodus aktiv ist reagiert es sofort auf Schwellwertänderungen. Verzögerungen werden zunächst ignoriert.".i18n, style: theme.bodyMediumItalic),
                  
                  if(analogValues == null || analogValues?.isEmpty == true) Material(
                  color: theme.colorScheme.warnVariant.primaryContainer,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const UICSpacer(),
        
                          UICProgressIndicator.large(),
                          
                          const UICSpacer(2),
        
                          Text("Die Sonnenschutzeinstellungen werden geladen.".i18n,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.warnVariant.onPrimaryContainer
                            )
                          ),
        
                          const UICSpacer(2),
                                
                          Text("Bitte haben Sie einen Moment Geduld.".i18n,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.warnVariant.onPrimaryContainer
                            )
                          ),
                                
                          const UICSpacer(),
                                
                          UICElevatedButton(
                            onPressed: node.readSunProfile,
                            leading: const Icon(Icons.refresh),
                            child: Text("Wiederholen".i18n)
                          ),
                        ],
                      ),
                    ),
                  ),
              
                  UICNamedCenterDivider(title: "Sonnenschwellwert (Stufe)".i18n, padding: const EdgeInsets.only(top: 10)),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Überschritten".i18n, style: theme.bodySmallItalic),
                  ),
                  
                  UICColorSlider(
                    min: 1,
                    max: 15,
                    divisions: 14,
                    value: max(sunThresHi, 1),
                    backgroundGradient: const [
                      Color(0xFFffcd00),
                      Color(0xBFffcd00),
                    ],
                    onChange: (v) => setState(() {
                      sunThresHi = v;
                      sunThresLo = min(sunThresLo, sunThresHi - 1);
                    }),
                    onChangeEnd: (_) => update()
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Unterschritten".i18n, style: theme.bodySmallItalic),
                  ),
                  
                  UICColorSlider(
                    min: 0,
                    max: 14,
                    divisions: 14,
                    value: max(sunThresLo, 0),
                    onChange: (v) => setState(() {
                      sunThresLo = v;
                      sunThresHi = max(sunThresLo + 1, sunThresHi);
                    }),
                    onChangeEnd: (_) => update(),
                  ),
              
                  UICNamedCenterDivider(title: "Verzögerung Sonnenautomatik (Minuten)".i18n, padding: const EdgeInsets.only(top: 30)),
              
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Ausfahrtverzögerung bei erreichtem Sonnenwert".i18n, style: theme.bodySmallItalic),
                  ),
                  UICColorSlider(
                    min: 3,
                    max: 15,
                    divisions: 12,
                    // config: config,
                    value: max(sunDelayHi / 60, 3),
                    backgroundGradient: const [
                      Color(0xFFffcd00),
                      Color(0xBFffcd00),
                    ],
                    onChange: (v) => setState(() { sunDelayHi = v * 60; }),
                    onChangeEnd: (_) => update()
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Einfahrtverzögerung bei unterschrittenem Sonnenwert".i18n, style: theme.bodySmallItalic),
                  ),
                  UICColorSlider(
                    min: 6,
                    max: 30,
                    // config: config,
                    divisions: 24,
                    value: max(sunDelayLo / 60, 6),
                    onChange: (v) => setState(() { sunDelayLo = v * 60; }),
                    onChangeEnd: (_) => update()
                  ),
              
                  UICNamedCenterDivider(title: "Schwellwert für Windsensor".i18n, padding: const EdgeInsets.only(top: 30)),
                  
                  UICColorSlider(
                    min: 1,
                    max: 11,
                    // config: config,
                    divisions: 10,
                    value: max(windThres, 1),
                    onChange: (v) => setState(() { windThres = v; }),
                    onChangeEnd: (_) => update(),
                    backgroundGradient: [
                      Colors.white,
                      theme.colorScheme.errorVariant.primaryContainer,
                    ],
                    altRightColor: Colors.white,
                    altLeftColor: theme.colorScheme.errorVariant.primaryContainer,
                  ),
              
                  UICNamedCenterDivider(title: "Wintermodus".i18n, padding: const EdgeInsets.only(top: 30)),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Tooltip(
                        key: tipWinterMode,
                        triggerMode: TooltipTriggerMode.manual,
                        showDuration: const Duration(seconds: 0),
                        message: "Der gewählte Empfänger fährt automatisch in die obere Endlage und wird gegen jede Art der Bedienung gesperrt (betrifft auch alle eingelernten Sender). Wird verwendet, um Schutzüberzüge für Markisen vor Beschädigungen zu schützen.".i18n,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.info, color: theme.colorScheme.secondary),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Wintermodus'.i18n,
                          style: theme.textTheme.bodyMedium
                        ),
                      ),
                      UICSwitch(
                        value: modeWinter,
                        onChanged: toggleModeWinter,
                      )
                    ],
                  ),
              
                  UICNamedCenterDivider(title: "Reaktion auf Regen".i18n, padding: const EdgeInsets.only(top: 10)),
        
                  const UICSpacer(),
        
                  UICToggleButtonList(
                    onChanged: toggleAction,
                    buttons: [
                      UICToggleButton(
                        leading: const Icon(BeckerIcons.up),
                        selected: role == CPMatrixMode.sunProtection,
                        child: Text("Einfahren".i18n),
                      ),
                      UICToggleButton(
                        leading: const Icon(Icons.remove_rounded),
                        selected: role == CPMatrixMode.none,
                        child: Text("Keine".i18n),
                      ),
                      UICToggleButton(
                        leading: const Icon(BeckerIcons.down),
                        selected: role == CPMatrixMode.rainProtection,
                        child: Text("Ausfahren".i18n),
                      ),
                    ],
                  ),
                ],
              )
            )
          ],
        );
      }
    );
  }
}
