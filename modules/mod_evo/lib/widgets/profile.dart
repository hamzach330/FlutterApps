part of '../module.dart';

class EvoProfiles extends StatefulWidget {
  const EvoProfiles({super.key});

  @override
  State<EvoProfiles> createState() => _EvoProfilesState();
}

class _EvoProfilesState extends State<EvoProfiles> {
  RangeValues? _currentRangeValues;
  late final evo = Provider.of<Evo>(context, listen: false);

  @override
  initState() {
    super.initState();
    unawaited(asyncInit());
  }

  Future<void> asyncInit () async {
    await evo.getRampConfiguration();
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<Evo>(
      builder: (context, evo, _) {
        _currentRangeValues = RangeValues(
          evo.rampConfiguration.rampTop?.toDouble() ?? 20.0,
          100 - (evo.rampConfiguration.rampBottom?.toDouble() ?? 40.0)
        );
        return Column(
          children: [
            DropdownMenu<EvoOperationMode?>(
              initialSelection: evo.rampConfiguration.mode,
              onSelected: (EvoOperationMode? mode) async {
                evo.rampConfiguration.mode = mode;
                await evo.setRampConfiguration();
                await evo.wink();
              },
              dropdownMenuEntries: EvoOperationMode.values.map<DropdownMenuEntry<EvoOperationMode>>((EvoOperationMode value) {
                return DropdownMenuEntry<EvoOperationMode>(
                  value: value,
                  label: value.name.i18n,
                );
              }).toList(),
            ),
        
            const UICSpacer(2),

            Row(
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
                ),

                Column(
                  children: [
                    if(evo.rampConfiguration.mode == EvoOperationMode.standard) Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 240,
                          width: 140,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/evo/ramp_default.png"),
                              fit: BoxFit.contain,
                            ),
                          )
                        )
                      ]
                    ),
                
                    if(evo.rampConfiguration.mode == EvoOperationMode.whisper) Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 240,
                          width: 140,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/evo/ramp_whisper.png"),
                              fit: BoxFit.contain,
                            ),
                          )
                        )
                      ]
                    ),
                
                    if(evo.rampConfiguration.mode == EvoOperationMode.adaptive) Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 240,
                          width: 140,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/evo/ramp_dynamic.png"),
                              fit: BoxFit.contain,
                            ),
                          )
                        )
                      ]
                    ),
                  ],
                ),
            
                if(evo.rampConfiguration.mode == EvoOperationMode.standard) SizedBox(
                  height: 240,
                  child: UICRangeSlider(
                    values: _currentRangeValues!,
                    backgroundGradient: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer,
                    ],
                    onChanged: (values) {
                      evo.rampConfiguration.rampTop = values.start.toInt();
                      evo.rampConfiguration.rampBottom = 100 - values.end.toInt();
                      setState(() {
                        _currentRangeValues = values;
                      });
                    },
                    onChangeEnd: (values) async {
                      evo.rampConfiguration.rampTop = values.start.toInt();
                      evo.rampConfiguration.rampBottom = 100 - values.end.toInt();
                      setState(() {
                        _currentRangeValues = values;
                      });

                      await evo.setRampConfiguration();
                      await evo.wink();
                    },
                  ),
                )
              ],
            ),

            const UICSpacer(3),

          ],
        );
      }
    );
  }
}