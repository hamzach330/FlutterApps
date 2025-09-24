part of 'centronic_plus.dart';

class CentronicPlusNode {
  CentronicPlusNode({
    this.coupled = false,
    this.initiator,
    String? parentMac,
    required this.mac,
    required this.panId,
    required this.cp
  }):_parentMac = parentMac;

  CentronicPlus cp;
  final String mac;
  String? panId;
  CPInitiator? initiator;
  bool coupled;
  String? name; /// The nodes name as received on getName call
  String? serial; /// The node underlying device serial number
  int? version;
  int? manufacturer;
  Version? semVer;
  String? artId; /// The article id as received on readEEPROM call
  String? build;
  String? _parentMac;
  bool waitForRediscovery = false;
  bool waitForCouple = false;
  bool? sensorLoss;
  bool macAssignmentActive = false;
  CPRemoteActivity? indicateActivity;
  Timer? indicateActivityTimer;
  bool _online = true;
  bool _selected = false;
  int groupId = 0;
  bool visible = false;

  StreamController<CPRemoteActivity> simpleDigitalEvents = StreamController.broadcast();
  final StreamController<CentronicPlusNode> updateStream = StreamController.broadcast();
  final List<CentronicPlusNode> children = [];
  StatusFlags statusFlags = StatusFlags();
  AnalogValues? analogValues;
  AnalogValues? runtimeConfiguration;

  void notifyListeners() => updateStream.add(this);

  String? productName;
  bool _loading = false;
  bool _updating = false;
  bool _readError = false;
  int _errCount = 0;
  DateTime? _lastSeen;
  bool _wantsUpdate = true;

  String get parentMac => _parentMac ?? CP_EMPTY_MAC;

  CentronicPlusNode? get parent {
    return cp.getNodeByMac(parentMac);
  }

  /*
  Helpers to check whether all required data is collected.
  */
  bool get _wantsPageData => version == null || manufacturer == null || initiator == null;
  bool get _wantsServiceData => build == null;
  bool get _wantsName => name == null;
  bool get _collected => !_wantsPageData && !_wantsServiceData && !_wantsName;

  DateTime get lastSeen => _lastSeen ?? DateTime.fromMillisecondsSinceEpoch(0);
  int get timeoutCount => _errCount;

  bool get loading => _loading;
  bool get updating => _updating;
  bool get online => _online;

  bool get readError => _readError;

  bool get wantsAttention => isBatteryPowered == false && !waitForCouple && (statusFlags.hasWarning == true || readError == true || sensorLoss == true || statusFlags.setupComplete == false);

  bool get wantsUpdate => _wantsUpdate;
  /// Whether this device is a VarioControl - Requires getProductName to be called first
  bool get isVarioControl => productName?.startsWith("VC") ?? false;
  /// Whether this is a VarioControl 470 PLUS - Requires getProductName to be called first
  bool get isVC470 => productName?.startsWith("VC470") ?? false;
  /// Whether this is a VarioControl 420 PLUS - Requires getProductName to be called first
  bool get isVC420 => productName?.startsWith("VC420") ?? false;
  /// Whether this is a VarioControl 420 PLUS - Requires getProductName to be called first
  bool get isVC421 => productName?.startsWith("VC421") ?? false;
  /// Whether this is a VarioControl 520 PLUS - Requires getProductName to be called first
  bool get isVC520 => productName?.startsWith("VC520") ?? false;
  /// Whether this is a VarioControl 620 PLUS - Requires getProductName to be called first
  bool get isVC620 => productName?.startsWith("VC620") ?? false;
  /// Whether this is a VarioControl 670 PLUS - Requires getProductName to be called first
  bool get isVC670 => productName?.startsWith("VC670") ?? false;
  /// Whether this device is a LightControl - Requires getProductName to be called first
  bool get isLightControl => productName?.startsWith("LC") ?? false;
  /// Whether this is a LightControl 120 PLUS - Requires getProductName to be called first
  bool get isLC120 => productName?.startsWith("LC120") ?? false;
  /// Whether this is a VarioControl VC180 PLUS - Requires getProductName to be called first
  bool get isVC180 => productName?.startsWith("VC180") ?? false;
  /// Whether this device is battery powered (for example SC861)
  bool get isBatteryPowered => analogValues?.values.keys.contains("battery") == true
    || _isBatteryPowered
    || initiator == CPInitiator.marki
    || initiator == CPInitiator.sunDusk
    || initiator == CPInitiator.easySwitch;
  /// Set from database
  bool _isBatteryPowered = false;
  void set isBatteryPowered(bool value) {
    _isBatteryPowered = value;
  }

  bool get selected => _selected;

  bool get supportsSpecialFunctions => productName?.startsWith("C18") == true
    || productName?.startsWith("C16") == true
    || productName?.startsWith("C12") == true
    || productName?.startsWith("C01") == true
    || productName?.startsWith("Pico") == true
    || initiator == CPInitiator.bldc;

  /// Whether this is a drive
  bool get isDrive => initiator != null
    && initiator != CPInitiator.oneTwo
    && initiator != CPInitiator.sunDuskWindHumTempout
    && initiator != CPInitiator.easySwitch
    && initiator != CPInitiator.actSwitchDim
    && initiator != CPInitiator.sunDuskTempinPpm
    && initiator != CPInitiator.sunDuskTempout
    && initiator != CPInitiator.sunDuskTempin
    && initiator != CPInitiator.sunDuskWind
    && initiator != CPInitiator.sunDusk
    && initiator != CPInitiator.humTempout
    && initiator != CPInitiator.tempin
    && initiator != CPInitiator.tempout
    && initiator != CPInitiator.wind
    && initiator != CPInitiator.windHumTempout
    && initiator != CPInitiator.central0
    && initiator != CPInitiator.central1
    && initiator != CPInitiator.central2
    && initiator != CPInitiator.markiSensSec
    && initiator != CPInitiator.marki
    && initiator != CPInitiator.actWayLight
    && initiator != CPInitiator.actImpulseLight
    && initiator != CPInitiator.actSwitchDim
    && initiator != CPInitiator.easy;

