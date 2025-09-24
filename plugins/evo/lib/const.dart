part of evo_protocol;

const kEvoModbusWriteFlag = 0x40;

enum EvoOperationMode {
  standard(1, "Standardbetrieb"),
  whisper(2, "Flüsterbetrieb"),
  adaptive(3, "Dynamikbetrieb");

  const EvoOperationMode(this.value, String name) : _name = name;
  final int value;
  final String _name;

  String get name => _name;

  static EvoOperationMode fromInt(int? mode) {
    switch(mode) {
      case 1: return EvoOperationMode.standard;
      case 2: return EvoOperationMode.whisper;
      case 3: return EvoOperationMode.adaptive;
      default: return EvoOperationMode.standard;
    }
  }
}

enum EvoSettingsAddress {
  flyscreen(0x01),
  antifreeze(0x02),
  endposition(0x43),
  rampConfiguration(0xFF);

  const EvoSettingsAddress(this.value);
  final int value;
}

// enum EvoEndPosition {
//   upper(0x00),
//   lower(0x01),
//   clear(0x04);
//   const EvoEndPosition(this.value);
//   final int value;
// }

enum EvoModbusStatusXCodes {
  mmaxRightLeft(0x00), /// Mmax rechts / links
  driveStatusNotActive(0x01), /// SMI nichtaktiv 
  serialNumber(0x02), /// Seriennummer
  additionalFunction(0x03),
  cycleCounter(0x04),
  driveStatusActive(0x05), /// SMI aktiv
  changeFlags(0x06),
  driveStatusPower(0x07), /// nach SMI Power-up
  testInfo(0x08),
  softwareId(0x09),
  driveInfo(0x0a),
  basicConfiguration(0x0b);

  const EvoModbusStatusXCodes(this.value);
  final int value;
}

enum EvoModbusStatusPos12XCodes {
  statusPos12XIstPos(0x00),
  statusPos12XPos1(0x01),
  statusPos12XPos2(0x02),
  statusPos12XPos3(0x03);

  const EvoModbusStatusPos12XCodes(this.value);
  final int value;
}

enum EvoModbusStatusEndPositionCodes {
  statusEndPositionTop(0x00),
  statusEndPositionBottom(0x01);

  const EvoModbusStatusEndPositionCodes(this.value);
  final int value;
}

enum EvoModbusProtocolState {
  protocolWaitResponse,
  protocolRcvStart,
  protocolRcvEnd,
  protocolUndef,
  protocolErrorLen,
  protocolErrorCrc
}

enum EvoModbusErrorCodes {
  ok(0x00),
  systemHardware(0x01),
  bufferOverflow(0x02),
  invalidAddress(0x03),
  invalidCommand(0x04),
  accessReadOnly(0x05),
  checksum(0x06);

  const EvoModbusErrorCodes(this.value);
  final int value;
}

enum EvoModbusSpeedAttributes {
  speedAttrCurrentProf, /// no value,     
  speedAttrStandardProf, /// no value,
  speedAttrQuietProf, /// no value,
  speedAttrDynamicProf, /// no value,
  speedAttrAlarm, /// no value,
  speedAttrSlowest, /// no value,
  speedAttrPerc, /// value 8bit: 0..255 => 0..100%; with flags
  speedAttrPriRpm10, /// value 16bit: 0..SPEED_MAX_RPM primary shaft in RPM; no flags 
  speedAttrSecRpm02, /// value  8bit: 0..250 => 0..50,0 rpm; with flags
  speedAttrSecRpm01 /// value 16bit: 0..60000 => 0..60,000rpm; no flags (SMI 0.1rpm resolution) 
}

enum EvoModbusSpeedFlags {
  rampUpOff, /// no ramp up
  rampUpShort, /// short ramp up
  rampUpMedium, /// medium ramp up
  rampUpLong, /// long ramp up
  rampDnOff, /// no ramp down
  rampDnShort, /// short ramp down
  rampDnMedium, /// medium ramp down
  rampDnLong, /// long ramp down
  rampStopOff, /// no ramp stop
  rampStopOn /// ramp stop
}

enum EvoModbusSpeedFlagsUp {
  rampUpOff(0x00),
  rampUpShort(0x01),
  rampUpMedium(0x02),
  rampUpLong(0x03);

  const EvoModbusSpeedFlagsUp(this.value);
  final int value;
}

enum EvoModbusSpeedFlagsDn {
  rampDnOff(0x00),
  rampDnShort(0x04),
  rampDnMedium(0x08),
  rampDnLong(0x0C);

  const EvoModbusSpeedFlagsDn(this.value);
  final int value;
}

