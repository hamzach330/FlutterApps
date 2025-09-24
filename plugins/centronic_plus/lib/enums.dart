part of 'centronic_plus.dart';

/// Hey, that's us!
/// Becker Antriebe GmbH
const CP_MAN_BECKER = 0x01;

const CP_EMPTY_MAC = "0000000000000000";
const CP_ALL_GROUPS = "00000000";
const CP_ROOT_MAC = "0100000000000000";

enum CPInitiator {
  /// Simple switch (up down stop) without shift switch EC541/8/16 PLUS
  easy(0x00, "EASY"),

  /// (Unused) Simple switch with shift switch (memo)
  easySwitch(0x01, "EASY_SWITCH"),

  /// (Unused) Clock switch
  clock(0x02, "CLOCK"),

  /// (Unused) Priority switch (Central Command)
  centralPrio(0x03, "CENTRAL_PRIO"),

  /// One / (or and) Two button switch
  oneTwo(0x04, "ONE_TWO"),

  /// (Unused) Light switch / dimming control
  lightDim(0x05, "LIGHT_DIM"),

  /// Sunshield protection control switch SWC541/8/16 PLUS
  marki(0x06, "MARKI"),

  /// (Unused) Jalousie control switch
  jalousie(0x07, "JALOUSIE"),

  /// (Unused) Sunshield protection sensor
  markiSens(0x08, "MARKI_SENS"),

  /// Sunshield protection sensor secure-controlled SC911
  markiSensSec(0x09, "MARKI_SENS_SEC"),

  /// (Unused) Jalousie sensor
  jalSens(0x0A, "JAL_SENS"),

  /// (Unused) Jalousie sensor secure-controlled
  jalSensSec(0x0B, "JAL_SENS_SEC"),

  /// (Unused) Roller shutter sensor
  rolloSens(0x0C, "ROLLO_SENS"),

  /// (Unused) Living room sensor (inside)
  inroomSens(0x0D, "INROOM_SENS"),

  /// (Unused) Sensor reserved 0
  res0Sens(0x0E, "RES0_SENS"),

  /// (Unused) Sensor reserved 1
  res1Sens(0x0F, "RES1_SENS"),

  /// (Unused) SHUTTER...SUNSHIELD...JAL..LIGHT Actuator Universal Relais/IO/BUS
  uniVcactor(0x10, "UNI_VCACTOR"),

  /// Roller shutter drive C01 PLUS / VC420, VC520, VC 470 rollo-mode
  rolloDrive(0x11, "ROLLO_DRIVE"),

  /// BLDC drive
  bldc(0x12, "BLDC"),

  /// Sunshield protection drive C12 PLUS VC420, VC520, VC 470 sun-mode
  sunDrive(0x13, "SUN_DRIVE"),

  /// Sunshield protection drive C12 EVO PLUS
  sunDriveBldc(0x14, "SUN_DRIVE_BLDC"),

  /// Sunshield protection drive Jalousie VC420, VC520, VC 470 jalousie-mode
  sunDriveJal(0x15, "SUN_DRIVE_JAL"),

  /// Sunshield protection drive ZIP C18 PLUS
  sunDriveZip(0x16, "SUN_DRIVE_ZIP"),

  /// Sunshield protection drive ZIP C18 EVO PLUS
  sunDriveZipBldc(0x17, "SUN_DRIVE_ZIP_BLDC"),

  /// Sunshield protection drive Screen C16 PLUS
  sunDriveScreen(0x18, "SUN_DRIVE_SCREEN"),

  /// Sunshield protection drive Screen C16 EVO PLUS
  sunDriveScreenBldc(0x19, "SUN_DRIVE_SCREEN_BLDC"),

  /// Sunshield protection drive Sun sail C23 PLUS
  sunDriveSail(0x1A, "SUN_DRIVE_SAIL"),

  /// Sunshield protection drive Sun sail C23 EVO PLUS
  sunDriveSailBldc(0x1B, "SUN_DRIVE_SAIL_BLDC"),

  /// (Unused) Actuator Glass Dimming
  actGlassDim(0x1C, "ACT_GLASS_DIM"),

  /// Actuator Switch / Dimming VC420, VC520, VC 470, LC120 switch-mode
  actSwitchDim(0x1D, "ACT_SWITCH_DIM"),

  /// Sunshield protection drive Volant
  sunDriveVolant(0x1E, "SUN_DRIVE_VOLANT"),