  bool get isSensor => initiator != null && (
       initiator == CPInitiator.sunDuskWindHumTempout
    || initiator == CPInitiator.sunDuskTempinPpm
    || initiator == CPInitiator.sunDuskTempout
    || initiator == CPInitiator.sunDuskTempin
    || initiator == CPInitiator.sunDuskWind
    || initiator == CPInitiator.sunDusk
    || initiator == CPInitiator.humTempout
    || initiator == CPInitiator.tempin
    || initiator == CPInitiator.tempout
    || initiator == CPInitiator.wind
    || initiator == CPInitiator.markiSensSec
    || initiator == CPInitiator.windHumTempout);

  bool get isRemote => initiator != null && (
       initiator == CPInitiator.oneTwo
    || initiator == CPInitiator.marki
    || initiator == CPInitiator.easySwitch
  );

  bool get isCentral => initiator != null && (
    initiator == CPInitiator.central0
    || initiator == CPInitiator.central1
    || initiator == CPInitiator.central2
  );

  bool get isEvo => initiator != null && (
    initiator == CPInitiator.bldc
  );

  bool get isFlyScreenProtected => productName?.startsWith("C01") == true
    || initiator == CPInitiator.bldc;
  //  || productName?.contains("C16") == true
  //  || productName?.contains("C12") == true;

  bool get isSwitch => initiator != null && (
       initiator == CPInitiator.actSwitchDim
  );

  /// Node is part of a different CP installation
  bool get netDiff => panId != cp.pan && coupled == true;

  /// Node is in factory net
  bool get netFactory => panId != cp.pan && coupled == false;


  bool get isAwning   => initiator != null && (
    initiator == CPInitiator.sunDrive
  );
  
  bool get isScreen   => initiator != null && (
    initiator == CPInitiator.sunDriveZip
  );

  bool get isShutter  => initiator != null && (
    initiator == CPInitiator.rolloDrive
    || initiator == CPInitiator.bldc
  );
  
  bool get isVenetian => initiator != null && (
    initiator == CPInitiator.sunDriveJal
  );

  /// This is the updated feature list retrieval.
  /// Use this instead of the old functions isVenetian, isShutter, isX...
  List<CPFeatures> get features {
    List<CPFeatures> features = [];

    if (initiator != null) {
      // Central features
      if ([
        CPInitiator.central0,
        CPInitiator.central1,
        CPInitiator.central2,
      ].contains(initiator)) {
        features.add(CPFeatures.central);
      }

      // Act Switch Dim features
      if (initiator == CPInitiator.actSwitchDim) {
        features.addAll([
          CPFeatures.onOff,
          CPFeatures.analogValues,
        ]);
      }

      // Drive features
      if ([
        CPInitiator.rolloDrive,
        CPInitiator.bldc,
        CPInitiator.sunDrive,
        CPInitiator.sunDriveBldc,
        CPInitiator.sunDriveJal,
        CPInitiator.sunDriveZip,
        CPInitiator.sunDriveZipBldc,
        CPInitiator.sunDriveScreen,
        CPInitiator.sunDriveScreenBldc,
        CPInitiator.sunDriveSail,
        CPInitiator.sunDriveSailBldc,
      ].contains(initiator)) {
        features.addAll([
          CPFeatures.moveTo,
          CPFeatures.moveUp,
          CPFeatures.moveDown,
          CPFeatures.moveStop,
          CPFeatures.sunProtection,
          CPFeatures.modeWinter,
          CPFeatures.intermediatePosition1,
          CPFeatures.intermediatePosition2,
          CPFeatures.analogValues,
        ]);

        if (initiator == CPInitiator.sunDriveJal) {
          features.add(CPFeatures.moveToSlat);
        }

        if ([
          CPInitiator.bldc,
          CPInitiator.sunDriveBldc,
          CPInitiator.sunDriveZipBldc,
          CPInitiator.sunDriveScreenBldc,
          CPInitiator.sunDriveSailBldc,
        ].contains(initiator)) {
          features.addAll([
            CPFeatures.moveProfileDynamic,
            CPFeatures.moveProfileSilent,
            CPFeatures.moveProfileFast,
            CPFeatures.frostProtection,
            CPFeatures.flyscreenProtection,
            CPFeatures.brushless,
            CPFeatures.bluetooth,
          ]);
        } else if (productName == "C01 PLUS") {
          features.addAll([
            CPFeatures.frostProtection,
            CPFeatures.flyscreenProtection,
          ]);
        }
      }

      // Remote features
      if ([
        CPInitiator.easy,
        CPInitiator.easySwitch,
        CPInitiator.marki,
        CPInitiator.oneTwo,
      ].contains(initiator)) {
        features.addAll([
          CPFeatures.lowPower,
          CPFeatures.pushUp,
          CPFeatures.pushDown,
          CPFeatures.pushStop,
        ]);

        if (artId != null && {
          "40367350020",
          "40367350100",
          "40367350260",
          "40367350320",
        }.contains(artId)) {
          features.add(CPFeatures.remoteChCnt8);
        } else if (artId != null && {
          "40367350070",
          "40367350110",
          "40367350270",
          "40367350330",
        }.contains(artId)) {
          features.add(CPFeatures.remoteChCnt16);
        } else {
          features.add(CPFeatures.remoteChCnt1);
        }
      }

      // Sensor features
      if ([
        CPInitiator.sun,
        CPInitiator.sunDusk,
        CPInitiator.sunDuskWind,
        CPInitiator.sunDuskWindHumTempout,
        CPInitiator.sunDuskTempin,
        CPInitiator.sunDuskTempout,
        CPInitiator.sunDuskTempinPpm,
        CPInitiator.windHumTempout,
        CPInitiator.tempout,
        CPInitiator.tempin,
        CPInitiator.ppm,
        CPInitiator.markiSensSec,
      ].contains(initiator)) {
        features.addAll([
          CPFeatures.remoteChCnt1,
          CPFeatures.analogValues,
        ]);

        switch (initiator) {
          case CPInitiator.sun:
            features.add(CPFeatures.sunValue);
            break;
          case CPInitiator.sunDusk:
            features.addAll([
              CPFeatures.sunValue,
              CPFeatures.duskDawnValue,
            ]);
            break;
          case CPInitiator.sunDuskWind:
            features.addAll([
              CPFeatures.sunValue,
              CPFeatures.duskDawnValue,
              CPFeatures.windValue,
            ]);
            break;
          case CPInitiator.sunDuskTempin:
            features.addAll([
              CPFeatures.sunValue,
              CPFeatures.duskDawnValue,
              CPFeatures.temperatureValue,
            ]);
            break;
          case CPInitiator.sunDuskTempinPpm:
            features.addAll([
              CPFeatures.sunValue,
              CPFeatures.duskDawnValue,
              CPFeatures.temperatureValue,
              CPFeatures.ppmValue,
            ]);
            break;
          case CPInitiator.sunDuskTempout:
            features.addAll([
              CPFeatures.sunValue,
              CPFeatures.duskDawnValue,
              CPFeatures.temperatureValue,
            ]);
            break;
          case CPInitiator.windHumTempout:
            features.addAll([
              CPFeatures.windValue,
              CPFeatures.humidityValue,
              CPFeatures.temperatureValue,
            ]);
            break;
          case CPInitiator.tempout:
          case CPInitiator.tempin:
            features.add(CPFeatures.temperatureValue);
            break;
          case CPInitiator.ppm:
            features.add(CPFeatures.ppmValue);
            break;
          case CPInitiator.markiSensSec:
            // No additional features
            break;
          case CPInitiator.sunDuskWindHumTempout:
            features.addAll([
              CPFeatures.windValue,
              CPFeatures.duskDawnValue,
              CPFeatures.sunValue,
              CPFeatures.rainValue,
              CPFeatures.temperatureValue,
            ]);
            break;
          default:
            break;
        }
      }
    }

    return features;
  }