enum EvoModbusSpeedFlagsStop {
  rampStopOff(0x00),
  rampStopOn(0x10);

  const EvoModbusSpeedFlagsStop(this.value);
  final int value;
}

enum EvoServiceCommandCodes {
  reqStatus(0x00),
  respStatus(0x80),
  reqEepromRead(0x01),
  respEepromRead(0x81),
  reqEepromWrite(0x11),
  respEepromWrite(0x91),
  reqRamRead(0x02),
  respRamRead(0x82),
  reqConfigRead(0x03),
  respConfigRead(0x83),
  reqConfigWrite(0x13),
  respConfigWrite(0x93),
  reqParatelegrWrite(0x17),
  respParatelegrWrite(0x97),
  reqDiagRead(0x04),
  respDiagRead(0x84),
  reqSettingRead(0x05),
  respSettingRead(0x85),
  reqSettingWrite(0x15),
  respSettingWrite(0x95),
  reqFlashRead(0x06),
  respFlashRead(0x86),
  reqFlashWrite(0x16),
  respFlashWrite(0x96),
  reqSeepromRead(0x08),
  respSeepromRead(0x88),
  reqSeepromWrite(0x18),
  respSeepromWrite(0x98),
  reqDbRead(0x09),
  respDbRead(0x89),
  reqDbWrite(0x19),
  respDbWrite(0x99),
  reqDatapointRead(0x0a),
  respDatapointRead(0x8a),
  reqDatapointMetaRead(0x0b),
  respDatapointMetaRead(0x8b),
  reqDatapointWrite(0x1a),
  respDatapointWrite(0x9a),
  reqControlBmiGet(0x0fbaa50f2c),
  respControlBmiGet(0x8f),
  reqControlAppmGet(0x0f4150504d),
  respControlAppmGet(0x8f),
  reqControlBmiSet(0x1fbaa50f2c),
  respControlBmiSet(0x9f),
  reqControlAppmSet(0x1f4150504d),
  respControlAppmSet(0x9f),
  reqControlReset(0x1fba5af0c3),
  respControlReset(0x9f),
  reqUserSignal(0x20),
  reqModbusOverBle(0x2b),
  respModbusOverBle(0xab),
  respUserSignal(0xa0);

  const EvoServiceCommandCodes(this.value);
  final int value;
}

enum EvoServiceResponseWithErrorCode {
  respEepromRead,
  respEepromWrite,
  respSeepromRead,
  respSeepromWrite,
  respDbRead,
  respDbWrite,
  respRamRead,
  respConfigRead,
  respConfigWrite,
  respParatelegrWrite,
  respDiagRead,
  respSettingWrite,
  respFlashRead,
  respFlashWrite,
  respControlBmiGet,
  respControlAppmGet,
  respControlBmiSet,
  respControlAppmSet,
  respControlReset,
  respUserSignal,
  respDatapointRead,      /// MC → BC Antwort: Lesen eines Datenpunktes/Datenpuffers
  respDatapointMetaRead,  /// MC → BC Antwort: Lesen der Metadaten eines Datenpunktes/Da
  respDatapointWrite      /// MC → BC Antwort: Schreiben eines Datenpunktes/Datenpuffers
}

enum EvoServiceResponseErrorCodes {
  none,
  locked,
  moving,
  noPower,
  invalidPara,
  noAccess,
  eepromBusy,
  resetPending,
  incompatiblePara,
  invalidLength,
  eepromWrite,
  failed,
  appRunning
}

enum EvoServiceProtocolState {
  protocolWaitResponse,
  protocolRcvStart,
  protocolRcvEnd,
  protocolUndef,
  protocolErrorLen,
  protocolErrorCrc
}

enum EvoModbusAddressCodes {
  moveCommand(0x00),
  upStep(0x01),
  downStep(0x02),
  progSetupParameters(0x03),
  // moveToPos(0x20), /// use EvoModbusSetPositionxAdressCodes
  // setPos1To(0x21), /// use EvoModbusSetPositionxAdressCodes
  // setPos2To(0x22), /// use EvoModbusSetPositionxAdressCodes
  // setPos3To(0x23), /// use EvoModbusSetPositionxAdressCodes
  readPositionX(0x30), /// FC → MC Command (1Byte)
  readStatusEndPositionX(0x31), /// FC → MC Up-Step (1Byte)
  readSystemStatus(0x32),
  readSystemEvents(0x33), /// FC → MC Functions (1Byte)
  readManInfo(0x34), /// FC → MC Functions (1Byte)