  /// Actuator impulse Light LC120 impulse-mode
  actImpulseLight(0x1F, "ACT_IMPULSE_LIGHT"),

  /// Actuator Way â€“ Light LC120 way light-mode
  actWayLight(0x20, "ACT_WAY_LIGHT"),

  /// Actuator Impulse Shutter / Door Becker BUS 0,6 s Up / Down - 0,2 s Stop VC520 impulse-mode
  actImpulseShutter(0x21, "ACT_IMPULSE_SHUTTER"),

  /// Actuator garage door
  actDoor(0x22, "ACT_DOOR"),

  /// (Unused) Parameter for Roller shutter drives
  parRollo(0x23, "PAR_ROLLO"),

  /// (Unused) Parameter for BLDC drives
  parBldc(0x24, "PAR_BLDC"),

  /// (Unused) Parameter for Sun shield protection drives
  parMarki(0x25, "PAR_MARKI"),

  /// (Unused) Parameter for Sun shield protection drives (insight)
  parMarkiIns(0x26, "PAR_MARKI_INS"),

  /// (Unused) Parameter for Jalousie drives
  parJal(0x27, "PAR_JAL"),

  /// (Unused) Parameter for ZIP drive
  parZip(0x28, "PAR_ZIP"),

  /// (Unused) Parameter for Clock
  parClock(0x29, "PAR_CLOCK"),

  /// (Unused) Parameter for Sun shield sensor
  parMarkiSens(0x2A, "PAR_MARKI_SENS"),

  /// (Unused) Parameter for Sun sailing device
  parSunSail(0x2B, "PAR_SUN_SAIL"),

  /// (Unused) Parameter for Jalousie
  parJalousie(0x2C, "PAR_JALOUSIE"),

  /// (Unused) Parameter for Window
  parWindow(0x2D, "PAR_WINDOW"),

  /// (Unused) Parameter for Actuator Glass â€“ Dimming
  parActGlasDim(0x2E, "PAR_ACT_GLAS_DIM"),

  /// (Unused) Parameter for Actuator Switch / Dimmer
  parActSwitchDim(0x2F, "PAR_ACT_SWITCH_DIM"),

  /// (Unused) Testing Serial Production
  serialTest(0x30, "SERIAL_TEST"),

  /// (Unused) Service Tool
  service(0x31, "SERVICE"),

  /// (Unused) Parameter Tool
  paramtool(0x32, "PARAMTOOL"),

  /// (Unused) Repeater Dummy Device for
  repeater(0x33, "REPEATER"),

  /// Central Control 0 Basiskanal IP FF80:0:..:1: CC41â€¦
  central0(0x34, "CENTRAL0"),

  /// Central Control 1 Homee
  central1(0x35, "CENTRAL1"),

  /// Central Control 2
  central2(0x36, "CENTRAL2"),

  /// Bootloader
  bootloader(0x37, "BOOTLOADER"),

  /// Reserved
  res0(0x38, "RES0"),

  /// Reserved
  res1(0x39, "RES1"),

  /// Reserved
  res2(0x3A, "RES2"),

  /// Reserved
  res3(0x3B, "RES3"),

  /// Reserved
  res4(0x3C, "RES4"),

  /// Reserved
  res5(0x3D, "RES5"),

  /// Reserved
  res6(0x3E, "RES6"),

  /// SC561
  sun(0x80, "SUN"),

  /// SC631
  sunDusk(0x81, "SUN_DUSK"),

  /// SC811, 861
  sunDuskWind(0x82, "SUN_DUSK_WIND"),

  /// SC911
  sunDuskWindHumTempout(0x83, "SUN_DUSK_WIND_HUM_TEMPOUT"),

  ///
  sunDuskTempin(0x84, "SUN_DUSK_TEMPIN"),

  ///
  sunDuskTempout(0x85, "SUN_DUSK_TEMPOUT"),

  ///
  sunDuskTempinPpm(0x86, "SUN_DUSK_TEMPIN_PPM"),

  /// SC711, 211
  wind(0x87, "WIND"),

  ///
  windHumTempout(0x88, "WIND_HUM_TEMPOUT"),

  ///
  humTempout(0x89, "HUM_TEMPOUT"),

  ///
  tempout(0x8A, "TEMPOUT"),

  ///
  tempin(0x8B, "TEMPIN"),

  ///
  ppm(0x8C, "PPM"),
  none(0xFF, "");

