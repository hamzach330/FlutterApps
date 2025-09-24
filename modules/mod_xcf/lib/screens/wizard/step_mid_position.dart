part of '../../module.dart';

class StepIntermediatePosition extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const StepIntermediatePosition({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<StepIntermediatePosition> createState() =>
      _StepIntermediatePositionState();
}

class _StepIntermediatePositionState extends State<StepIntermediatePosition> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  late final XCFSetupController controller;
  final dwellTimeTextController = TextEditingController(text: "60");

  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = XCFSetupController(xcf: xcf, context: context);
    controller.init().then((_) async {
      final dt = await xcf.getDwellTime();
      dwellTimeTextController.text = dt.toString();
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      children: [
        Text("Zwischenhalt", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: theme.defaultWhiteSpace),
        Expanded(
          child: Row(
            children: [
              // Linke Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Verweildauer".i18n,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: UICTextInput(
                              label: "Verweildauer (Sekunden)".i18n,
                              controller: dwellTimeTextController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                theme.colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),)),
                            ),
                            icon: const Icon(Icons.save_rounded),
                            tooltip: "Verweildauer speichern".i18n,
                            onPressed: () async {
                              final value =
                                  int.tryParse(dwellTimeTextController.text);
                              if (value != null) {
                                await xcf.setDwellTime(value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Rechte Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: theme.defaultWhiteSpace),
                              child: UICBigMove(
                                onUp: () {
                                  timer?.cancel();
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 100), (_) {
                                    xcf.sendCommand(XCFCommand.DI_AUF);
                                  });
                                },
                                onStop: () {
                                  timer?.cancel();
                                },
                                onDown: () {
                                  timer?.cancel();
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 100), (_) {
                                    xcf.sendCommand(XCFCommand.DI_AB);
                                  });
                                },
                                onRelease: () {
                                  timer?.cancel();
                                  controller
                                      .updateSetupState()
                                      .then((_) => setState(() {}));
                                },
                              ),
                            ),
                            ListenableBuilder(
                              listenable: controller.position,
                              builder: (context, _) {
                                return UICBigSlider(
                                  width: 50,
                                  readOnly: true,
                                  labelSide: UICTextInputLabelSide.bottom,
                                  value: max(
                                      0,
                                      min(100,
                                          100 * controller.position.value)),
                                  onChangeEnd: (_) {},
                                  onChanged: (_) {},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller.setIntermediatePosition();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Zwischenhalt setzen".i18n),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        //TODO: get rid of these SizedBoxes
        SizedBox(height: theme.defaultWhiteSpace),
        SizedBox(height: theme.defaultWhiteSpace),
        SizedBox(height: theme.defaultWhiteSpace),
      ],
    );
  }
}