  // True if the features of both nodes are identical (ignoring optional features)
  bool compareFeatures(CentronicPlusNode other) {
    final firstFeatures = Set.from(this.features.where((f) => !f.optional));
    final secondFeatures = Set.from(other.features.where((f) => !f.optional));

    return firstFeatures.difference(secondFeatures).isEmpty &&
           secondFeatures.difference(firstFeatures).isEmpty;
  }

  bool matchVersion ({
    Version? min,
    Version? max,
  }) {
    if(min == null) min = Version(0,0,0);
    if(max == null) max = Version(255, 255, 255);

    if(semVer != null) {
      if(semVer! >= min && semVer! < max) {
        return true;
      }
    }
    return false;
  }

  void resetLocalInfo() {
    _loading = false;
    name = null;
    version = null;
    manufacturer = null;
    artId = null;
    semVer = null;
    build = null;
    _parentMac = null;
    productName = null;
    statusFlags = StatusFlags();
    analogValues = null;
    runtimeConfiguration = null;
    sensorLoss = null;

    notifyListeners();
  }

  int get remoteChannelCount {
    if(initiator == CPInitiator.central0) {
      return 192;
    }
    switch(artId) {
      case "40367350020":
        return 8;
      case "40367350060":
        return 1;
      case "40367350070":
        return 16;
      case "40367350090":
        return 1;
      case "40367350100":
        return 8;
      case "40367350110":
        return 16;
      case "40367350250":
        return 1;
      case "40367350260":
        return 8;
      case "40367350270":
        return 16;
      case "40367350310":
        return 1;
      case "40367350320":
        return 8;
      case "40367350330":
        return 16;
      default:
        return 1;
    }
  }

  /// Sun Protection roles dependend on initiator for some reason 
  int getMatrixValueFor(CPMatrixMode mode) {
    if(mode == CPMatrixMode.none) {
      if(isShutter) {
        return 1;
      } else if(isAwning) {
        return 6;
      } else if(isVenetian) {
        return 5;
      } else if(isScreen) {
        return 17;
      }
    } else if(mode == CPMatrixMode.sunProtection) {
      if(isShutter) {
        return 7;
      } else if(isAwning) {
        return 2;
      } else if(isVenetian) {
        return 9;
      } else if(isScreen) {
        return 18;
      }
    } else if(mode == CPMatrixMode.rainProtection) {
      if(isShutter) {
        return 8;
      } else if(isAwning) {
        return 4;
      } else if(isVenetian) {
        return 10;
      } else if(isScreen) {
        return 19;
      }
    }
    return 0;
  }

  void select() {
    _selected = true;
    notifyListeners();
  }

  void selectUnique() {
    cp.unselectNodes();
    _selected = true;
    notifyListeners();
  }

  void unselect() {
    _selected = false;
    notifyListeners();
  }

  /** V2 **/

  Future<void> couple() async {
    waitForCouple = true;
    notifyListeners();

    try {
      await cp._setCoupledFlag(mac);
      await cp.readPanId();

      panId = cp.pan;
      coupled = true;
      _online = true;
      waitForCouple = false;
    } catch(e) {
      waitForCouple = false;
    }
  }

  void _remove() {
    cp._removeNode(this);
  }

