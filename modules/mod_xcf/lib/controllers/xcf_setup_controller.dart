part of '../module.dart';

class XCFSetupController {
  final XCFProtocol xcf;
  final BuildContext context;

  XCFSetupController({
    required this.xcf,
    required this.context,
  });

  XCFSetupState? setupState;
  bool lowerEndPositionSet = false;
  bool upperEndPositionSet = false;
  bool rotaryDirectionSet = false;
  bool rotaryDirection = false;

  final ValueNotifier<double> position = ValueNotifier(0);
  Timer? positionTimer;
  Timer? movementTimer;

  Future<void> init() async {
    final dt = await xcf.getDwellTime();
    setupState = await xcf.readSetup();

    upperEndPositionSet = setupState?.posAufBekannt ?? false;
    lowerEndPositionSet = setupState?.posZuBekannt ?? false;
    rotaryDirectionSet = upperEndPositionSet || lowerEndPositionSet;
  }

  Future<void> updateSetupState() async {
    setupState = await xcf.readSetup();
  }

  Future<void> toggleRotaryDirection() async {
    rotaryDirection = !rotaryDirection;
    await xcf.toggleRotaryDirection(rotaryDirection ? 0 : 1);
  }

  void confirmRotaryDirection() {
    rotaryDirectionSet = true;
  }

  void resetRotaryDirection() {
    rotaryDirectionSet = false;
  }

  Future<void> setUpperEndPosition(VoidCallback onUpdate) async {
    if (upperEndPositionSet) {
      await xcf.setEndPosition(XCFEndPosition.upper);
    }
    await xcf.sendCommand(XCFCommand.DI_PROG);
    upperEndPositionSet = true;
    onUpdate();
  }

  Future<void> setLowerEndPosition(VoidCallback onUpdate) async {
    if (lowerEndPositionSet) {
      await xcf.setEndPosition(XCFEndPosition.lower);
    }
    await xcf.sendCommand(XCFCommand.DI_PROG);
    lowerEndPositionSet = true;
    onUpdate();
  }

  Future<void> setIntermediatePosition () async {
    await xcf.setIntermediatePosition(XCFIntermediatePosition.free);
    await xcf.sendCommand(XCFCommand.DI_PROG);
  }

  Future<void> deleteUpperEndPosition(VoidCallback onUpdate) async {
    final  messenger = UICMessenger.of(context);
    final confirm = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlage oben löschen".i18n,
      child: Text("Sind Sie sicher, dass Sie die obere Endlage löschen möchten?".i18n),
    ));
    if (confirm == true) {
      await xcf.setEndPosition(XCFEndPosition.upper);
      upperEndPositionSet = false;
      onUpdate();
    }
  }

  Future<void> deleteLowerEndPosition(VoidCallback onUpdate) async {
    final  messenger = UICMessenger.of(context);
    final confirm = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlage unten löschen".i18n,
      child: Text("Sind Sie sicher, dass Sie die untere Endlage löschen möchten?".i18n),
    ));
    if (confirm == true) {
      await xcf.setEndPosition(XCFEndPosition.lower);
      lowerEndPositionSet = false;
      onUpdate();
    }
  }

  Future<void> deleteEndPositions(VoidCallback onUpdate) async {
    final  messenger = UICMessenger.of(context);
    final confirm = await messenger.alert(UICSimpleConfirmationAlert(
      title: "Endlagen zurücksetzen".i18n,
      child: Text("Sind Sie sicher, dass Sie beide Endlagen zurücksetzen möchten?".i18n),
    ));
    if (confirm == true) {
      await xcf.setEndPosition(XCFEndPosition.deleteUpperLower);
      lowerEndPositionSet = false;
      upperEndPositionSet = false;
      onUpdate();
    }
  }

  void dispose() {
    positionTimer?.cancel();
    movementTimer?.cancel();
    position.dispose();
  }
}