part of '../../module.dart';

class XCFSetupWizard extends StatefulWidget {
  static const path = '${XCFHome.path}/setup_wizard';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFSetupWizard(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFSetupWizard({super.key});

  @override
  State<XCFSetupWizard> createState() => _XCFSetupWizardState();
}

class _XCFSetupWizardState extends State<XCFSetupWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  late final messenger = UICMessenger.of(context);
  final dwellTimeTextController = TextEditingController(text: "60");
  StreamSubscription? subscription;

  Timer? timer;
  XCFSetupState? setupState;

  bool companyConfigured = false;
  bool canMove = false;
  bool lowerEndPositionSet = false;
  bool upperEndPositionSet = false;
  bool intermediaPositionSet = false;
  bool rotaryDirectionSet = false;
  bool rotaryDirectionAvailable = false;

  bool rotaryDirection = false;
  final position = ValueNotifier<double>(0);
  Timer? positionTimer;

  void _nextStep() {
    if(_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousStep() {
    if(_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    final dt = await xcf.getDwellTime();
    dwellTimeTextController.text = (dt).toString();

    setupState = await xcf.readSetup();

    upperEndPositionSet = setupState?.posAufBekannt ?? false;
    lowerEndPositionSet = setupState?.posZuBekannt ?? false;
    intermediaPositionSet = setupState?.posTeilAuf ?? false;
    rotaryDirectionSet = setupState?.posAufBekannt == true || setupState?.posZuBekannt == true;

    // Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
    //   position.value = (await xcf.readPosition());
    // });

    setState(() {});
  }

  Future<void> updateSetupState() async {
    setupState = await xcf.readSetup();
    setState(() {});
  }

  Future<void> removeLowerEndPosition () async {
    await xcf.setEndPosition(XCFEndPosition.lower);
  }

  Future<void> removeUpperEndPosition () async {
    await xcf.setEndPosition(XCFEndPosition.upper);
  }

  Future<void> setLowerEndPosition () async {
    if(lowerEndPositionSet) {
      await removeLowerEndPosition();
    }

    await xcf.sendCommand(XCFCommand.DI_PROG);

    setState(() {
      lowerEndPositionSet = true;
    });
  }

  Future<void> setUpperEndPosition () async {
    if(upperEndPositionSet) {
      await removeUpperEndPosition();
    }

    await xcf.sendCommand(XCFCommand.DI_PROG);

    setState(() {
      upperEndPositionSet = true;
    });
  }

  Future<void> deleteEndPositions () async {
    final confirmDelete = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlagen zurücksetzen".i18n,
      child: Text("Sind Sie sicher, dass Sie beide Endlagen zurücksetzen möchten?".i18n),
    ));

    if(confirmDelete == true) {
      await xcf.setEndPosition(XCFEndPosition.deleteUpperLower);
      setState(() {
        lowerEndPositionSet = false;
        upperEndPositionSet = false;
      });
    }
  }

  Future<void> getDwellTime () async {
    final dt = await xcf.getDwellTime();
    dwellTimeTextController.text = (dt).toString();
  }

  Future<void> setDwellTime () async {
    await xcf.setDwellTime(int.tryParse(dwellTimeTextController.text) ?? 10);
  }

  Future<void> setIntermediatePosition () async {
    await xcf.setIntermediatePosition(XCFIntermediatePosition.free);
    await xcf.sendCommand(XCFCommand.DI_PROG);
  }

  Future<void> deleteUpperEndPosition () async {
    final answer = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlage oben löschen".i18n,
      child: Text("Sind Sie sicher, dass Sie die obere Endlage löschen möchten?".i18n),
    ));