  const CPInitiator(this.value, this.name);
  final int value;
  final String name;
  String get hex => value.toRadixString(16).padLeft(2, '0');
}

enum CPRemoteActivity {
  up, down, stop, unknown
}

enum CPDatatype {
  /// Read TEXT 32 char len
  textRead32char(0x60),
  /// ???
  undocumented0x02(0x02),
  /// Write TEXT 32 char len
  textWrite32char(0x61),
  /// Reply TEXT 32 char len
  textReply32char(0x62),
  /// Standard Digital controls sets Command0 8Bit
  simpleDigital(0x00),
  /// 0x0D -nc-
  percentPower(0x0D),
  /// 0x0E Percent Position, Fully Opened: 0; Fully Closed = 0xFFFF Analog: Percent Position of Drive; Data 8/16 [PERCENT]
  percentPosition(0x0E),
  /// 0x0F Percent SLAT (Jalousie) Position, Fully Opened: 0; Fully Closed = 0xFFFF Analog: Percent Position of Drive; Data 8/16 [PERCENT]
  percentSlat(0x0F),
  /// 0x10 -nc-
  percentLight(0x10),
  /// 0x13 Max RunTime Drive Analog: Timeout Maximum Run-Time Drive; Data 8/16 [sec]
  maxRuntime(0x13),
  /// 0x14 Delay Time Release Out Analog: Timeout delay to react to outer Position; Data 8/16 [sec]
  delayTimeOut(0x14),
  /// 0x16 Delay Time Release In Analog: Timeout delay to react to inner Position; Data 8/16 [sec]
  delayTimeIn(0x16),
  /// 0x1B RunTime Intermediate Position 1 Analog: Timeout to run from upper Position to Intermediate Position 1; Data 8/16 [sec]
  runtimeCp1(0x1B),
  /// 0x1C RunTime Analog: Timeout to run from outer Position to Intermediate Position 2; Data 8/16 [sec]
  runtimeCp2(0x1C),
  /// 0x1F Intermediate Position 1 Enable Digital: Command1 - LSBit Position 0x00 or 0x01 (Enable)
  enCp1(0x1F),
  /// 0x20 Intermediate Position 2 Enable Digital: Command1 - LSBit Position 0x00 or 0x01 (Enable)
  enCp2(0x20),
  /// 0x22 Switchtime Automatic Enable by Clock Digital: Command1 - LSBit Position 0x00 or 0x01 (Enable) Command0 & UP
  enSwitchTime(0x22),
  /// 0x44 Command Out with Timed In -nd-
  cmdOutTimeIn(0x44),
  /// 0x45 Command In Timed Out -nd-
  cmdInTimeOut(0x45),
  /// 0x50 Analoge multi telegram
  anaMulti(0x50),
  /// 0x51 service telegram
  service(0x51),
  /// 0x52 Database lesen
  db(0x52),
  /// 0x53 Command control
  control(0x53),
  /// Status Page0 Standard Information
  page0(0x80),
  /// Status Page1 Motor specific 1
  page1(0x81),
  /// Status Page2 Motor specific 2
  page2(0x82),
  /// Status Page3 Parent MAC, Root, Pan-ID, Coupled
  page3(0x83),
  /// Status Page4 Root MAC, Root, Pan-ID, Coupled
  page4(0x84),
  /// Status Page4 Root MAC, Root, Pan-ID, Coupled
  special(0x90),
  /// Special command
  scResponse(0x70),
  /// Special command
  scSwReset(0x9F),
  /// Special command
  scFactoryResetAll(0x9E),
  /// Special command
  scFactoryResetCentronic(0x9D),
  /// Special command
  scFactoryResetCentronicPlus(0x9C),
  /// Special command
  scTiStop(0x9B),
  /// Special command
  scTiRestart(0x9A),
  /// Special command
  scCentronicLrearnTimerStop(0x99),
  /// Special command
  scCentronicDeleteTimerStart(0x98),
  /// Special command
  scCentronicLearnTimerStart(0x97),
  /// Special command
  scCentronicPowerOnTimerStart(0x96),
  /// Very special command
  scCentronicLearnDeleteTimersStop(0x99),
  /// Special command
  scTiEnable(0x95),
  /// Special command
  scTiDisable(0x94),
  /// Special command
  scRemoteDelete(0x93),
  /// If this is set the queue will skip the datatype check
  skipCheck(-1),

  none(0x00);

  const CPDatatype(this.value);
  final int value;
  String get hex => value.toRadixString(16).padLeft(2, '0');
}

