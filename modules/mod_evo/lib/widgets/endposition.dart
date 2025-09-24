part of '../module.dart';


class EvoEndposition extends StatefulWidget {
  const EvoEndposition({super.key});

  @override
  State<EvoEndposition> createState() => _EvoEndpositionState();
}

class _EvoEndpositionState extends State<EvoEndposition> {
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

  Future<void> setLower() async {
    await evo.setLowerEndpositionHere();
    await checkEndPositions();
  }

  Future<void> setUpper() async {
    await evo.setUpperEndpositionHere();
    await checkEndPositions();
  }

  Future<void> invertRotaryDirection() async {
    await evo.invertRotaryDirection();
    await checkEndPositions();
  }

  Future<void> deleteEndpositions() async {
    await evo.deleteEndpositions();
    await checkEndPositions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if(loading) return const UICProgressIndicator();

    return Consumer<Evo>(
      builder: (context, evo, _) => Column(
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UICBigMove(
                  onUp: () {
                    unawaited(evo.move(-1));
                  },
                  onStop: () {
                    unawaited(evo.move(0));
                  },
                  onDown: () {
                    unawaited(evo.move(1));
                  },
                  onRelease: () {
                    unawaited(evo.move(0));
                    unawaited(evo.move(0));
                    unawaited(evo.move(0));
                  },
                ),
            
                const UICSpacer(2),
            
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UICElevatedButton(
                        shrink: false,
                        style: UICColorScheme.variant,
                        onPressed: setUpper,
                        leading: const Icon(Icons.arrow_upward_rounded),
                        child: Text("Endlage oben setzen".i18n)
                      ),
                                          
                      const UICSpacer(),
                                            
                      UICElevatedButton(
                        shrink: false,
                        style: UICColorScheme.error,
                        onPressed: deleteEndpositions,
                        leading: const Icon(Icons.remove_circle_outline_rounded),
                        child: Text("Endlage(n) löschen".i18n)
                      ),
                  
                      const UICSpacer(),
                                          
                      UICElevatedButton(
                        shrink: false,
                        style: UICColorScheme.variant,
                        onPressed: setLower,
                        leading: const Icon(Icons.arrow_downward_rounded),
                        child: Text("Endlage unten setzen".i18n)
                      ),
                                          
                      if(!endPositions) const UICSpacer(),

                      if(!endPositions) UICElevatedButton(
                        shrink: false,
                        style: UICColorScheme.warn,
                        onPressed: invertRotaryDirection,
                        leading: const Icon(Icons.refresh),
                        child: Text("Drehrichtung ändern".i18n)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const UICSpacer(2),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UICSpacer(2),
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
          )
        ],
      )
    );
  }
}
