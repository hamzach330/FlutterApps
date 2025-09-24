part of 'module.dart';

class EvoIntermediatePositionsView extends StatefulWidget {
  static const path = '${EvoHome.path}/intermediate_positions';

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
      child: const EvoIntermediatePositionsView(),
    )
  );
  static go(BuildContext context) {
    context.push(path);
  }

  const EvoIntermediatePositionsView({super.key});

  @override
  State<EvoIntermediatePositionsView> createState() => _EvoIntermediatePositionsViewState();
}

class _EvoIntermediatePositionsViewState extends State<EvoIntermediatePositionsView> {
  late final evo = Provider.of<Evo>(context, listen: false);
  bool endPositions = false;
  bool loading = true;

  @override
  initState () {
    super.initState();
    unawaited(asyncInit());
  }

  asyncInit() async {
    await checkEndPositions();
    loading = false;
    setState(() {});
  }

  Future<void> checkEndPositions () async {
    final upper = await evo.getUpperEndPositionStatus();
    final lower = await evo.getLowerEndPositionStatus();

    if(upper.type == EvoModbusReadEndPositionType.none || lower.type == EvoModbusReadEndPositionType.none) {
      endPositions = false;
    } else {
      endPositions = true;
    }

    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if(loading) return const UICProgressIndicator();

    return UICPage(
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          body: UICTitle("Zwischenpositionen".i18n)
        ),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            const UICSpacer(5),

            if(!endPositions) Center(
              child: Container(
                padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorVariant.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(5))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: theme.defaultWhiteSpace),
                      child: Icon(Icons.expand_rounded,
                        color: theme.colorScheme.successVariant.onPrimaryContainer,
                        size: 16
                      )
                    ),
                    
                    Text("Einrichtung unvollständig".i18n,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.errorVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),

            if(endPositions) Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      UICBigMove(
                        onUp: () {
                          evo.move(-1);
                        },
                        onStop: () {
                          evo.move(0);
                        },
                        onDown: () {
                          evo.move(1);
                        },
                        onRelease: () {
                          evo.move(0);
                        },
                      ),
                              
                      const UICSpacer(),
                              
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UICElevatedButton(
                              shrink: false,
                              onPressed: () {
                                evo.moveToIntemediatePosition1();
                              },
                              leading: const RotatedBox(
                                quarterTurns: 2,
                                child: Icon(Icons.download),
                              ),
                              child: Text("Lüftungsposition (ZP1) anfahren".i18n)
                            ),
                        
                            const UICSpacer(),
                            
                            UICElevatedButton(
                              shrink: false,
                              onPressed: () {
                                evo.moveToIntemediatePosition2();
                              },
                              leading: const Icon(Icons.download),
                              child: Text("Beschattungsposition (ZP2) anfahren".i18n)
                            ),
  
                            const Expanded(child: UICSpacer()),
                        
                            UICElevatedButton(
                              shrink: false,
                              onPressed: () {
                                evo.setIntermediatePosition1Here();
                              },
                              leading: const Icon(Icons.settings_applications),
                              child: Text("Lüftungsposition (ZP1) setzen".i18n)
                            ),
  
                            const UICSpacer(),
                        
                            UICElevatedButton(
                              shrink: false,
                              onPressed: () {
                                evo.setIntermediatePosition2Here();
                              },
                              leading: const Icon(Icons.settings_applications),
                              child: Text("Beschattungsposition (ZP2) setzen".i18n)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const UICSpacer(3),
      
                Center(
                  child: UICElevatedButton(
                    shrink: false,
                    style: UICColorScheme.error,
                    onPressed: () async {
                      final messenger = UICMessenger.of(context);
                      final answer = await messenger.alert(
                        UICSimpleQuestionAlert(
                          title: "Zwischenposition löschen".i18n,
                          child: Text("Möchten Sie die Zwischenposition wirklich löschen?".i18n),
                        )
                      );
      
                      if(answer == true) {
                        await evo.clearIntermediatePosition1();
                      }
                    },
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    child: Text("Lüftungsposition (ZP1) löschen".i18n)
                  ),
                ),
  
                const UICSpacer(),
  
                Center(
                  child: UICElevatedButton(
                    shrink: false,
                    style: UICColorScheme.error,
                    onPressed: () async {
                      final messenger = UICMessenger.of(context);
                      final answer = await messenger.alert(
                        UICSimpleQuestionAlert(
                          title: "Zwischenposition löschen".i18n,
                          child: Text("Möchten Sie die Zwischenposition wirklich löschen?".i18n),
                        )
                      );
      
                      if(answer == true) {
                        await evo.clearIntermediatePosition2();
                      }
                    },
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    child: Text("Beschattungsposition (ZP2) löschen".i18n)
                  ),
                ),
  
                const UICSpacer(2),
  
                Center(
                  child: UICElevatedButton(
                    shrink: false,
                    style: UICColorScheme.error,
                    onPressed: () async {
                      final messenger = UICMessenger.of(context);
                      final answer = await messenger.alert(
                        UICSimpleQuestionAlert(
                          title: "Zwischenpositionen löschen".i18n,
                          child: Text("Möchten Sie wirklich alle Zwischenpositionen löschen?".i18n),
                        )
                      );
      
                      if(answer == true) {
                        await evo.clearIntermediatePositions();
                      }
                    },
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    child: Text("Zwischenpositionen löschen".i18n)
                  ),
                ),
              ]
            )
  
          ],
        )
      ] // const [ EvoProfiles(), EvoSpeed() ],
    );
  }
}