enum CPKeycodes {
  prog(1 << 7),
  down(1 << 6),
  up(1 << 5),
  stop(1 << 4),
  shift(1 << 3),
  dt(1 << 2),
  s6(1 << 1),
  s3(1 << 0),
  s9(1 << 0 | 1 << 1),
  none(0x00);

  const CPKeycodes(this.value);
  final int value;
}

enum CPCapabilities {
  up,
  stop,
  down,
  position,
  preset1,
  preset2,
  on,
  off,
  toggle,
  dim,
}

class ProductDescriptor {
  final String name;
  final String id;
  final CPInitiator? initiator;

  const ProductDescriptor(
      {required this.name, required this.id, this.initiator});
}

abstract class ProductId {
  static ProductDescriptor? fromArtIdAndInitiator({required String artId, required CPInitiator initiator}) {
    final res = descriptors.keys.where((descriptor) {
      if (descriptors[descriptor]!.id == artId &&
          descriptors[descriptor]!.initiator == CPInitiator.none) {
        return true;
      } else {
        return descriptors[descriptor]!.id == artId &&
            descriptors[descriptor]!.initiator == initiator;
      }
    });
    if (res.isNotEmpty) {
      return descriptors[res.first];
    }
    return null;
  }

  static const Map<String, ProductDescriptor> descriptors = {
    "EC548"    : ProductDescriptor(name: "EC548 PLUS", id: "40367350020", initiator: CPInitiator.none,),
    "EC541"    : ProductDescriptor(name: "EC541 PLUS", id: "40367350060", initiator: CPInitiator.none,),
    "EC5416"   : ProductDescriptor(name: "EC5416 PLUS", id: "40367350070", initiator: CPInitiator.none,),
    "SWC541"   : ProductDescriptor(name: "SWC541 PLUS", id: "40367350090", initiator: CPInitiator.none,),
    "SWC548"   : ProductDescriptor(name: "SWC548 PLUS", id: "40367350100", initiator: CPInitiator.none,),
    "SWC5416"  : ProductDescriptor(name: "SWC5416 PLUS", id: "40367350110", initiator: CPInitiator.none,),
    "SWC541A"  : ProductDescriptor(name: "SWC541A PLUS", id: "40367350250", initiator: CPInitiator.none,),
    "SWC548A"  : ProductDescriptor(name: "SWC548A PLUS", id: "40367350260", initiator: CPInitiator.none,),
    "SWC5416A" : ProductDescriptor(name: "SWC5416A PLUS", id: "40367350270", initiator: CPInitiator.none,),
    "EC541A"   : ProductDescriptor(name: "EC541A PLUS", id: "40367350310", initiator: CPInitiator.none,),
    "EC548A"   : ProductDescriptor(name: "EC548A PLUS", id: "40367350320", initiator: CPInitiator.none,),
    "EC5416A"  : ProductDescriptor(name: "EC5416A PLUS", id: "40367350330", initiator: CPInitiator.none,),
    "vc420Plus": ProductDescriptor(id: "40367350050", initiator: CPInitiator.none, name: "VC420 PLUS"),
    "vc520Plus": ProductDescriptor(id: "40367350130", initiator: CPInitiator.none, name: "VC520 PLUS"),
    "vc470Plus": ProductDescriptor(id: "40367350140", initiator: CPInitiator.none, name: "VC470 PLUS"),
    "lc120Plus": ProductDescriptor(id: "40367350150", initiator: CPInitiator.none, name: "LC120 PLUS"),
    "vc180Plus": ProductDescriptor(id: "40367350380", initiator: CPInitiator.none, name: "VC180 PLUS"),
    "vc620Plus": ProductDescriptor(id: "40367350160", initiator: CPInitiator.none, name: "VC620 PLUS"),
    "vc670Plus": ProductDescriptor(id: "40367350170", initiator: CPInitiator.none, name: "VC670 PLUS"),
    "picoC01PLUS": ProductDescriptor(id: "49057350020", initiator: CPInitiator.rolloDrive, name: "Pico C01 PLUS"),
    "picoC12PLUS": ProductDescriptor(id: "49057350020", initiator: CPInitiator.sunDrive, name: "Pico C12 PLUS"),
    "picoC18PLUS": ProductDescriptor(id: "49057350020", initiator: CPInitiator.sunDriveZip, name: "Pico C18 PLUS"),
    "picoC16PLUS": ProductDescriptor(id: "49057350020", initiator: CPInitiator.sunDriveScreen, name: "Pico C16 PLUS"),
    "c01Plus": ProductDescriptor(id: "40247351720", initiator: CPInitiator.rolloDrive, name: "C01 PLUS"),
    "c12Plus": ProductDescriptor(id: "40247351720", initiator: CPInitiator.sunDrive, name: "C12 PLUS"),
    "c18Plus": ProductDescriptor(id: "40247351720", initiator: CPInitiator.sunDriveZip, name: "C18 PLUS"),
    "c16Plus": ProductDescriptor(id: "40247351720", initiator: CPInitiator.sunDriveScreen, name: "C16 PLUS"),
    "vc421Plus": ProductDescriptor(id: "40367350240", initiator: CPInitiator.oneTwo, name: "VC421 PLUS"),
  };
}