    if(answer == true) {
      await removeUpperEndPosition();
      setState(() {
        upperEndPositionSet = false;
      });
    }
  }

  Future<void> toggleRotaryDirection () async {
    rotaryDirection = !rotaryDirection;
    await xcf.toggleRotaryDirection(rotaryDirection ? 0 : 1);
  }

  Future<void> confirmRotaryDirection () async {
    setState(() {
      rotaryDirectionSet = true;
    });
  }

  Future<void> resetRotaryDirection () async {
    setState(() {
      rotaryDirectionSet = false;
    });
  }

  Future<void> deleteLowerEndPosition() async {
    final answer = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlage unten löschen".i18n,
      child: Text("Sind Sie sicher, dass Sie die untere Endlage löschen möchten?".i18n),
    ));
    if(answer == true) {
      await removeLowerEndPosition();
      setState(() {
        lowerEndPositionSet = false;
      });
    }
  }

  @override
  dispose() {
    subscription?.cancel();
    timer?.cancel();
    positionTimer?.cancel();
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return LayoutBuilder(
      builder: (context, constraints) {
        final xAxisCount = min(2, max(1, (constraints.maxWidth ~/ 450)));

        return Scaffold(
          body:
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StepProjectInfo(onNext: _nextStep),
                        StepFinalPosition(onNext: _nextStep, onPrevious: _previousStep),
                        StepIntermediatePosition(onNext: _nextStep, onPrevious: _previousStep),
                        StepSummary(onPrevious: _previousStep),
                      ],
                    )
                  ),
                  WizardNavigation(
                    onNext: _nextStep,
                    onPrevious: _previousStep,
                    currentStep: _currentPage,
                    totalSteps: 3,
                  ),
                  WizardStepper(currentStep: _currentPage, totalSteps: 3),
                ],
              ),
            )
            // SliverToBoxAdapter(
            //   child: Center(
            //     child: SizedBox(
            //       width: 600,
            //       child: UICGridTile(
            //         elevation: 0,
            //         borderColor: Colors.transparent,
            //         bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
            //         // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
            //         title: UICGridTileTitle(
            //           backgroundColor: Colors.transparent,
            //           title: Text("1/3 Projekt-Informationen".i18n, style: subtitle),
            //         ),
            //         body: Column(
            //           children: [
            //             XCFCompanyForm(
            //               onIsComplete: () {
            //                 setState(() {
            //                   companyConfigured = true;
            //                 });
            //               },
            //               onIsIncomplete: () {
            //                 setState(() {
            //                   companyConfigured = false;
            //                 });
            //               },
            //             ),
            //           ]
            //         )
            //       ),
            //     ),
            //   ),
            // ),
            //
            // SliverUICDynamicHeightGridView.children(
            //   crossAxisCount: xAxisCount,
            //   dividers: true,
            //   children: [
            //     IgnorePointer(
            //       ignoring: !companyConfigured,
            //       child: Opacity(
            //         opacity: companyConfigured ? 1 : 0.25,
            //         child: UICGridTile(
            //           elevation: 0,
            //           borderColor: Colors.transparent,
            //           bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace * 1),
            //           // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
            //           title: UICGridTileTitle(
            //             backgroundColor: Colors.transparent,
            //             title: Text("2/3 Endlagen".i18n, style: subtitle),
            //           ),
            //
            //           body: Column(
            //             children: [
            //               IntrinsicHeight(
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     if(setupState?.drehsinnBekannt == false) Expanded(
            //                       child: Column(
            //                         spacing: theme.defaultWhiteSpace,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Icon(Icons.warning_rounded, color: theme.colorScheme.warnVariant.primaryContainer, size: 48),
            //                           Text("Drehrichtung unbekannt!".i18n, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            //                           Text("Fahren Sie den Antrieb in Auf- oder Ab-Richtung, um die Drehrichtung zu erkennen. Wird die Drehrichtung nicht erkannt prüfen Sie die Anschlüsse Ihrer Steuerung.".i18n, textAlign: TextAlign.center),
            //                         ],
            //                       ),
            //                     ),
            //
            //                     if(!rotaryDirectionSet && setupState?.drehsinnBekannt == true && !lowerEndPositionSet) Expanded(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Row(
            //                             spacing: theme.defaultWhiteSpace,
            //                             children: [
            //                               UICElevatedButton(
            //                                 onPressed: toggleRotaryDirection,
            //                                 leading: const Icon(Icons.rotate_90_degrees_cw_rounded),
            //                                 child: Text("Drehrichtungsumkehr".i18n),
            //                               ),
            //
            //                               UICGridTileAction(
            //                                 onPressed: confirmRotaryDirection,
            //                                 style: UICColorScheme.success,
            //                                 tooltip: "Drehrichtung bestätigen".i18n,
            //                                 child: const Icon(Icons.navigate_next_rounded),
            //                               )
            //                             ],
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //
            //                     if(rotaryDirectionSet) Expanded(
            //                       child: Center(
            //                         child: Column(
            //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                           children: [
            //                             if(!lowerEndPositionSet) const SizedBox(),
            //                             if(lowerEndPositionSet) Row(
            //                               spacing: theme.defaultWhiteSpace,
            //                               children: [
            //                                 UICElevatedButton(
            //                                   onPressed: setUpperEndPosition,
            //                                   leading: const Icon(Icons.arrow_upward_rounded),
            //                                   child: upperEndPositionSet ?
            //                                     Text("Endlage oben ersetzen".i18n) :
            //                                     Text("Endlage oben setzen".i18n),
            //                                 ),
            //
            //                                 if(upperEndPositionSet) UICGridTileAction(
            //                                   size: 16,
            //                                   style: UICColorScheme.error,
            //                                   onPressed: deleteUpperEndPosition,
            //                                   tooltip: "Endlage oben löschen".i18n,
            //                                   child: const Icon(Icons.close_rounded),
            //                                 ),
            //
            //                                 const Expanded(child:SizedBox()),
            //
            //                                 if(upperEndPositionSet) Icon(Icons.check_circle_outline, color: theme.colorScheme.successVariant.primary),
            //                               ],
            //                             ),
            //
            //                             if(!upperEndPositionSet && !lowerEndPositionSet) const SizedBox(),
            //                             if(upperEndPositionSet && lowerEndPositionSet) Row(
            //                               children: [
            //                                 UICElevatedButton(
            //                                   style: UICColorScheme.error,
            //                                   onPressed: deleteEndPositions,
            //                                   leading: const Icon(Icons.undo_rounded),
            //                                   child: Text("Endlagen zurücksetzen".i18n),
            //                                 ),
            //                               ],
            //                             ),
            //
            //                             if(rotaryDirectionSet && !lowerEndPositionSet) Row(
            //                               children: [
            //                                 UICElevatedButton(
            //                                   style: UICColorScheme.error,
            //                                   onPressed: resetRotaryDirection,
            //                                   leading: const Icon(Icons.undo_rounded),
            //                                   child: Text("Zurück".i18n),
            //                                 ),
            //                               ],
            //                             ),
            //
            //                             if(rotaryDirectionSet) Row(
            //                               spacing: theme.defaultWhiteSpace,
            //                               children: [
            //                                 UICElevatedButton(
            //                                   onPressed: setLowerEndPosition,
            //                                   leading: const Icon(Icons.arrow_downward_rounded),
            //                                   child: lowerEndPositionSet ?
            //                                     Text("Endlage unten ersetzen".i18n) :
            //                                     Text("Endlage unten setzen".i18n),
            //                                 ),
            //
            //                                 if(!upperEndPositionSet && lowerEndPositionSet) UICGridTileAction(
            //                                   size: 16,
            //                                   style: UICColorScheme.error,
            //                                   onPressed: deleteLowerEndPosition,
            //                                   tooltip: "Endlage oben löschen".i18n,
            //                                   child: const Icon(Icons.close_rounded),
            //                                 ),
            //
            //                                 const Expanded(child:SizedBox()),
            //
            //                                 if(lowerEndPositionSet) Icon(Icons.check_circle_outline, color: theme.colorScheme.successVariant.primary),
            //                               ],
            //                             ),
            //
            //
            //
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //
            //                     Padding(
            //                       padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace),
            //                       child: UICBigMove(
            //                         onUp: () {
            //                           timer?.cancel();
            //                           timer = null;
            //                           timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            //                             xcf.sendCommand(XCFCommand.DI_AUF);
            //                           });
            //                         },
            //                         onStop: () {
            //                           timer?.cancel();
            //                           timer = null;
            //                         },
            //                         onDown: () {
            //                           timer?.cancel();
            //                           timer = null;
            //                           timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            //                             xcf.sendCommand(XCFCommand.DI_AB);
            //                           });
            //                         },
            //                         onRelease: () {
            //                           timer?.cancel();
            //                           timer = null;
            //                           updateSetupState();
            //                         },
            //                       ),
            //                     ),
            //
            //                   ]
            //                 ),
            //               ),
            //             ],
            //           )
            //         ),
            //       ),
            //     ),
            //
            //     IgnorePointer(
            //       ignoring: !lowerEndPositionSet || !upperEndPositionSet || !companyConfigured || !rotaryDirectionSet,
            //       child: Opacity(
            //         opacity: companyConfigured && lowerEndPositionSet && upperEndPositionSet && rotaryDirectionSet ? 1 : 0.25,
            //         child: UICGridTile(
            //           elevation: 0,
            //           borderColor: Colors.transparent,
            //           bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
            //           // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
            //           title: UICGridTileTitle(
            //             backgroundColor: Colors.transparent,
            //             title: Text("3/3 Zwischenhalt".i18n, style: subtitle),
            //           ),
            //
            //           body: Column(
            //             children: [
            //               IntrinsicHeight(
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   children: [
            //                     ListenableBuilder(
            //                       listenable: position,
            //                       builder: (context, _) {
            //                         return UICBigSlider(
            //                           width: 50,
            //                           readOnly: true,
            //                           labelSide: UICTextInputLabelSide.bottom,
            //                           value: max(0, min(100, 100 * position.value)),
            //                           onChangeEnd: (v) {},
            //                           onChanged: (v) {}
            //                         );
            //                       }
            //                     ),
            //
            //                     const UICSpacer(),
            //
            //                     Expanded(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.end,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Row(
            //                             spacing: theme.defaultWhiteSpace,
            //                             children: [
            //                               const Expanded(child:SizedBox()),
            //                               Flexible(
            //                                 child: UICTextInput(
            //                                   label: "Verweildauer (Sekunden)".i18n,
            //                                   controller: dwellTimeTextController
            //                                 ),
            //                               ),
            //                               UICGridTileAction(
            //                                 size: 24,
            //                                 style: UICColorScheme.success,
            //                                 onPressed: () {
            //                                   setDwellTime();
            //                                 },
            //                                 tooltip: "Verweildauer speichern".i18n,
            //                                 child: const Icon(Icons.save_rounded),
            //                               ),
            //                             ]
            //                           ),
            //
            //                           const UICSpacer(),
            //
            //                           UICElevatedButton(
            //                             onPressed: setIntermediatePosition,
            //                             child: Text("Zwischenhalt setzen".i18n),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //
            //                   ]
            //                 ),
            //               ),
            //             ],
            //           )
            //         ),
            //       ),
            //     ),
            //   ]
            // ),
            //
            // UICConstrainedSliverList(
            //   maxWidth: 200,
            //   children: [
            //     const UICSpacer(4),
            //     IgnorePointer(
            //       ignoring: !lowerEndPositionSet || !upperEndPositionSet || !companyConfigured || !rotaryDirectionSet,
            //       child: Opacity(
            //         opacity: lowerEndPositionSet && upperEndPositionSet && companyConfigured && rotaryDirectionSet ? 1 : 0.25,
            //         child: UICElevatedButton(
            //           onPressed: () async {
            //             final confirmStart = await messenger.alert(UICSimpleConfirmationAlert(
            //               title: "Probealarm starten".i18n,
            //               child: Text("Stellen Sie sicher, dass der Verfahrbereich frei von Hindernissen ist.".i18n),
            //             ));
            //
            //             if(confirmStart == true) {
            //               final timer =  Timer.periodic(const Duration(milliseconds: 100), (_) async {
            //                 await xcf.setOutput(TEL_OUTPUT.DO_FA03_REL3.index, true);
            //               });
            //
            //
            //               await xcf.setOutput(TEL_OUTPUT.DO_FA03_REL3.index, false);
            //
            //               final completer = Completer<bool>();
            //
            //               final barrier = messenger.createBarrier(
            //                 abortable: true,
            //                 title: "Probealarm".i18n,
            //                 child: Container(),
            //                 onAbort: () async {
            //                   timer.cancel();
            //                   await xcf.setOutput(TEL_OUTPUT.DO_FA03_REL3.index, false);
            //                   completer.complete(false);
            //                 }
            //               );
            //               await completer.future;
            //               barrier?.remove();
            //             }
            //           },
            //           style: UICColorScheme.variant,
            //           leading: const Icon(Icons.wb_iridescent_outlined),
            //           child: Text("Probealarm starten".i18n),
            //         ),
            //       ),
            //     ),
            //   ]
            // ),
            

        );
      }
    );
  }
}
