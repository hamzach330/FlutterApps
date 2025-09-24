part of evo_protocol;

extension EvoProtocol on Evo {
  /// !!!!!!!!!!!!!!!!!!!
  /// !! EVO INTERFACE !!
  /// !!!!!!!!!!!!!!!!!!!

  Future<EvoRampConfiguration?> getRampConfiguration() async {
    rampConfiguration = (await writeMessageWithResponse(
            EvoServiceRampConfigurationRead(escape: escape)))
        .configuration;

    await getFlyScreen();
    await getFreezeProtection();
    notifyListeners();
    return rampConfiguration;
  }

  Future<void> wink() async {
    final response =
        await writeMessageWithResponse(EvoServiceWinkRequest(escape: escape));
    dev.log("$response");
  }

  Future<void> setFlyScreen(bool value) async {
    await writeMessageWithResponse(EvoServiceWriteSetting(
        escape: escape, value: value, setting: EvoSettingsAddress.flyscreen));
    flyScreenEnabled = value;
    notifyListeners();
  }

  Future<void> getFlyScreen() async {
    final result = await writeMessageWithResponse(EvoServiceReadSetting(
        escape: escape, setting: EvoSettingsAddress.flyscreen));

    flyScreenEnabled = result.unpackedResponse?[2] == 1;
    notifyListeners();
  }

  Future<void> setFreezeProtection(bool value) async {
    await writeMessageWithResponse(EvoServiceWriteSetting(
        escape: escape, value: value, setting: EvoSettingsAddress.antifreeze));
    freezeProtectEnabled = value;
    notifyListeners();
  }

  Future<void> getFreezeProtection() async {
    final result = await writeMessageWithResponse(EvoServiceReadSetting(
        escape: escape, setting: EvoSettingsAddress.antifreeze));

    freezeProtectEnabled = result.unpackedResponse?[2] == 1;
    notifyListeners();
  }

  Future<void> setRampConfiguration() async {
    await writeMessageWithResponse(EvoServiceRampConfigurationWriteRequest(
      escape: escape,
      configuration: rampConfiguration,
    ));

    notifyListeners();
  }

  /// !!!!!!!!!!!!!!!!!!!!
  /// !!MODBUS INTERFACE!!
  /// !!!!!!!!!!!!!!!!!!!!

  Future<void> move(int direction) async {
    EvoModbusMoveCommandCodes command;
    if (direction == 0) {
      command = EvoModbusMoveCommandCodes.stop;
      _queue.wipe();
    } else if (direction == -1) {
      command = EvoModbusMoveCommandCodes.up;
    } else if (direction == 1) {
      command = EvoModbusMoveCommandCodes.down;
    } else {
      throw Exception("Invalid direction");
    }

    await writeMessageWithResponse(
        EvoModbusWriteMoveCommand(escape: escape, command: command));
  }

  Future<void> moveTo(double position) async {
    final epTopInfo = await getUpperEndPositionStatus();
    final epBottomInfo = await getLowerEndPositionStatus();
    
    final currentPosition = await writeMessageWithResponse(
        EvoModbusReadPositionX(
            escape: escape,
            command: EvoModbusGetPositionXCommandCodes.currentPosition));

    final upper = epTopInfo.point > epBottomInfo.point
        ? epTopInfo.point
        : epBottomInfo.point;

    final lower = epTopInfo.point < epBottomInfo.point
        ? epTopInfo.point
        : epBottomInfo.point;

    if (lower == upper ||
        epBottomInfo.type == EvoModbusReadEndPositionType.none ||
        epTopInfo.type == EvoModbusReadEndPositionType.none) {
      throw Exception("Endposition setup incomplete or invalid");
    }

    final maxWay = upper - lower;

    final moveToPoint = ((100 - position) * (maxWay / 100)) + lower;

    await writeMessageWithResponse(EvoModbusSetPositionX(
        escape: escape,
        address: EvoModbusSetPositionXAdressCodes.moveToPos,
        position: EvoModbusSetPositionXPosition.setPosition,
        point: moveToPoint.toInt()));

    dev.log(
        "Current: ${currentPosition.point} (${((upper - currentPosition.point) / maxWay * 100).toInt()}%)");
    dev.log("Upper: ${epTopInfo.point} Type: ${epTopInfo.type}");
    dev.log("Lower: ${epBottomInfo.point} Type: ${epBottomInfo.type}");
    dev.log("DriveWay: $maxWay");
    dev.log("MoveTo: $moveToPoint (${position.toInt()}%)");
  }