  readParB1B4(0x36),
  readParB5B8(0x37),
  readParB9B12(0x38),
  readParB13B16(0x39),
  readParB17B20(0x3a),
  readParB21B24(0x3b),
  readParB25B28(0x3c),
  readParB29B32(0x3d),
  readParB33B36(0x3e),
  readParUpdate(0x3f),
  
  error(0x80); /// MC → FC Error (1Byte)

  const EvoModbusAddressCodes(this.value);
  final int value;
}

enum EvoModbusSetPositionXAdressCodes {
  moveToPos(0x20),
  setPos1To(0x21),
  setPos2To(0x22),
  setPos3To(0x23);

  const EvoModbusSetPositionXAdressCodes(this.value);
  final int value;
}

enum EvoModbusSetPositionXPosition {
  setPosition(0xFF),
  position1(0x00),
  position2(0x01),
  position3(0x02);

  const EvoModbusSetPositionXPosition(this.value);
  final int value;
}

enum EvoModbusMoveCommandCodes {
  stop(0x00),
  up(0x01),
  down(0x02),
  position1Move(0x03),
  position2Move(0x04),
  position1Set(0x05),
  position2Set(0x06),
  position1Clear(0x07),
  position2Clear(0x08),
  position3Move(0x09),
  position3Set(0x0a),
  position3Clear(0x0b);

  const EvoModbusMoveCommandCodes(this.value);
  final int value;
}

enum EvoModbusSetupFunctionCodes {
  progTopEndPositionHere(0x00),
  progBottomEndPositionHere(0x01),
  clearTopEndPositionWith2Clacks(0x02),
  clearBottomEndPositionWith2Clacks(0x03),
  clearTopBottomEndPosition(0x04),
  wave(0x05),
  fixedFrostProtectionOn(0x06),
  fixedFrostProtectionOff(0x07),
  flyScreenProtectionOn(0x08),
  flyScreenProtectionOff(0x09),
  blockRepetitionOn(0x0a),
  blockRepetitionOff(0x0b),
  obstacleRepetitionOn(0x0c),
  obstacleRepetitionOff(0x0d),
  topStopSoft(0x0e),
  topStopHard(0x0f),
  bottomStopSoft(0x10),
  bottomStopHard(0x11),
  topReversalOn(0x12),
  topReversalOff(0x13),
  bottomReversalOn(0x14),
  bottomReversalOff(0x15),
  setTopReversalPointHere(0x16),
  setBottomReversalPointHere(0x17),
  lockStepCommand(0x18),
  unlockStepCommand(0x19),
  progReset(0x1a),
  progSet(0x1b),
  progSet1(0x1c),
  setInstallationDirectionLeftIsBottom(0x1d),
  setInstallationDirectionRightIsBottom(0x1e),
  additionalFunctionCommBoardEnable(0x1f),
  additionalFunctionCommBoardDisable(0x20),
  clack1(0x21),
  clack2(0x22),
  clack3(0x23),
  clack4(0x24),
  clack5(0x25),
  clearUpperEndPositionSilent(0x26),
  clearLowerEndPositionSilent(0x27),
  invertRotaryDirection(0xfe),
  factoryReset(0xff),
  switchToBootLoader(0x1F);

  static EvoModbusSetupFunctionCodes fromInt(int value) {
    for(final e in EvoModbusSetupFunctionCodes.values) {
      if(e.value == value) {
        return e;
      }
    }
    throw ArgumentError("Unknown value $value");
  }

  const EvoModbusSetupFunctionCodes(this.value);
  final int value;
}

enum EvoModbusGetPositionXCommandCodes {
  currentPosition(0x00),
  position1(0x01),
  position2(0x02),
  position3(0x03);

  const EvoModbusGetPositionXCommandCodes(this.value);
  final int value;
}


enum EvoModbusReadEndPositionStatusX {
  upper(0x00),
  lower(0x01);

  const EvoModbusReadEndPositionStatusX(this.value);
  final int value;
}

enum EvoModbusReadEndPositionType {
  none, endPositionPoint, endPositionStop, endPositionSwing
}

enum EvoModbusSystemStatusXCommandCodes {
  statusModeUnchanged(0x00),
  statusModeRemoteOn(0x05),
  statusModeUnchangedClearFlags(0x07),
  serialNumber(0x02),
  statusSpecialFunction(0x03),
  statusCycleCounter(0x04),
  statusChangeflagsParameter(0x06),
  statusQAInfo(0x06),
  driveSoftwareId(0x09),
  
  lower(0x01);

  const EvoModbusSystemStatusXCommandCodes(this.value);
  final int value;
}