part of '../module.dart';

class EvoSpeed extends StatelessWidget {
  const EvoSpeed({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<Evo>(
      builder: (context, evo, _) => Column(
        children: [
          if(evo.rampConfiguration.mode == EvoOperationMode.whisper) Column(
            children: [
              const UICSpacer(),
              UICNamedDivider(title: "Ab".i18n, padding: const EdgeInsets.only(top: 0)),
              UICColorSlider(
                min: 12,
                max: 19,
                divisions: 7,
                value: min(19, max(12, (evo.rampConfiguration.quietFast ?? 12).toDouble())),
                backgroundGradient: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer,
                ],
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    19: "70%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.quietFast = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.quietFast = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
      
              UICNamedDivider(title: "Auf".i18n, padding: const EdgeInsets.only(top: 20)),
              UICColorSlider(
                min: 12,
                max: 19,
                divisions: 7,
                value: min(28, max(12, (evo.rampConfiguration.quietSlow ?? 12).toDouble())),
                backgroundGradient: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer,
                ],
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    19: "70%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.quietSlow = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.quietSlow = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
            ],
          ),
      
          if(evo.rampConfiguration.mode == EvoOperationMode.adaptive) Column(
            children: [
              const UICSpacer(),
              UICNamedDivider(title: "Ab".i18n, padding: EdgeInsets.zero),
              UICColorSlider(
                min: 12,
                max: 28,
                divisions: 16,
                value: min(28, max(12, (evo.rampConfiguration.dynamicSlow ?? 12).toDouble())),
                backgroundGradient: const [
                  Color(0xFFffcd00),
                  Color(0xBFffcd00),
                ],
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    28: "100%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.dynamicSlow = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.dynamicSlow = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
      
              UICNamedDivider(title: "Auf".i18n, padding: const EdgeInsets.only(top: 20)),
              UICColorSlider(
                min: 12,
                max: 28,
                divisions: 16,
                value: min(28, max(12, (evo.rampConfiguration.dynamicFast ?? 12).toDouble())),
                backgroundGradient: const [
                  Color(0xFFffcd00),
                  Color(0xBFffcd00),
                ],
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    28: "100%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.dynamicFast = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.dynamicFast = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
            ],
          ),
      
          if(evo.rampConfiguration.mode == EvoOperationMode.standard) Column(
            children: [
              const UICSpacer(),
              UICNamedDivider(title: "Langsamfahrt Ab".i18n, padding: EdgeInsets.zero),
              UICColorSlider(
                min: 12,
                max: 19,
                divisions: 7,
                value: min(19, max(12, (evo.rampConfiguration.standardSlowDown ?? 12).toDouble())),
                backgroundGradient: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer,
                ],
                onChange: (v) {
                  evo.rampConfiguration.standardSlowDown = v.toInt();
                  evo.notifyListeners();
                },
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    19: "70%"
                  }[v.toInt()];
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.standardSlowDown = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
      
              UICNamedDivider(title: "Langsamfahrt Auf".i18n, padding: const EdgeInsets.only(top: 20)),
              UICColorSlider(
                min: 12,
                max: 19,
                divisions: 7,
                value: min(19, max(12, (evo.rampConfiguration.standardSlowUp ?? 12).toDouble())),
                backgroundGradient: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer,
                ],
                valueFormatter: (v) {
                  return {
                    12: "45%",
                    19: "70%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.standardSlowUp = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.standardSlowUp = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
      
              UICNamedDivider(title: "Eilfahrt Ab".i18n, padding: const EdgeInsets.only(top: 20)),
              UICColorSlider(
                min: 19,
                max: 28,
                divisions: 7,
                value: min(28, max(19, (evo.rampConfiguration.standardFastDown ?? 12).toDouble())),
                backgroundGradient: const [
                  Color(0xFFffcd00),
                  Color(0xBFffcd00),
                ],
                valueFormatter: (v) {
                  return {
                    19: "70%",
                    28: "100%"
                  }[v.toInt()];
                },
                onChange: (v) {
                  evo.rampConfiguration.standardFastDown = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.standardFastDown = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
      
              UICNamedDivider(title: "Eilfahrt Auf".i18n, padding: const EdgeInsets.only(top: 20)),
              UICColorSlider(
                min: 19,
                max: 28,
                divisions: 7,
                value: min(28, max(19, (evo.rampConfiguration.standardFastUp ?? 12).toDouble())),
                valueFormatter: (v) {
                  return {
                    19: "70%",
                    28: "100%"
                  }[v.toInt()];
                },
                backgroundGradient: const [
                  Color(0xFFffcd00),
                  Color(0xBFffcd00),
                ],
                onChange: (v) {
                  evo.rampConfiguration.standardFastUp = v.toInt();
                  evo.notifyListeners();
                },
                onChangeEnd: (v) async {
                  evo.rampConfiguration.standardFastUp = v.toInt();
                  await evo.setRampConfiguration();
                  await evo.wink();
                }
              ),
            ],
          ),
        ],
      )
    );

  }
}