  Future<V2Message> _waitFor(
    CPAccId key, {
    MessageFilter? messageFilter,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    _lastSeen = DateTime.now();
    notifyListeners();
    try {
      return await cp._waitFor(key, messageFilter: messageFilter, timeout: timeout);
    } catch(e) {
      _errCount++;
      rethrow;
    }
  }

  void show () {
    visible = true;
    _selected = false;
    notifyListeners();
    cp.notifyListeners();
  }

  void hide () {
    visible = false;
    _selected = false;
    notifyListeners();
    cp.notifyListeners();
  }
  
  void remove() {
    cp._removeNode(this);
  }

  void _asyncHandleMessage (V2Message message) {
    _lastSeen = DateTime.now();
    _online = true;
    notifyListeners();

    if(message.dataType == CPDatatype.page1) {
      _handlePage1(message);
    } else if(message.dataType == CPDatatype.page3) {
      _handlePage3(message);
    } else if (message.dataType == CPDatatype.db) {
      _handleDB(message);
    } else if (message.dataType == CPDatatype.service) {
      _handleService(message);
    } else if (message.dataType == CPDatatype.anaMulti) {
      _handleAnaMulti(message);
    } else if (message.dataType == CPDatatype.simpleDigital) {
      _handleSimpleDigital(message);
    } else if (message.dataType == CPDatatype.textReply32char) {
      _handleNameReply(message);
    }
  }

  void sendPositionCommand(double position, [CPEVOProfile? evoProfile]) async {
    final messageId = cp._nextQueueId();
    final int bit32 = (0xFFFF * (position / 100)).toInt();
    final value = [bit32 & 0xFF, bit32 >> 8];

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.control,
      control: ControlFlags(analog: true),
      command: CommandFlags(),
      payload: [
        ...value,
        if(evoProfile != null) ...[0x10, evoProfile.value, 0x00],
      ],
      messageId: messageId,
    ));
  }

  void sendSlatPositionCommand(double slat, [CPEVOProfile? evoProfile]) async {
    final messageId = cp._nextQueueId();
    final int bit32 = (0xFFFF * (slat / 100)).toInt();
    final value = [bit32 & 0xFF, bit32 >> 8];

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.control,
      control: ControlFlags(analog: true),
      command: CommandFlags(),
      payload: [
        0x00, 0x00,
        DtvLo.slat.value, ...value,
        if(evoProfile != null) ...[0x10, evoProfile.value, 0x00],
      ],
      messageId: messageId,
    ));
  }

  void testMoveTo(double slat, [CPEVOProfile? evoProfile]) async {
    final messageId = cp._nextQueueId();
    final int moveToSlat32 = (0xFFFF * (30.0 / 100)).toInt();
    final moveToSlat = [moveToSlat32 & 0xFF, moveToSlat32 >> 8];

    final int moveTo32 = (0xFFFF * (30.0 / 100)).toInt();
    final moveTo = [moveTo32 & 0xFF, moveTo32 >> 8];

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.control,
      control: ControlFlags(analog: true),
      command: CommandFlags(),
      payload: [
        ...moveTo,
        DtvLo.slat.value, ...moveToSlat,
        if(evoProfile != null) ...[0x10, evoProfile.value, 0x00],
      ],
      messageId: messageId,
    ));
  }

  void _sendDigitalCommand(CommandFlags command, [ControlFlags? control]) {
    unawaited(cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.simpleDigital,
      control: control ?? ControlFlags(),
      command: command,
    )));
  }

  void sendProgCommand({bool silent = false}) {
    _sendDigitalCommand(CommandFlags(prog: true));
  }

  void sendDownCommand({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(down: true));
  }

  void sendUpCommand({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(up: true));
  }

  void sendStopCommand({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(stop: true));
  }

  void sendMemoCommand({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(memo: true));
  }

  void sendDtCommand({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(doubleClick: true));
  }

  void sendS6Command({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(sec6: true));
  }

  void sendS3Command({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(sec3: true));
  }

  void sendS9Command({bool silent = false}) async {
    _sendDigitalCommand(CommandFlags(sec9: true));
  }

  void setPreset1() {
    _sendDigitalCommand(CommandFlags(raw: [0x31, 0x00]));
  }

  void setPreset2() {
    _sendDigitalCommand(CommandFlags(raw: [0x51, 0x00]));
  }

  void deletePreset() {
    _sendDigitalCommand(CommandFlags(raw: [0x17, 0x00]));
  }

  void movePreset1() {
    _sendDigitalCommand(CommandFlags(raw: [0x24, 0x00]));
  }

  void movePreset2() {
    _sendDigitalCommand(CommandFlags(raw: [0x44, 0x00]));
  }

  void setLowerEndposition({silent = false}) {
    _sendDigitalCommand(CommandFlags(raw: [0x81 | 0x40, 0x00]));
  }

  void setUpperEndposition({silent = false}) {
    _sendDigitalCommand(CommandFlags(raw: [0x81 | 0x20, 0x00]));
  }

  void setEnableFlyscreen() {
    _sendDigitalCommand(CommandFlags(raw: [0x91 | 0x40, 0x00]));
  }

  void deleteEndposition({silent = false}) {
    _sendDigitalCommand(CommandFlags(raw: [0x81 | 0x10, 0x00]));
  }

  void setEnableFrost() {
    _sendDigitalCommand(CommandFlags(raw: [0x91 | 0x20, 0x00]));
  }

  void invertRotaryDirection() {
    _sendDigitalCommand(CommandFlags(raw: [0x81 | 0x60, 0x00]));
  }

  void _sendSpecialCommand({
    required CPDatatype dataType,
  }) {
    unawaited(cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: dataType,
      control: ControlFlags(digital: true),
      command: CommandFlags(raw: [0xFF, 0xBA]),
    )));
  }

  void scTiStop() {
    _sendSpecialCommand(dataType: CPDatatype.scTiStop);
  }

  void scTiRestart() {
    _sendSpecialCommand(dataType: CPDatatype.scTiRestart);
  }

  void scCentronicLrearnTimerStop() {
    _sendSpecialCommand(dataType: CPDatatype.scCentronicLrearnTimerStop);
  }

  void scCentronicDeleteTimerStart() {
    _sendSpecialCommand(dataType: CPDatatype.scCentronicDeleteTimerStart);
  }

  void scCentronicLearnTimerStart() {
    _sendSpecialCommand(dataType: CPDatatype.scCentronicLearnTimerStart);
  }

  void scCentronicPowerOnTimerStart() {
    _sendSpecialCommand(dataType: CPDatatype.scCentronicPowerOnTimerStart);
  }

  void scCentronicLearnDeleteTimersStop() {
    _sendSpecialCommand(dataType: CPDatatype.scCentronicLearnDeleteTimersStop);
  }

  void scTiEnable() {
    _sendSpecialCommand(dataType: CPDatatype.scTiEnable);
  }

  void scTiDisable() {
    _sendSpecialCommand(dataType: CPDatatype.scTiDisable);
  }

  void scRemoteDelete() {
    _sendSpecialCommand(dataType: CPDatatype.scRemoteDelete);
  }

  void scFactoryResetCentronic() {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetCentronic);
  }

  void scSwReset() {
    _sendSpecialCommand(dataType: CPDatatype.scSwReset);
    _remove();
  }

  void scFactoryResetAll() {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetAll);
    _remove();
  }

  void scFactoryResetCentronicPlus() {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetCentronicPlus);
    _remove();
  }

  void identify() async {
    if(cp.discovery) {
      unawaited(cp.writeAscii(V2Message.encode(
        port: CP_DEFAULT_PORT,
        accessId: CPAccId.tiSendId.hex,
        protocolType: "00",
        timeout: "01",
        priority: "00",
        mac: mac,
      )));
    } else {
      unawaited(cp.writeAscii(V2Message.encodeDTCommand(
        mac: mac,
        dataType: CPDatatype.simpleDigital,
        command: CommandFlags(prog: true, sec3: true),
        control: ControlFlags(),
        messageId: cp._nextQueueId(),
      )));
    }
  }

  void enableFeedback() {
    // 0701011aa0dc04fffe0105b301013400000000002000810000000a010501
    // Port:          0x7
    // Access ID:     DATA_SEND_PAN_RN_UNICAST (0x1)
    // Block number:  1 (0x1)
    // Block length:  26 (0x1a)
    // MAC:           a0dc04fffe0105b3
    // Protocol type: 1 (0x1)
    // Manufacturer:  1 (0x1)
    // Initiator:     CENTRAL0 (0x34)
    // Group:         [0, 0, 0, 0] (0x0 0x0 0x0 0x0)
    // Data type:     SIMPLE_DIGITAL (0x0)
    // Control:       DIGITAL (0x20 0x0)
    // Command:       SEC3 PROG (0x81 0x0)
    // Extra payload: [0, 0, 10, 1, 5, 1]
    // Sync:          2561
    // Priority:      5
    // Timeout:       1

    final messageId = cp._nextQueueId();
    unawaited(cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      group: "00 00 00 00",
      dataType: CPDatatype.simpleDigital,
      control: ControlFlags(digital: true),
      command: CommandFlags(sec3: true, prog: true),
      payload: [0x00, 0x00],
      messageId: messageId
    )));
  }

  Future<void> updateDeviceName() async {
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      protocolType: "80",
      group: "00 00 00 00",
      dataType: CPDatatype.textRead32char,
      payload: List.filled(32, 0x00),
      priority: "",
      timeout: "",
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.dataType == CPDatatype.textReply32char,
    );

    name = Mutators.toUtf8String(result.payload.sublist(16, 48));
  }

  /// FIXME: Remotes (SWC) respod with wrong datatype.
  Future<bool> setName(String newName) async {
    name = newName;
    unawaited(cp.dbPutNode?.call(this));
    notifyListeners();

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      protocolType: "80",
      group: "00 00 00 00",
      dataType: CPDatatype.textWrite32char,
      payload: Mutators.fromUtf8String(newName, 32),
      priority: "",
      timeout: "",
    ));
    
    await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.dataType == CPDatatype.textReply32char,
    );


    return true;
  }

  Future<void> updateProperties() async {
    final messageId = cp._nextQueueId();
    
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      control: ControlFlags(read: true),
      command: CommandFlags(),
      dataType: CPDatatype.page1,
      payload: [0x00, 0x00], // ???
      messageId: messageId,
    ));

    final MessageFilter filter = (message) => message.macAddress == mac && message.messageId == messageId;
    final result = await _waitFor(CPAccId.dataSendPanRn, messageFilter: filter);
    final pageData = CPNodePage1Data.fromV2Message(result);

    statusFlags = pageData.flags;
    version = pageData.version;
    manufacturer = pageData.manufacturer;
    initiator = pageData.initiator;
  }

  Future<void> updateParent() async {
    final messageId = cp._nextQueueId();
    
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      control: ControlFlags(read: true),
      command: CommandFlags(),
      dataType: CPDatatype.page3,
      payload: [0x00, 0x00], // ???
      messageId: messageId,
    ));

    final MessageFilter filter = (message) => message.macAddress == mac && message.messageId == messageId;
    final result = await _waitFor(CPAccId.dataSendPanRn, messageFilter: filter);

    final parentA = Mutators.toHexString(result.payload.sublist(11, 15));
    final parentB = Mutators.toHexString(result.payload.sublist(16, 20));

    _parentMac = "$parentA$parentB";
    initiator = initiator ?? result.initiator;

    notifyListeners();
  }

  Future<List<int>> readEeprom({
    required String mac,
    required int length,
    required List<int> address,
    CPDatatype dataTypeResponse = CPDatatype.service,
  }) async {
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      control: ControlFlags(raw: [0x01, 0x05]),
      command: CommandFlags(raw: [0x00, 0x00]),
      dataType: CPDatatype.service,
      payload: [length, ...address, 0x00],
      timeout: "",
      priority: "",
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac,
    );

    return result.payload.sublist(20, result.payload.length - 4);
  }

  Future<bool> updateSoftwareInfo({silent = false}) async {
    final messageId = cp._nextQueueId();
    
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.service,
      control: ControlFlags(),
      command: CommandFlags(),
      payload: [0x00], // ???
      messageId: messageId,
    ));

    final MessageFilter filter = (message) => message.macAddress == mac && message.messageId == messageId;
    final result = await _waitFor(CPAccId.dataSendPanRn, messageFilter: filter);
    final eeprom = CPNodeEEPROM.fromV2Message(result);

    serial = eeprom.serial;
    semVer = eeprom.version;
    artId = eeprom.artId;
    build = eeprom.build;

    if(initiator == CPInitiator.sunDuskWindHumTempout && (version ?? 13) < 12) {
      artId = "403673502000";
    } else if(initiator == CPInitiator.sunDuskWind && (version ?? 13) < 12) {
      artId = "403673502000";
    }

    return true;
  }

  void getProductName() {
    if(initiator == CPInitiator.sunDuskWind && isBatteryPowered) {
      productName = "SC861 PLUS"; /// Variant of SC811
    } else {
      productName = ProductId.fromArtIdAndInitiator(
        artId: artId ?? "",
        initiator: initiator ?? CPInitiator.none
      )?.name ?? initiator?.name.toString();
    }
  }

  Future<void> updateInfo({bool save = true}) async {
    if(_updating == true) {
      return;
    }

    _updating = true;
    _readError = false;

    notifyListeners();

    try {
      if(isCentral == false) {
        await updateProperties();
        await updateSoftwareInfo();
        if(!isBatteryPowered) {
          await updateParent();
        }
        getProductName();
      }

      await updateDeviceName();

      _online = true;

      if(save) {
        unawaited(cp.dbPutNode?.call(this));
      }
    } catch(e) {
      _readError = true;
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  void updateState() async {
    if(isCentral) return;
    
    _loading = true;
    _readError = false;

    notifyListeners();
    
    final messageId = cp._nextQueueId();
    
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: isSensor ? CPDatatype.anaMulti : CPDatatype.db,
      control: ControlFlags(read: true),
      command: CommandFlags(),
      payload: [
        0x00, 0x00,
        DtvLo.slat.value, 0x00, 0x00,
        if(isSensor) DtvHi.wind.value, 0x00, 0x00,
        if(isSensor) DtvHi.sun.value, 0x00, 0x00,
        if(isSensor) DtvHi.dawn.value, 0x00, 0x00,
        if(isSensor) DtvHi.rain.value, 0x00, 0x00,
        if(isSensor) DtvHi.frost.value, 0x00, 0x00,
        if(isSensor) DtvHi.tempOut.value, 0x00, 0x00,
      ],
      messageId: messageId,
    ));

    try {
      final MessageFilter filter = (message) => message.macAddress == mac && message.messageId == messageId;
      final result = await _waitFor(CPAccId.dataSendPanRn, messageFilter: filter);
      analogValues = result.analog;
    } catch (e) {
      _readError = true;
    } finally {
      _loading = false;
    }

    notifyListeners();
  }

  void _handleNameReply(V2Message message) {
    name = Mutators.toUtf8String(message.payload.sublist(16, 48));
    initiator = message.initiator;
    if(_collected) {
      //  unawaited(cp.dbPutNode?.call(this));
    }

    notifyListeners();
  }
  
  void _handlePage1(V2Message message) {
    final pageData = CPNodePage1Data.fromV2Message(message);

    statusFlags = pageData.flags;
    version = pageData.version;
    manufacturer = pageData.manufacturer;
    initiator = pageData.initiator;

    if(_collected) {
      //  unawaited(cp.dbPutNode?.call(this));
    }

    notifyListeners();
  }

  void _handlePage3(V2Message message) {
    final parentA = Mutators.toHexString(message.payload.sublist(11, 15));
    final parentB = Mutators.toHexString(message.payload.sublist(16, 20));

    _parentMac = "$parentA$parentB";
    initiator = initiator ?? message.initiator;

    if(_collected) {
      //  unawaited(cp.dbPutNode?.call(this));
    } else {
      // unawaited(updateInfo());
    }

    notifyListeners();
  }

  void _handleDB(V2Message message) {
    if(message.control.analog) {
      try {
        analogValues = message.analog;
        notifyListeners();
      } catch (e) {/* no analog data */}

      try {
        statusFlags = StatusFlags(raw: message.payload.sublist(18, 20));
        notifyListeners();
      } catch (e) {/* No work */}
    }
  }

  void _handleService(V2Message message) {
    log("Update node service", name: "CentronicPlusNode._handleService");

    try {
      analogValues = message.analog;
      notifyListeners();
    } catch (e) {
      log("No values", name: "CentronicPlusNode._handleService");
    }

    if(message.control.read == true) {
      final eeprom = CPNodeEEPROM.fromV2Message(message);
      initiator = initiator ?? message.initiator;
      serial = eeprom.serial;
      semVer = eeprom.version; 
      artId = eeprom.artId;
      build = eeprom.build;
      getProductName();
      log("Serial: $serial", name: "CentronicPlusNode._handleService");
      log("Article ID: $artId", name: "CentronicPlusNode._handleService");
      log("Version: $semVer", name: "CentronicPlusNode._handleService");
      log("Build: $build", name: "CentronicPlusNode._handleService");
      log("Product Name: $productName", name: "CentronicPlusNode._handleService");

      if(initiator == CPInitiator.sunDuskWindHumTempout && (version ?? 13) < 12) {
        artId = "403673502000";
      } else if(initiator == CPInitiator.sunDuskWind && (version ?? 13) < 12) {
        artId = "403673502000";
      }
    }
  }

  void _handleAnaMulti(V2Message message) {
    /// Also handle button presses
    if(message.control.digital && (message.command.up || message.command.down || message.command.stop)) {
      _handleSimpleDigital(message);
    }

    try {
      analogValues = message.analog;
      notifyListeners();
    } catch (e) {
      log("", name: "_handleService");
    }
  }

  Timer? _activityTimer;
  void _handleSimpleDigital(V2Message message) {
    _activityTimer?.cancel();
    _activityTimer = null;

    log("Simple digital message: $message", name: "_handleSimpleDigital");

    CPRemoteActivity activity;
    if(message.command.up) {
      activity = CPRemoteActivity.up;
    } else if(message.command.down) {
      activity = CPRemoteActivity.down;
    } else if(message.command.stop) {
      activity = CPRemoteActivity.stop;
    } else {
      activity = CPRemoteActivity.unknown;
    }
    simpleDigitalEvents.add(activity);

    indicateActivity = activity;

    _activityTimer = Timer(const Duration(seconds: 1), () {
      indicateActivity = null;
      _activityTimer = null;
      notifyListeners();
    });

    initiator = message.initiator;

    try {
      analogValues = message.analog;
    } catch (e) {/* No work */}

    notifyListeners();

    if(!_collected) {
      unawaited(updateInfo());
    }
  }

  Future<void> _setVcOperationMode(List<int> mode) async {
    final messageId = cp._nextQueueId();

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.service,
      payload: [0x3F, ...mode, 0x00, 0x00],
      control: ControlFlags(raw: [0x17, 0x27]), // weird status change flag
      command: CommandFlags(),
      messageId: messageId,
    ));

    await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  void setVcOperationModeShutter() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xAB]);
    resetLocalInfo();
    initiator = CPInitiator.rolloDrive;
    notifyListeners();
  }

  void setVcOperationModeSunProtection() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xAA]);
    resetLocalInfo();
    initiator = CPInitiator.sunDrive;
    notifyListeners();
  }

  void setVcOperationModeVenetian() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA9]);
    resetLocalInfo();
    initiator = CPInitiator.sunDriveJal;
    notifyListeners();
  }

  void setVcOperationModeSwitch() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA8]);
    resetLocalInfo();
    initiator = CPInitiator.actSwitchDim;
    notifyListeners();
  }

  void setVcOperationModeShutterPulse() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA7]);
    resetLocalInfo();
    notifyListeners();
  }

  void setVcOperationModeSwitchPulse() async {
    _loading = true;
    notifyListeners();
    await _setVcOperationMode([0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA6]);
    resetLocalInfo();
    initiator = CPInitiator.actImpulseLight;
    notifyListeners();
  }

  Future<int> readRssi() async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.simpleDigital,
      control: ControlFlags(raw: [0x80, 0x00]),
      command: CommandFlags(),
      payload: [0x00, 0x00],
      messageId: messageId
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      timeout: Duration(seconds: 2),
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );

    return result.payload[17].toSigned(8);
  }

  /**********************************/
  /**********************************/
  /**********************************/
  /*********** MAC ASSIGN ***********/
  /**********************************/
  /**********************************/
  /**********************************/

  /// Assign this (central) node to control the target node.
  /// This function is limited to assigning 64 groups.
  /// [group] - The group bits to assign (64bit)
  /// 
  /// 3 bit Page (GRP-PGB)
  /// 24 bit Group (GRPVB)
  /// |---------------|----------|----------|-----------|--------|--------|--------|--------|--------|
  /// |               | MSB      |          |           |        |        |        |        | LSB    |
  /// |---------------|----------|----------|-----------|--------|--------|--------|--------|--------|
  /// | Byte          | 7        | 6        | 5         | 4      | 3      | 2      | 1      | 0      |
  /// |---------------|----------|----------|-----------|--------|--------|--------|--------|--------|
  /// | Page/GrpCode  | GRP-PGB2 | GRP-PGB1 | GRP-PAGEB0| GRPC4  | GRPC3  | GRPC2  | GRPC1  | GRPC0  |
  /// | GroupVBits1   | GRPVB8   | GRPVB7   | GRPVB6    | GRPVB5 | GRPVB4 | GRPVB3 | GRPVB2 | GRPVB1 |
  /// | GroupVBits2   | GRPVB16  | GRPVB15  | GRPVB14   | GRPVB13| GRPVB12| GRPVB11| GRPVB10| GRPVB9 |
  /// | GroupVBits3   | GRPVB24  | GRPVB23  | GRPVB22   | GRPVB21| GRPVB20| GRPVB19| GRPVB18| GRPVB17|
  /// |---------------|----------|----------|-----------|--------|--------|--------|--------|--------|
  /// 
  /// example assign a node to group 1 on Page 1:
  /// macAssign(targetNode, 0);
  /// Page 1                       Page 2                     Page 3
  /// 0b00000001_00000000_00000000_00000000_00000000_00000000_00000000_00000000
  /// macAssign(targetNode, 24);
  /// example assign a node to group 1 on Page 2:
  /// Page 1                       Page 2                     Page 3
  /// 0b00000000_00000000_00000000_00000001_00000000_00000000_00000000_00000000
  /// 

  final Map<int, List<CentronicPlusNode>> channelAssignments = {};


  /// Get all nodes assigned to this node (hopefully)
  Future<Map<int, List<CentronicPlusNode>>> loadGroups () async {
    final ownMac = "a2${(mac).substring(2, 16)}";
    final messageId = cp._nextQueueId();
    channelAssignments.clear();

    _loading = true;
    notifyListeners();

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: CP_EMPTY_MAC,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.db,
      control: ControlFlags(installationKey: true, digital: true),
      command: CommandFlags(),
      payload: [
        0x00, 0x01,
        0x81, MACAction.read.value,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, ...Mutators.fromHexString(ownMac, ownMac.length ~/ 2), 0x00, 0x00
      ],
      messageId: messageId
    ));

    try {
      await Future.wait([
        for(final node in cp.getOwnNodes().where((node) => node.isDrive || node.isLightControl || node.isSwitch || node.isVarioControl)) 
          Future(() async {
            final result = await _waitFor(
              CPAccId.dataSendPanRn,
              messageFilter: (message) => message.macAddress == node.mac && message.messageId == messageId
            );

            final groupIds = cp.getGroupIdsFromPage24List(result.payload.sublist(26, 30));
            final responseNode = cp.getNodeByMac(result.macAddress);

            for(final id in groupIds) {
              channelAssignments[id] = channelAssignments[id] ?? [];
              if(responseNode != null) {
                channelAssignments[id]?.add(responseNode);
              }
            }

            notifyListeners();
          }),
      ]).timeout(Duration(seconds: 7));
    } catch (e) {
      log("Error while updating MAC assignments: $e", name: "CentronicPlusNode.updateMacAssign");
    }

    _loading = false;
    notifyListeners();
    
    return channelAssignments;
  }

  Future<bool> assignGroups (CentronicPlusNode target, List<int> groups) async {
    final ownMac = "a2${(target.mac).substring(2, 16)}";
    target._loading = true;
    target.notifyListeners();

    for(final page in cp.getPageListFromGroupIds(groups)) {
      try {
        final messageId = cp._nextQueueId();
        await cp.writeAscii(V2Message.encodeDTCommand(
          mac: mac,
          dataType: CPDatatype.db,
          control: ControlFlags(installationKey: true),
          command: CommandFlags(),
          payload: [0x00, 0x01,
            0x81, MACAction.set.value, 0x00,
            target.initiator?.value ?? CPInitiator.central0.value,
            ...page,
            ...Mutators.fromHexString(ownMac, ownMac.length ~/ 2),
            0x00, 0x00
          ],
          messageId: messageId
        ));

        await _waitFor(
          CPAccId.dataSendPanRn,
          messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
        );
      } catch(e) {
        target._loading = false;
        target.notifyListeners();
        return false;
      }
    }
    
    target._loading = false;
    target.notifyListeners();
    return true;
  }

  Future<bool> unassignGroups (CentronicPlusNode target) async {
    final ownMac = "a2${(target.mac).substring(2, 16)}";

    try {
      final messageId = cp._nextQueueId();
      await cp.writeAscii(V2Message.encodeDTCommand(
        mac: mac,
        dataType: CPDatatype.db,
        control: ControlFlags(installationKey: true),
        command: CommandFlags(),
        payload: [
          0x00, 0x01,
          0x81, MACAction.delete.value, 0x00,
          target.initiator?.value ?? CPInitiator.central0.value,
          ...[0x00, 0x01, 0x00, 0x00],
          ...Mutators.fromHexString(ownMac, ownMac.length ~/ 2),
          0x00, 0x00
        ],
        messageId: messageId
      ));
      
      await _waitFor(
        CPAccId.dataSendPanRn,
        messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
      );

      return true;
    } catch(e) {
      return false;
    }
  }

  Future<void> unassignGroupInitiator(CPInitiator initiator) async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.db,
      control: ControlFlags(installationKey: true),
      command: CommandFlags(),
      payload: [0x00, 0x01,
        0x82, initiator.value,
      ],
      messageId: messageId
    ));

    await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  Future<List<int>?> evoTunnelCommand({
    required List<int> message
  }) async {
    final messageId = cp._nextQueueId();

    await cp.writeAscii(V2Message.encode(
      accessId: CPAccId.dataSendPanRnUnicast.hex,
      mac: mac,
      protocolType: "04",
      extraPayload: Mutators.toHexString([
        0x00,
        ...[messageId >> 8, messageId & 0xFF],
        ...message,
      ]),
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.protocolType == 4,
    );

    return result.payload.sublist(12, result.payload.length);
  }

  /// Unused ?
  Future<V2Message?> readSunMatrix() async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.anaMulti,
      control: ControlFlags(analog: true),
      command: CommandFlags(),
      payload: [0x00 ,0x00 ,0xFF ,0x00, 0x00],
      messageId: messageId,
    ));

    return await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  Future<V2Message?> readSunProfile() async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.anaMulti,
      control: ControlFlags(raw: [0x80, 0x00]),
      command: CommandFlags(),
      payload:[0x00, 0x00,
        0x01, 0x00, 0x00, // wind thres-lo
        0x11, 0x00, 0x00, // sun thres-hi
        0x12, 0x00, 0x00, // sun thres-lo
        0x13, 0x00, 0x00, // sun delay-hi
        0x14, 0x00, 0x00, // sun delay-lo
        0xFF, 0x00, 0x00
      ],
      messageId: messageId,
    ));

    return await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  Future<V2Message?> writeSunProfile({
    required int sunThresHi,
    required int sunThresLo,
    required int sunDelayHi,
    required int sunDelayLo,
    required int windThresLo,
    required bool winterMode,
    required int matrix
  }) async {
    _loading = true;
    notifyListeners();
    
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.anaMulti,
      control: ControlFlags(raw: [0x20, 0x60]),
      command: winterMode ? CommandFlags(raw: [0x20, 0x40]) : CommandFlags(),
      payload: [0x00, 0x00,
        0x01, ...AnalogValues.fromWindLevel(windThresLo),
        0x11, ...AnalogValues.fromSunLevel(sunThresHi),
        0x12, ...AnalogValues.fromSunLevel(sunThresLo),
        0x13, ...AnalogValues.fromInt16(sunDelayHi),
        0x14, ...AnalogValues.fromInt16(sunDelayLo),
        0xFF, matrix, 0x00,
      ],
      messageId: messageId,
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );

    _loading = false;
    notifyListeners();

    return result;
  }

  Future<void> lockUnlock({
    required bool up,
    required bool down,
  }) async {
    final messageId = cp._nextQueueId();
    int lock = 0;
    if(up)   lock  = 1 << 5;
    if(down) lock |= 1 << 6;

    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.control,
      control: ControlFlags(raw: [0x20, 0x60]),
      command: CommandFlags(raw: [0x00, lock]),
      messageId: messageId,
    ));
  }

  Future<void> setEnableSunProtection(bool enable) async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.none,
      control: ControlFlags(raw: [0x20, 0x80]),
      command: CommandFlags(raw: [0x00, enable ? 0x80 : 0x00]),
      messageId: messageId,
    ));

    await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  Future<void> setEnableMemoryFunction(bool enable) async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.none,
      control: ControlFlags(raw: [0x28, 0x00]),
      command: CommandFlags(raw: [enable ? 0x08 : 0x00, 0x00]),
      messageId: messageId,
    ));

    await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  

  /**********************************/
  /**********************************/
  /**********************************/
  /************ RUN TIMES ***********/
  /**********************************/
  /**********************************/
  /**********************************/

  Future<V2Message?> setRuntime ({
    double runTime = 0,
    double turnTime = 0,
    double pulseTime = 0,
  }) async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.db,
      control: ControlFlags(),
      command: CommandFlags(),
      payload:[0x00, 0x00,
        0x09, ...AnalogValues.fromInt16((runTime * 10).toInt()),
        0x0A, ...AnalogValues.fromInt16((turnTime * 10).toInt()),
        0x0B, ...AnalogValues.fromInt16((pulseTime * 10).toInt())
      ],
      messageId: messageId,
    ));

    return await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );
  }

  Future<AnalogValues?> getRuntime () async {
    final messageId = cp._nextQueueId();
    await cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      dataType: CPDatatype.db,
      control: ControlFlags(raw: [0x80, 0x00]),
      command: CommandFlags(),
      payload:[0x00, 0x00,
        0x09, 0x00, 0x00, /// Run time
        0x0A, 0x00, 0x00, /// Turning time
        0x0B, 0x00, 0x00  /// Pulse time
      ],
      messageId: messageId,
    ));

    final result = await _waitFor(
      CPAccId.dataSendPanRn,
      messageFilter: (message) => message.macAddress == mac && message.messageId == messageId,
    );

    return result.analog;
  }

  void save() async {
    unawaited(cp.dbPutNode?.call(this));
  }
}