  /// MOVE COMMANDS (ADDRES 0x00)

  Future<void> setIntermediatePosition1Here() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position1Set));
  }

  Future<void> setIntermediatePosition2Here() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position2Set));
  }

  Future<void> setIntermediatePosition3Here() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position3Set));
  }

  Future<void> clearIntermediatePosition1() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position1Clear));
  }

  Future<void> clearIntermediatePosition2() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position2Clear));
  }

  Future<void> clearIntermediatePosition3() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position3Clear));
  }

  Future<void> moveToIntemediatePosition1() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position1Move));
  }

  Future<void> moveToIntemediatePosition2() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position2Move));
  }

  Future<void> moveToIntemediatePosition3() async {
    await writeMessageWithResponse(EvoModbusWriteMoveCommand(
        escape: escape, command: EvoModbusMoveCommandCodes.position3Move));
  }

  Future<void> clearIntermediatePositions() async {
    await clearIntermediatePosition1();
    await clearIntermediatePosition2();
    await clearIntermediatePosition3();
  }

  /// FUNCTION CODES (ADDRESS 0x03)

  Future<void> setUpperEndpositionHere() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.progTopEndPositionHere));
  }

  Future<void> setLowerEndpositionHere() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.progBottomEndPositionHere));
  }

  Future<void> clearLowerEndpositionConfirmed() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.clearBottomEndPositionWith2Clacks));
  }

  Future<void> clearUpperEndpositionConfirmed() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.clearTopEndPositionWith2Clacks));
  }

  Future<void> deleteEndpositions() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.clearTopBottomEndPosition));
  }

  Future<void> wave() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.wave));
  }

  Future<void> setFrostProtection(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.fixedFrostProtectionOn
            : EvoModbusSetupFunctionCodes.fixedFrostProtectionOff));
  }

  /// ! If you are using an evo+ device, it's recommended to use the [setFlyScreen] method
  /// Enable fly screen protection via Modbus
  Future<void> setFlyScreenMB(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.flyScreenProtectionOn
            : EvoModbusSetupFunctionCodes.flyScreenProtectionOff));
  }

  Future<void> setBlockRepetition(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.blockRepetitionOn
            : EvoModbusSetupFunctionCodes.blockRepetitionOff));
  }

  Future<void> setObstacleRepetition(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.obstacleRepetitionOn
            : EvoModbusSetupFunctionCodes.obstacleRepetitionOff));
  }

  Future<void> setTopStopSoft() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.topStopSoft));
  }

  Future<void> setTopStopHard() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.topStopHard));
  }

  Future<void> setBottomStopSoft() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.bottomStopSoft));
  }

  Future<void> setBottomStopHard() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.bottomStopHard));
  }

  Future<void> setTopReversal(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.topReversalOn
            : EvoModbusSetupFunctionCodes.topReversalOff));
  }

  Future<void> setBottomReversal(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.bottomReversalOn
            : EvoModbusSetupFunctionCodes.bottomReversalOff));
  }

  Future<void> setTopReversalPoint() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.setTopReversalPointHere));
  }

  Future<void> setBottomReversalPoint() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.setBottomReversalPointHere));
  }

  Future<void> setLockStepCommand(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.lockStepCommand
            : EvoModbusSetupFunctionCodes.unlockStepCommand));
  }

  Future<void> setProgReset() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.progReset));
  }

  Future<void> setProgSet() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.progSet));
  }

  Future<void> setProgSet1() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.progSet1));
  }

  Future<void> setInstallationDirectionLeftIsBottom() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option:
            EvoModbusSetupFunctionCodes.setInstallationDirectionLeftIsBottom));
  }

  Future<void> setInstallationDirectionRightIsBottom() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option:
            EvoModbusSetupFunctionCodes.setInstallationDirectionRightIsBottom));
  }

  Future<void> setAdditionalFunctionCommBoardEnable(bool on) async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: on
            ? EvoModbusSetupFunctionCodes.additionalFunctionCommBoardEnable
            : EvoModbusSetupFunctionCodes.additionalFunctionCommBoardDisable));
  }

  Future<void> clack(int count) async {
    if (count > 4) {
      throw ArgumentError("Count cannot be greater than 4");
    }
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.fromInt(
            EvoModbusSetupFunctionCodes.clack1.value + count)));
  }

  Future<void> clearUpperEndPositionSilent() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.clearUpperEndPositionSilent));
  }

  Future<void> clearLowerEndPositionSilent() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.clearLowerEndPositionSilent));
  }

  Future<void> invertRotaryDirection() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.invertRotaryDirection));
  }

  Future<void> factoryReset() async {
    await writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape, option: EvoModbusSetupFunctionCodes.factoryReset));
  }

  Future<void> switchToBootLoader() {
    return writeMessageWithResponse(EvoModbusSetupFunction(
        escape: escape,
        option: EvoModbusSetupFunctionCodes.switchToBootLoader));
  }

  Future<EvoModbusReadEndPositionStatus> getUpperEndPositionStatus() async {
    return await writeMessageWithResponse(EvoModbusReadEndPositionStatus(
        escape: escape, endPosition: EvoModbusReadEndPositionStatusX.upper));
  }

  Future<EvoModbusReadEndPositionStatus> getLowerEndPositionStatus() async {
    return await writeMessageWithResponse(EvoModbusReadEndPositionStatus(
        escape: escape, endPosition: EvoModbusReadEndPositionStatusX.lower));
  }

  Future<double> getCurrentPosition() async {
    final epTopInfo = await getUpperEndPositionStatus();
    final epBottomInfo = await getLowerEndPositionStatus();

    final currentPosition = await writeMessageWithResponse(
        EvoModbusReadPositionX(
            escape: escape,
            command: EvoModbusGetPositionXCommandCodes.currentPosition));

    final upper = epTopInfo.point > epBottomInfo.point
        ? epTopInfo.point
        : epBottomInfo.point;

    final lower = epTopInfo.point < epBottomInfo.point
        ? epTopInfo.point
        : epBottomInfo.point;

    if (lower == upper ||
        epBottomInfo.type == EvoModbusReadEndPositionType.none ||
        epTopInfo.type == EvoModbusReadEndPositionType.none) {
      throw Exception("Endposition setup incomplete or invalid");
    }

    final maxWay = upper - lower;

    final retval = (upper - currentPosition.point) / maxWay * 100;

    return min(100, max(0, retval));
  }

  /// SET POSITION COMMANDS (ADDRESS 0x20, 0x21, 0x22, 0x23)

  Future<void> setPositionTo(int point,
      {intermediatePosition =
          EvoModbusSetPositionXPosition.setPosition}) async {
    await writeMessageWithResponse(EvoModbusSetPositionX(
        escape: escape,
        address: EvoModbusSetPositionXAdressCodes.moveToPos,
        position: intermediatePosition,
        point: point));
  }

  Future<void> setIntermediatePosition1To(int point) async {
    await writeMessageWithResponse(EvoModbusSetPositionX(
        escape: escape,
        address: EvoModbusSetPositionXAdressCodes.setPos1To,
        point: point));
  }

  Future<void> setIntermediatePosition2To(int point) async {
    await writeMessageWithResponse(EvoModbusSetPositionX(
        escape: escape,
        address: EvoModbusSetPositionXAdressCodes.setPos2To,
        point: point));
  }

  Future<void> setIntermediatePosition3To(int point) async {
    await writeMessageWithResponse(EvoModbusSetPositionX(
        escape: escape,
        address: EvoModbusSetPositionXAdressCodes.setPos3To,
        point: point));
  }

  /// READ ENDPOSITION COMMANDS (ADDRES 0x30)

  Future<int> getIntermediatePosition1() async {
    final response = await writeMessageWithResponse(EvoModbusReadPositionX(
        escape: escape, command: EvoModbusGetPositionXCommandCodes.position1));
    dev.log("Position: ${response.point}");
    return response.point;
  }

  Future<int> getIntermediatePosition2() async {
    final response = await writeMessageWithResponse(EvoModbusReadPositionX(
        escape: escape, command: EvoModbusGetPositionXCommandCodes.position2));
    dev.log("Position: ${response.point}");
    return response.point;
  }

  Future<int> getIntermediatePosition3() async {
    final response = await writeMessageWithResponse(EvoModbusReadPositionX(
        escape: escape, command: EvoModbusGetPositionXCommandCodes.position3));
    dev.log("Position: ${response.point}");
    return response.point;
  }
}
