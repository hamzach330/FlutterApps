part of 'centronic_plus.dart';

typedef MessageFilter = bool Function(V2Message);

// FilteredFuture: A future that can be filtered by a message filter.
class FilteredFuture {
  final MessageFilter? filter;
  final Completer<V2Message> _completer = Completer<V2Message>();

  FilteredFuture({this.filter});

  Future<V2Message> get future => _completer.future;
  bool get isCompleted => _completer.isCompleted;
  void complete(V2Message? message) {
    if (!_completer.isCompleted) {
      _completer.complete(message);
    }
  }
}

// FilteredListener: A listener that can be filtered by a message filter.
class FilteredListener {
  final MessageFilter? filter;
  final FutureOr<void> Function(V2Message)? callback;

  FilteredListener({this.filter, this.callback});
}

class V2Message extends MTMessageInterface{
  // Fields
  int _port = 0;
  CPAccId _accessId = CPAccId.dataSendPanRn;
  int _blnr = 0;
  int _blen = 0;
  bool _lenok = false;
  List<int> payload = [];

  // Decode method
  void decode(List<int> payload) {
    _port = payload[0];
    _accessId = CPAccId.values.firstWhere((v) => v.value == payload[1]);
    _blnr = payload[2];
    _blen = payload[3];
    _lenok = payload.length == _blen;
    this.payload = payload.sublist(4);

    log(Mutators.toHexString(payload), name: "CP <<<");

    try {
      log("  Port:          0x${Mutators.toHexByte(_port)}", name: "CPDecode");
      log("  Access ID:     ${accessId.name} (0x${_accessId.hex})", name: "CPDecode");
      log("  Block number:  0x${Mutators.toHexByte(_blnr)}", name: "CPDecode");
      log("  Block length:  0x${Mutators.toHexByte(_blen)}", name: "CPDecode");
      log("  MAC:           $macAddress", name: "CPDecode");
      log("  Protocol type: 0x${Mutators.toHexByte(protocolType)}", name: "CPDecode");
      log("  Manufacturer:  0x${Mutators.toHexByte(manufacturer)}", name: "CPDecode");
      log("  Initiator:     ${initiator.name} (0x${initiator.hex})", name: "CPDecode");
      log("  Group:         0x${Mutators.toHexString(group)}", name: "CPDecode");
      log("  Data type:     ${dataType.name} (0x${dataType.hex})", name: "CPDecode");
      log("  Control:       ${control.hex} (${control})", name: "CPDecode");
      log("  Command:       ${command.hex} (${command})", name: "CPDecode");
      log("  Extra payload: 0x${Mutators.toHexString(extraPayload)}", name: "CPDecode");
      log("  Sync:          ${messageId}", name: "CPDecode");
      log("  Priority:      $priority", name: "CPDecode");
      log("  Timeout:       $timeout", name: "CPDecode");
    } catch (e) {
      log("Decoding this ${accessId.name} message is not fully supported.", name: "CPDecode");
    }
  }

  // Static string factory
  static String encode({
    String port = CP_DEFAULT_PORT,
    String accessId = "01",
    String block = "01",
    String mac = "",
    String protocolType = "",
    String manufacturer = "",
    String initiator = "",
    String group = "",
    String dataType = "",
    String control = "",
    String command = "",
    String extraPayload = "",
    int? messageId, // aka sync counter
    String timeout = "",
    String priority = "",
  }) {
    String _sync = "";
    if (messageId != null) {
      _sync = messageId.toRadixString(16).padLeft(4, '0');
    }
    String message =
        "$mac$protocolType$manufacturer$initiator$group$dataType$control$command$extraPayload$_sync$timeout$priority";
    message = message.replaceAll(" ", "");
    String length = (message.length ~/ 2).toRadixString(16).padLeft(2, '0');
    return "\x02$port$accessId$block$length$message\x03";
  }

  static String encodeDTCommand({
    CPAccId accessId = CPAccId.dataSendPanRnUnicast,
    required String mac,
    String protocolType = "01",
    CPDatatype dataType = CPDatatype.control,
    CPInitiator initiator = CPInitiator.central0,
    String group = CP_ALL_GROUPS,
    ControlFlags? control, // const [0x20, 0x00],
    CommandFlags? command, // const [0x20, 0x00],
    List<int> payload = const [0x00, 0x00],
    int? messageId,
    String timeout = "05",
    String priority = "01",
  }) {
    return encode(
      accessId: accessId.hex,
      mac: mac,
      manufacturer: MANUFACTURER,
      protocolType: protocolType,
      initiator: initiator.hex,
      group: group,
      dataType: dataType.hex,
      control: control == null ? "" : control.hex,
      command: command == null ? "" : command.hex,
      extraPayload: payload.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      messageId: messageId,
      timeout: timeout,
      priority: priority,
    );
  }

  // Properties
  bool get lengthOk => _lenok;
  CPAccId get accessId => _accessId;
  int get blockNumber => _blnr;
  int get blockLength => _blen;
  int get port => _port;

  String get macAddress => Mutators.toHexString(payload.sublist(0, 8));
  int get protocolType => payload[8];
  int get manufacturer => payload[9];
  CPInitiator get initiator =>
      Mutators.toInitiator(payload[10]) ?? CPInitiator.none;
  List<int> get group => payload.sublist(11, 15);

  CPDatatype get dataType {
    try {
      return Mutators.toDatatype(payload[15])!;
    } catch (_) {
      return CPDatatype.none;
    }
  }

  ControlFlags get control => ControlFlags(raw: payload.sublist(16, 18));
  CommandFlags get command => CommandFlags(raw: payload.sublist(18, 20));
  List<int> get extraPayload => payload.sublist(20);

  int get messageId {
    var s = payload.sublist(payload.length - 4, payload.length - 2);
    return (s[0] << 8) | s[1];
  }

  int get priority => payload[payload.length - 2];

  AnalogValues get analog =>
      AnalogValues(raw: payload.sublist(20, payload.length - 4));

  int get timeout => payload.last;


  /// TI SPECIFIC
  bool get tiCoupled => Mutators.toBool(payload[12]);
  CPInitiator get tiInitiator => Mutators.toInitiator(payload[16]) ?? CPInitiator.none;
  String get tiPan => Mutators.toHexString(payload.sublist(8, 12));
}