enum CPEVOProfile {
  none(0x00),
  speed(0x01),
  standard(0x02),
  quiet(0x03),
  dynamic(0x04),
  alarm(0x05),
  slowest(0x06);
  
  const CPEVOProfile(this.value);
  final int value;
}

const String MANUFACTURER = "01";
const String CP_DEFAULT_PORT = "07";
const String STORAGE_PATH = "config/.cen_plus_cache";

// CP_ORIGIN
enum CPOrigin {
  unknown,
  onNetwork,
  db,
  teachin,
  teachinAssociated,
}

// CP_ACCID
enum CPAccId {
  dataSendPanRn(0x00),
  dataSendPanRnUnicast(0x01),
  dataSendPanRnMulticast(0x02),
  dataSendPanRMulticast(0x09),
  dataSendPanBroadcast(0x08),
  dataSendWwwBroadcast(0x0E),
  readNeighborTab(0x10),
  readRoutingTab(0x11),
  updateUsb(0x1C),
  readPanId(0x17),
  readAllNodesStart(0x19),
  readAllNodesStop(0x1A),
  resetFactory(0x1D),
  readSwVersion(0x1E),
  resetStickDevice(0x1F),
  replyReadNeighborTab(0x20),
  replyReadRoutingTab(0x21),
  replyReadPanId(0x27),
  replyReadAllNodesStart(0x29),
  replyReadAllNodesStop(0x2A),
  replyReadSwVersion(0x2E),
  tiReadNeighborTab(0x12),
  tiStart(0x13),
  tiSendId(0x14),
  tiSendCoupleCmd(0x15),
  tiStop(0x16),
  replyTiReadNeighborTab(0x22),
  replyTiStart(0x23),
  replyTiSendId(0x24),
  replyTiSendCoupleCmd(0x25),
  replyTiStop(0x26);

  final int value;
  
  String get hex => value.toRadixString(16).padLeft(2, '0');

  const CPAccId(this.value);
}

// DTV_HI
enum DtvHi {
  wind(0x00),
  sun(0x10),
  dawn(0x20),
  rain(0x30),
  frost(0x40),
  temp(0x50),
  tempOut(0x60),
  battery(0xF0),
  matrix(0xFF);

  final int value;
  get hex => value.toRadixString(16).padLeft(2, '0');
  const DtvHi(this.value);
}

// DTV_LO
enum DtvLo {
  // value(0x00),
  thresHigh(0x01),
  thresLow(0x02),
  timeHigh(0x03),
  timeLow(0x04),
  timeFailure(0x05),
  timePriority(0x06),
  safety(0x07),
  auto_(0x08),
  slat(0x0F);

  final int value;
  get hex => value.toRadixString(16).padLeft(2, '0');
  const DtvLo(this.value);
}

// CP_FEATURES
/// Geräte-Features (Hardware-Capabilities)
enum CPFeatures {
  moveTo(false, true),
  dimTo(false, true),
  onOff(false, true),
  lowPower(true, false),
  sunValue(false, false),
  windValue(false, false),
  temperatureValue(false, false),
  humidityValue(false, false),
  rainValue(false, false),
  frostValue(false, false),
  duskDawnValue(false, false),
  moveUp(false, true),
  moveDown(false, true),
  moveStop(false, true),
  moveProfileDynamic(true, true),
  moveProfileSilent(true, true),
  moveProfileFast(true, true),
  flyscreenProtection(true, true),
  frostProtection(true, true),
  moveToSlat(true, true),
  moveUpSlat(true, true),
  moveDownSlat(true, true),
  pulse(false, true),
  batteryValue(true, false),
  modeWinter(false, true),
  sunProtection(false, true),
  remoteChCnt1(false, false),
  remoteChCnt8(false, false),
  remoteChCnt16(false, false),
  pushUp(false, false),
  pushDown(false, false),
  pushStop(false, false),
  pushButton(false, false),
  brushless(true, false),
  bluetooth(true, false),
  ppmValue(false, false),
  intermediatePosition1(false, true),
  intermediatePosition2(false, true),
  intermediatePosition3(false, true),
  analogValues(true, false),
  central(false, false);

