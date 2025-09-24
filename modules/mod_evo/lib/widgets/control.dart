part of '../module.dart';

class EvoControl extends StatefulWidget {
  const EvoControl({super.key});

  @override
  State<EvoControl> createState() => _EvoControlState();
}

class _EvoControlState extends State<EvoControl> {
  late final evo = Provider.of<Evo>(context, listen: false);
  AsyncPeriodicTimer? _timer;
  double _position = 0.0;
  bool endPositions = false;
  bool intermediatePositions = false;
  bool loading = true;

  @override
  initState() {
    super.initState();
    unawaited(asyncInit());
  }

  asyncInit() async {
    _timer = AsyncPeriodicTimer(const Duration(seconds: 7), _poll)..start();
    await checkEndPositions();
    await hasIntermediatePositions();
    loading = false;
    setState(() {});
  }

  Future<void> _poll() async {
    try {
      _position = await evo.getCurrentPosition();
      setState(() { });
    } catch(e) {
      dev.log("Error during poll: $e");
    }
  }

  @override
  dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void reassemble() {
    _timer?.cancel();
    super.reassemble();
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

  Future<void> hasIntermediatePositions() async {
    final pos1 = await evo.getIntermediatePosition1();
    final pos2 = await evo.getIntermediatePosition2();

    if(pos1 == 0 || pos2 == 0) {
      intermediatePositions = false;
    } else {
      intermediatePositions = true;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(loading) return const UICProgressIndicator();
    
    return Consumer<Evo>(
      builder: (context, evo, _) => Column(
        children: [
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

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                spacing: theme.defaultWhiteSpace,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Opacity(
                    opacity: 0,
                    child: Text("0%")
                  ), // Fix 1px offset glitch
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
                      if(!endPositions) {
                        unawaited(evo.move(0));
                        unawaited(evo.move(0));
                        unawaited(evo.move(0));
                        unawaited(checkEndPositions());
                      }
                    },
                  ),

                  const Icon(Icons.swap_vert_rounded, size: 32),
                ],
              ),

              if(endPositions) const UICSpacer(),

              if(endPositions) Column(
                spacing: theme.defaultWhiteSpace,
                children: [
                  UICBigSlider(
                    value: _position,
                    onChanged: (value) {},
                    onChangeEnd: (value) {
                      evo.moveTo(value);
                    },
                  ),
                  const Icon(Icons.height_rounded, size: 32),
                ],
              ),
            ],
          ),

          const UICSpacer(3),
        
          if(intermediatePositions) Center(
            child: SizedBox(
              width: 110,
              child: UICElevatedButton(
                onPressed: () {
                  evo.moveToIntemediatePosition1();
                },
                child: const Icon(BeckerIcons.one, size: 16,)
              ),
            ),
          ),
      
          if(intermediatePositions) const UICSpacer(),

          if(intermediatePositions) Center(
            child: Text("Lüftungsposition".i18n),
          ),

          if(intermediatePositions) const UICSpacer(2),

          if(intermediatePositions) Center(
            child: SizedBox(
              width: 110,
              child: UICElevatedButton(
                onPressed: () {
                  evo.moveToIntemediatePosition2();
                },
                child: const Icon(BeckerIcons.two, size: 16,)
              ),
            ),
          ),

          if(intermediatePositions) const UICSpacer(),

          if(intermediatePositions) Center(
            child: Text("Beschattungsposition".i18n),
          ),

          if(intermediatePositions) const UICSpacer(3),

        ],
      )
    );
  }
}


