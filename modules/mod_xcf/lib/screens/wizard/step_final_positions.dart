part of '../../module.dart';

class StepFinalPosition extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const StepFinalPosition({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<StepFinalPosition> createState() => _StepFinalPositionState();
}

class _StepFinalPositionState extends State<StepFinalPosition> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  late final XCFSetupController controller;
  final dwellTimeTextController = TextEditingController(text: "60");

  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = XCFSetupController(xcf: xcf, context: context);
    controller.init().then((_) => setState(() {}));
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Endlagen", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: theme.defaultWhiteSpace),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: controller.lowerEndPositionSet ? null : Border.all(color: theme.colorScheme.primary),
                          boxShadow: controller.lowerEndPositionSet ? null : [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.save),
                                  onPressed: () => controller.setLowerEndPosition(() => setState(() {})),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: controller.lowerEndPositionSet
                                      ? () => controller.deleteLowerEndPosition(() => setState(() {}))
                                      : null,
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/images/behang_down.png',
                              // width: 64,
                              // height: 64,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: !controller.upperEndPositionSet && controller.lowerEndPositionSet
                              ? Border.all(color: theme.colorScheme.primary)
                              : null,
                          boxShadow: !controller.upperEndPositionSet && controller.lowerEndPositionSet
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.save),
                                  onPressed: controller.lowerEndPositionSet
                                      ? () => controller.setUpperEndPosition(() => setState(() {}))
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: controller.upperEndPositionSet
                                      ? () => controller.deleteUpperEndPosition(() => setState(() {}))
                                      : null,
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/images/behang_up.png',
                              // width: 64,
                              // height: 64,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text(""),
                            onPressed: () => controller.resetRotaryDirection(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => controller.deleteEndPositions(() => setState(() {})),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("DELETE ALL"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: UICBigMove(
                      onUp: () {
                        timer?.cancel();
                        timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
                          xcf.sendCommand(XCFCommand.DI_AUF);
                        });
                      },
                      onStop: () {
                        timer?.cancel();
                      },
                      onDown: () {
                        timer?.cancel();
                        timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
                          xcf.sendCommand(XCFCommand.DI_AB);
                        });
                      },
                      onRelease: () {
                        timer?.cancel();
                        controller.updateSetupState().then((_) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        //TODO: get rid of these sized boxes
        SizedBox(height: theme.defaultWhiteSpace),
        SizedBox(height: theme.defaultWhiteSpace),
        SizedBox(height: theme.defaultWhiteSpace),
      ],
    );
  }
}