  final bool optional;
  final bool controllable;

  const CPFeatures(this.optional, this.controllable);
}

enum CPDeviceAction {
  moveUp('Auf', 'move_up'),
  moveDown('Ab', 'move_down'),
  stop('Stop', 'stop'),
  moveToPosition('Position', 'move_to_position'),
  intermediatePosition1('ZP1', 'intermediate_pos_1'),
  intermediatePosition2('ZP2', 'intermediate_pos_2'),
  intermediatePosition3('ZP3', 'intermediate_pos_3'),
  sunProtectionOn('Sonnenschutz Ein', 'sun_protection_on'),
  sunProtectionOff('Sonnenschutz Aus', 'sun_protection_off'),
  turnOn('Ein', 'turn_on'),
  turnOff('Aus', 'turn_off'),
  dimToLevel('Dimmen', 'dim_to_level'),
  slatPosition('Lamellen Position', 'slat_position'),
  slatUp('Lamellen Auf', 'slat_up'),
  slatDown('Lamellen Ab', 'slat_down'),
  automaticOn('Automatik Ein', 'automatic_on'),
  automaticOff('Automatik Aus', 'automatic_off'),
  program('Programmieren', 'program'),
  pulse('Impuls', 'pulse');

  const CPDeviceAction(this.displayName, this.commandId);
  
  final String displayName;
  final String commandId;
  
  CommandFlags toCommandFlags() {
    switch (this) {
      case CPDeviceAction.moveUp:
        return CommandFlags(up: true);
      case CPDeviceAction.moveDown:
        return CommandFlags(down: true);
      case CPDeviceAction.stop:
        return CommandFlags(stop: true);
      case CPDeviceAction.sunProtectionOn:
        return CommandFlags(sun: true);
      case CPDeviceAction.sunProtectionOff:
        return CommandFlags(sun: false);
      case CPDeviceAction.turnOn:
        return CommandFlags();
      case CPDeviceAction.turnOff:
        return CommandFlags();
      case CPDeviceAction.program:
        return CommandFlags(prog: true);
      default:
        return CommandFlags();
    }
  }
}

extension CPFeaturesActions on CPFeatures {
  List<CPDeviceAction> get supportedActions {
    switch (this) {
      case CPFeatures.moveUp:
        return [CPDeviceAction.moveUp];
      case CPFeatures.moveDown:
        return [CPDeviceAction.moveDown];
      case CPFeatures.moveStop:
        return [CPDeviceAction.stop];
      case CPFeatures.moveTo:
        return [CPDeviceAction.moveToPosition];
      case CPFeatures.intermediatePosition1:
        return [CPDeviceAction.intermediatePosition1];
      case CPFeatures.intermediatePosition2:
        return [CPDeviceAction.intermediatePosition2];
      case CPFeatures.intermediatePosition3:
        return [CPDeviceAction.intermediatePosition3];
      case CPFeatures.sunProtection:
        return [CPDeviceAction.sunProtectionOn, CPDeviceAction.sunProtectionOff];
      case CPFeatures.onOff:
        return [CPDeviceAction.turnOn, CPDeviceAction.turnOff];
      case CPFeatures.dimTo:
        return [CPDeviceAction.dimToLevel];
      case CPFeatures.moveToSlat:
        return [CPDeviceAction.slatPosition];
      case CPFeatures.moveUpSlat:
        return [CPDeviceAction.slatUp];
      case CPFeatures.moveDownSlat:
        return [CPDeviceAction.slatDown];
      case CPFeatures.pulse:
        return [CPDeviceAction.pulse];
      default:
        return [];
    }
  }
}

enum MACAction {
  read(0x00),
  set(0x81),
  setExclusive(0x82),
  delete(0x83);

  const MACAction(this.value);
  final int value;
  String get hex => value.toRadixString(16).padLeft(2, '0');
}

enum CPMatrixMode {
  none,
  sunProtection,
  rainProtection
}
