part of 'centronic_plus.dart';

class CentronicPlusMulticast {
  static const String mac = '0000000000000000';
  final CentronicPlus _cp;

  CentronicPlusMulticast(CentronicPlus centronicPlus): _cp = centronicPlus;

  void lockUnlock({
    required bool up,
    required bool down,
    String group = CP_ALL_GROUPS
  }) {
    int lock = 0;
    if(up)   lock  = 1 << 5;
    if(down) lock |= 1 << 6;

    unawaited(_cp.writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      mac: mac,
      group: group,
      dataType: CPDatatype.none,
      control: ControlFlags(raw: [0x20, 0x60]),
      command:  CommandFlags(raw: [0x00, lock]),
    )));
  }

  void _sendDigitalCommand(CommandFlags command, {String group = ""}) {
    unawaited(_cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanBroadcast, /// On the network layer what exactly is the difference between Broadcast and Multicast?
      dataType: CPDatatype.simpleDigital,
      group: group,
      control: ControlFlags(),
      command: command,
    )));
  }

  void _sendAnalogControl(List<int> payload, {String group = CP_ALL_GROUPS}) {
    unawaited(_cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanBroadcast,
      dataType: CPDatatype.control,
      group: group,
      control: ControlFlags(analog: true),
      command: CommandFlags(),
      payload: payload,
    )));
  }

  // FIXME: 16bit
  void sendPositionCommand(double position, {CPEVOProfile? evoProfile, String group = CP_ALL_GROUPS}) {
    List<int> evoData = [];
    if(evoProfile != null) {
      evoData = [0x10, evoProfile.value, 0x00];
    }

    _sendAnalogControl([
      0x00, (255 * (position / 100)).toInt(), ...evoData,
    ]);
  }

  // FIXME: 16biit
  void sendSlatPositionCommand(double slat, {CPEVOProfile? evoProfile, String group = CP_ALL_GROUPS}) {
    List<int> evoData = [];
    if(evoProfile != null) {
      evoData = [0x10, evoProfile.value, 0x00];
    }

    _sendAnalogControl([
      0x00, 0x00, 0x0F, (255 * (slat / 100)).toInt(), ...evoData,
    ]);
  }

  void sendDownCommand({bool silent = false, String group = CP_ALL_GROUPS}) async {
    _sendDigitalCommand(CommandFlags(down: true), group: group);
  }

  void sendUpCommand({bool silent = false, String group = CP_ALL_GROUPS}) async {
    _sendDigitalCommand(CommandFlags(up: true), group: group);
  }

  void sendStopCommand({bool silent = false, String group = CP_ALL_GROUPS}) async {
    _sendDigitalCommand(CommandFlags(stop: true), group: group);
  }

  void movePreset1({String group = CP_ALL_GROUPS}) {
    _sendDigitalCommand(CommandFlags(raw: [0x24, 0x00]), group: group);
  }

  void movePreset2({String group = CP_ALL_GROUPS}) {
    _sendDigitalCommand(CommandFlags(raw: [0x44, 0x00]), group: group);
  }

  void deleteEndposition({silent = false, String group = CP_ALL_GROUPS}) {
    _sendDigitalCommand(CommandFlags(raw: [0x81 | 0x10, 0x00]), group: group);
  }

  void setEnableSunProtection({required bool enable, String group = CP_ALL_GROUPS}) async {
    await _cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.none,
      group: group,
      control: ControlFlags(raw: [0x20, 0x80]),
      command: CommandFlags(raw: [0x00, enable ? 0x80 : 0x00]),
    ));
  }

  void setEnableMemoryFunction({required bool enable, String group = CP_ALL_GROUPS}) async {
    await _cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.none,
      group: group,
      control: ControlFlags(raw: [0x28, 0x00]),
      command: CommandFlags(raw: [enable ? 0x08 : 0x00, 0x00]),
    ));
  }

  void restartAllDevices({String group = CP_ALL_GROUPS}) async {
    await _cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.scSwReset,
      group: group,
      control: ControlFlags(raw: [0x20, 0x00]),
      command: CommandFlags(raw: [0xFF, 0xBA]),
    ));
  }

  void _sendSpecialCommand({
    required CPDatatype dataType,
    String group = CP_ALL_GROUPS
  }) {
    unawaited(_cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: dataType,
      group: group,
      control: ControlFlags(digital: true),
      command: CommandFlags(raw: [0xFF, 0xBA]),
    )));
  }

  void scFactoryResetCentronic({group = CP_ALL_GROUPS}) {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetCentronic, group: group);
  }

  void scFactoryResetAll({group = CP_ALL_GROUPS}) {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetAll, group: group);
  }

  void scFactoryResetCentronicPlus({group = CP_ALL_GROUPS}) {
    _sendSpecialCommand(dataType: CPDatatype.scFactoryResetCentronicPlus, group: group);
  }

  void removeSensorAssignments({group = CP_ALL_GROUPS}) async {
    await _cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.db,
      group: group,
      control: ControlFlags(raw: [0x01, 0x00]),
      command: CommandFlags(),
      payload: [0x00, 0x01, 0x82, CPInitiator.sunDuskWind.value],
    ));
    
    await _cp.writeAscii(V2Message.encodeDTCommand(
      mac: mac,
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.db,
      group: group,
      control: ControlFlags(raw: [0x01, 0x00]),
      command: CommandFlags(),
      payload: [0x00, 0x01, 0x82, CPInitiator.sunDuskWindHumTempout.value],
    ));
  }

  /// FIXME: This is actually read parent.
  void _meshRead({String group = CP_ALL_GROUPS}) async {
    final messageId = _cp._nextQueueId();
    await _cp.writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      mac: "00 00 00 00 00 00 00 00",
      protocolType: "01",
      group: group,
      dataType: CPDatatype.page3,
      control: ControlFlags(read: true),
      command: CommandFlags(),
      payload: [0, 0],
      messageId: messageId,
    ));
  }

  void _updateDeviceName({String group = CP_ALL_GROUPS}) async {
    await _cp.writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      mac: mac,
      protocolType: "80",
      group: group,
      dataType: CPDatatype.textRead32char,
      payload: List.filled(32, 0x00),
      priority: "",
      timeout: "",
    ));
  }

  void _updateSoftwareInfo({String group = CP_ALL_GROUPS}) async {
    final messageId = _cp._nextQueueId();
    
    await _cp.writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      mac: mac,
      dataType: CPDatatype.service,
      group: group,
      control: ControlFlags(),
      command: CommandFlags(),
      payload: [0x00], // ???
      messageId: messageId,
    ));
  }

  void _updateProperties({String group = CP_ALL_GROUPS}) async {
    final messageId = _cp._nextQueueId();
    
    await _cp.writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      mac: mac,
      control: ControlFlags(read: true),
      command: CommandFlags(),
      dataType: CPDatatype.page1,
      group: group,
      payload: [0x00, 0x00], // ???
      messageId: messageId,
    ));
  }

  // Timer? _updateTimer;
  void getAllNodes({int reps = 10}) async {
    if(await _cp._updateUnnamedNodes() == 0) {
      _meshRead();
      await Future.delayed(Duration(milliseconds: 500));
      _updateDeviceName();
      await Future.delayed(Duration(milliseconds: 500));
      _updateSoftwareInfo();
      await Future.delayed(Duration(milliseconds: 500));
      _updateProperties();
      await Future.delayed(Duration(milliseconds: 500));
      await _cp._updateUnnamedNodes(save: false);
    }
  }
}
