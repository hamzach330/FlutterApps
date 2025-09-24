/// The plugin library
library centronic_plus;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import "package:collection/collection.dart";
import 'package:hex/hex.dart';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/message.dart';
import 'package:mt_interface/protocol.dart';
import 'package:version/version.dart';

export 'package:hex/hex.dart';

part 'package:centronic_plus_protocol/mutators.dart';
part 'package:centronic_plus_protocol/node.dart';
part 'package:centronic_plus_protocol/enums.dart';
part 'package:centronic_plus_protocol/message.dart';
part 'package:centronic_plus_protocol/const.dart';
part 'package:centronic_plus_protocol/flags.dart';
part 'package:centronic_plus_protocol/models.dart';
part 'package:centronic_plus_protocol/multicast.dart';
part 'package:centronic_plus_protocol/store.dart';

class CentronicPlus
    extends MTReaderWriter<V2Message, List<int>, CentronicPlus> {
  CentronicPlus({
    this.dbPutNode,
    this.dbGetNode,
    this.dbGetNodes,
    this.dbDeleteNode,
    this.dbDeleteAllNodes,
  });

  late final CentronicPlusMulticast multicast = CentronicPlusMulticast(this);
  final Map<CPAccId, List<FilteredFuture>> _futures = {};

  Future<bool> Function(CentronicPlusNode node)? dbPutNode;
  Future<CentronicPlusNode?> Function(String mac, CentronicPlus)? dbGetNode;
  Future<List<CentronicPlusNode>?> Function(CentronicPlus)? dbGetNodes;
  Future<bool> Function(CentronicPlusNode node)? dbDeleteNode;
  Future<bool> Function(String panId)? dbDeleteAllNodes;

  final cPPort = 0x07;

  /// [cPPort] is a constant used in the communication with the device
  final _stx = 0x02;

  /// [_stx] telegram start byte
  late final stx = ascii.decode([_stx]);
  final _etx = 0x03;

  /// [_etx] telegram stop byte
  late final etx = ascii.decode([_etx]);

  /// V2 Queue
  int _idQueueCounter = -1;
  int _nextQueueId() {
    _idQueueCounter++;
    if (_idQueueCounter > 0xFFEE) {
      _idQueueCounter = 0;
    }
    return _idQueueCounter;
  }

  List<int> _readBuffer = [];

  bool meshUpdatePending = false;
  Timer? meshUpdateTimeout;

  StreamSubscription<List<MTEndpoint>>? endpointListener;
  StreamSubscription<MTConnectionState>? connectionStateListener;

  List<CentronicPlusNode> nodes = [];
  
  // CPReadPanResult? info;
  Version? swVersion;
  Version get version => swVersion ?? Version(0, 0, 0);

  bool matchVersion({
    Version? min,
    Version? max,
  }) {
    if (version == Version(0, 0, 0)) {
      return false;
    }

    if (min == null) min = Version(0, 0, 0);
    if (max == null) max = Version(255, 255, 255);

    if (version >= min && version <= max) {
      return true;
    }
    return false;
  }

  bool waitForUSB = false;
  String? waitForMac;

  bool discovery = false;

  /// whether node discovery is running

  String pan = "";
  bool coupled = false;
  String? mac;
  int rssi = 0;

  isRootNode(String mac) {
    return getNodeByMac(mac);
  }

  StreamController<String>? _tunnelRcv;

  Future<void> writeAscii(String data) async {
    log(data, name: "CP >>>");
    await endpoint.write(ascii.encode(data));
  }

  @override
  Future<void> writeMessage(V2Message message) async {
    throw UnimplementedError("Use writeAscii instead");
  }

  Future<T?> writeMessageWithResponse<T extends V2Message>(T message) {
    throw UnimplementedError("Use writeAscii instead");
  }

  @override
  void read(List<int> data) {
    _readBuffer.addAll(data);
    // _logBuffer.addAll(data);

    try{
      log(ascii.decode(data), name: "CP READ BUFFER");
    } catch(e) {
      log("Error decoding read buffer: $e", name: "CP READ BUFFER");
      return;
    }

    if (_tunnelRcv != null) {
      if (_readBuffer.contains(_etx) == true &&
          _readBuffer.contains(_stx) == true) {
        final messages = ascii.decode(_readBuffer).split("\n");
        for (final message in messages) {
          _tunnelRcv?.add(message);
        }
        _readBuffer.clear();
      }
      return;
    }

    if (_readBuffer.contains(_etx) == false) {
      return;
    }

    while (_readBuffer.contains(_etx) && _readBuffer.contains(_stx)) {
      final start = _readBuffer.indexOf(_stx);
      final end = _readBuffer.indexOf(_etx);

      if (start > end) {
        _readBuffer = _readBuffer.sublist(end + 1, _readBuffer.length);
      } else {
        final sublist = _readBuffer.sublist(start + 1, end);
        final asciiDecoded = ascii.decode(sublist);
        final hexDecoded = HEX.decode(asciiDecoded);

        _readBuffer = _readBuffer.sublist(end + 1);
        try {
          rssi = (int.parse(ascii.decode(_readBuffer.sublist(0, _readBuffer.indexOf(0x0A))))).toInt();
          _asyncHandleMessage(hexDecoded);
        } catch(e) {
          _asyncHandleMessage(hexDecoded);
        }
      }
    }
  }

  Future<void> closeTunnel() async {
    await tunnelWrite(Uint8List.fromList([27]));
    await tunnelWrite(ascii.encode("\n"), true);
    await _tunnelRcv?.close();
    _tunnelRcv = null;
  }

  StreamController<String>? openTunnel(String mac) {
    if (endpoint.connected == false) {
      return null;
    }

    _tunnelRcv = StreamController<String>.broadcast();

    final tunnelRequest = HEX.encode(
        [cPPort, 0x1B, 0x01, 0x0B, ...HEX.decode(mac), 0x00, 0x00, 0x00]);
    tunnelWrite(ascii.encode("$stx$tunnelRequest$etx"), true);

    return _tunnelRcv;
  }

  tunnelWrite(Uint8List data, [bool raw = false]) async {
    await endpoint.write(raw == false ? ascii.encode(HEX.encode(data)) : data);
  }

  /// Implementation of the CRC16 calculcation
  /// CITT CRC16 polynomial ^16 + ^12 + ^5 + 1
  /// From Contiki
  static int crc16Add(int b, int acc) {
    /// FIXED FROM ORIGINAL IMPL
    /// BECAUSE DART INTEGERS ARE 64 BIT
    /// AND
    /// DUE TO SHIFTING LEFT WE'LL END UP WITH A NUMBER BIGGER 16 BIT
    acc ^= b;
    acc = (acc >> 8) | (acc << 8);
    acc ^= (acc & 0xff00) << 4;
    acc &= 0xFFFF;

    /// <-----
    acc ^= (acc >> 8) >> 4;
    acc ^= (acc & 0xff00) >> 5;
    return acc;
  }

  /// Implementation of the CRC16 calculcation
  /// CITT CRC16 polynomial ^16 + ^12 + ^5 + 1
  /// From Contiki
  static int crc16Data(Uint8List data, int len, int acc) {
    int i;

    for (i = 0; i < len; ++i) {
      acc = crc16Add(data[i], acc);
    }
    return acc;
  }

  @override
  void notifyListeners() => updateStream.add(this);

  Future<void> initEndpoint({
    bool readMesh = true,
  }) async {


    meshUpdatePending = false;

    final info = await readPanId();
    mac = info.mac;
    pan = info.pan;
    coupled = info.coupled;

    if(nodes.isEmpty) {
      nodes = await dbGetNodes?.call(this) ?? [];
    }

    notifyListeners();

    swVersion = await readUsbVersion();

    if(readMesh && nodes.isNotEmpty) {
      unawaited(updateMesh());
    }

    notifyListeners();
  }

  Future<void> updateMesh({Duration duration = const Duration(seconds: 1)}) async {
    if (coupled == false) {
      return;
    }

    if (meshUpdatePending) {
      meshUpdateTimeout?.cancel();
    }

    meshUpdatePending = true;
    meshUpdateTimeout = Timer(duration, () {
      meshUpdatePending = false;
      notifyListeners();
    });

    await stopReadAllNodes();
    multicast.getAllNodes();

    notifyListeners();
  }

  CentronicPlusNode? getNodeByMac(String mac) {
    return nodes.firstWhereOrNull((node) => node.mac == mac);
  }

  void clearNodes() {
    nodes.clear();
    unawaited(dbDeleteAllNodes?.call(pan));
    notifyListeners();
  }

  void unselectNodes() {
    for (final node in nodes) {
      if (node._selected == true) {
        node._selected = false;
        node.notifyListeners();
      }
    }
  }

  /// List of nodes with the same panId as our stick.
  List<CentronicPlusNode> getOwnNodes() =>
      nodes.where((node) => node.panId == pan).toList();

  /// List of nodes with the same panId as our stick and groupBits set.
  List<CentronicPlusNode> getGroupedNodes() => nodes
      .where((node) => node.panId == pan && node.groupId > 0)
      .toList();

  /// List of nodes with the same panId as our stick and no groupBits set.
  List<CentronicPlusNode> getUngroupedNodes() => nodes
      .where((node) => node.panId == pan && node.groupId == 0)
      .toList();

  /// List of nodes with the other panId as our stick.
  List<CentronicPlusNode> getForeignNodes() =>
      nodes.where((node) => node.panId != pan).toList();

  /// A list of devices in the sticks network
  List<CentronicPlusNode> getOwnNetwork(String nameFilter) {
    if (nameFilter != "") {
      return getOwnNodes();
    } else {
      List<CentronicPlusNode> nodes = [];
      var lookup = {};

      for (final obj in getOwnNodes()) {
        lookup[obj.mac] = obj;
        obj.children.clear();
      }

      for (final obj in getOwnNodes()) {
        if (obj.parentMac != CP_EMPTY_MAC &&
            obj.parentMac != mac &&
            lookup.containsKey(obj.parentMac)) {
          lookup[obj.parentMac].children.add(obj);
        } else {
          nodes.add(obj);
        }
      }

      return nodes;
    }
  }

  Map<String?, List<CentronicPlusNode>> getForeignNetworks(String filter) {
    List<CentronicPlusNode> nodes = getForeignNodes()
      ..sort((a, b) => (a.mac).compareTo(b.mac));

    if (filter != "") {
      nodes = getForeignNodes()
          .where((node) =>
              node.name?.toLowerCase().contains(filter.toLowerCase()) == true)
          .toList();
    }

    return Map.fromEntries(groupBy(nodes,
            (CentronicPlusNode node) => node.coupled == true ? node.panId : "0")
        .entries
        .toList()
      ..sort((e1, e2) => e1.key!.compareTo(e2.key!)));
  }

  Future<V2Message> _waitFor(
    CPAccId key, {
    MessageFilter? messageFilter,
    Duration timeout = const Duration(seconds: 10),
  }) {
    final resolver = FilteredFuture(filter: messageFilter);
    _futures.putIfAbsent(key, () => []);
    _futures[key]!.add(resolver);
    return resolver.future.timeout(timeout);
  }

  bool _completeFor(CPAccId key, V2Message? result) {
    final filteredFutures = _futures[key] ?? [];
    bool completed = false;
    for (final filteredFuture in List<FilteredFuture>.from(filteredFutures)) {
      if (!filteredFuture.isCompleted) {
        if (filteredFuture.filter != null) {
          if (result != null && filteredFuture.filter!(result)) {
            filteredFutures.remove(filteredFuture);
            filteredFuture.complete(result);
            completed = true;
          }
        } else {
          filteredFutures.remove(filteredFuture);
          filteredFuture.complete(result);
          completed = true;
        }
      }
    }
    return completed;
  }

  void _removeNode(CentronicPlusNode node) {
    nodes.remove(node);
    unawaited(dbDeleteNode?.call(node));
    notifyListeners();
  }

  CentronicPlusNode _addNodeIfNew(CentronicPlusNode newNode) {
    final node = nodes.firstWhereOrNull((node) => node.mac == newNode.mac);
    if (node == null) {
      nodes.add(newNode);
      notifyListeners();
    }
    node?.cp = this;
    return node ?? newNode;
  }

  void _asyncHandleMessage(List<int> telegram) async {
    final message = V2Message();
    message.decode(telegram);

    if (_completeFor(message.accessId, message)) {
      return;
    }

    if (message.accessId == CPAccId.dataSendPanRn) {
      _addNodeIfNew(CentronicPlusNode(
        panId: pan,
        mac: message.macAddress,
        initiator: message.initiator,
        cp: this,
      ))._asyncHandleMessage(message);
    } else if (message.accessId == CPAccId.replyReadNeighborTab) {
      await _handleNeighbourTableEntry(message);
    } else if (message.accessId == CPAccId.replyReadRoutingTab) {
      await _handleRoutingTableEntry(message);
    } else if (message.accessId == CPAccId.replyTiReadNeighborTab) {
      await _handleTiNeighbourTableEntry(message);
    } else if (message.accessId == CPAccId.replyReadAllNodesStop) {
      // _intermediateNodes.clear();
    }
  }

  Future<void> _handleNeighbourTableEntry(V2Message message) async {
    _addNodeIfNew(CentronicPlusNode(
      panId: "",
      mac: message.macAddress,
      initiator: message.initiator,
      cp: this,
    ));

    notifyListeners();
  }

  Future<void> _handleRoutingTableEntry(V2Message message) async {
    _addNodeIfNew(CentronicPlusNode(
      panId: "",
      mac: message.macAddress,
      initiator: message.initiator,
      cp: this,
    ));

    notifyListeners();
  }

  Future<void> _handleTiNeighbourTableEntry(V2Message message) async {
    final node = nodes.firstWhereOrNull((node) => node.mac == message.macAddress);

    if(node != null && node.panId != message.tiPan) {
      node.remove();
      notifyListeners();
    }

    _addNodeIfNew(CentronicPlusNode(
      panId: message.tiPan,
      mac: message.macAddress,
      initiator: message.tiInitiator,
      cp: this,
      coupled: message.tiCoupled,
    ));

    notifyListeners();
  }

  List<CentronicPlusNode> getNodesFrom64BitMask(List<int> mask) {
    final _mask = ByteData.sublistView(Uint8List.fromList(mask)).getUint64(0, Endian.little);
    final groupIds = <int>[];
    for (int bit = 0; bit < 64; bit++) {
      if ((_mask & (1 << bit)) != 0) {
        groupIds.add(bit + 1);
      }
    }
    return getOwnNodes().where((node) => groupIds.contains(node.groupId)).toList();
  }

  List<int> getPage64FromGroupIds(Iterable<int> groupIds) {
    final pages = getPageListFromGroupIds(groupIds);
    var mask = pages.expand((e) => e.sublist(1,4)).toList();
    if(mask.length > 8) {
      mask = mask.sublist(0, 8);
    }
    while (mask.length < 8) {
      mask.add(0);
    }
    mask = mask.sublist(0, 8);
    return mask;
  }



  /// FIXME: This is only really applicable on cc11 where there first 2 2/3 pages are stored as 64 bit.
  /// FIXME: Make pageData actual 8bit int?
  /// [pageData] Uint8List of 8 bytes
  /// returns List<String> of 32 bit group IDs to be consumed by encodeX
  List<String> getPage32FromPage64(List<int> pageData) {
    if (pageData.length != 8) {
      throw ArgumentError('Need exactly 8 bytes');
    }

    final pages = [
      if(pageData[0] != 0 || pageData[1] != 0 || pageData[2] != 0) [0,  pageData[0], pageData[1], pageData[2]],
      if(pageData[3] != 0 || pageData[4] != 0 || pageData[5] != 0) [32, pageData[3], pageData[4], pageData[5]],
      if(pageData[6] != 0 || pageData[7] != 0)                     [64, pageData[6], pageData[7], 0x00],
    ];

    return <String>[
      for (final page in pages) page.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')
    ];
  }

  Uint8List _to24(int m) => (ByteData(3)
        ..setUint8(0,  m        & 0xFF)
        ..setUint8(1, (m >> 8)  & 0xFF)
        ..setUint8(2, (m >> 16) & 0xFF))
      .buffer.asUint8List();

  Uint8List _to16as24(int m16) => (ByteData(3)
        ..setUint8(0,  m16       & 0xFF)
        ..setUint8(1, (m16 >> 8) & 0xFF)
        ..setUint8(2, 0x00))
      .buffer.asUint8List();

  List<List<int>> getPageListFromGroupIds(Iterable<int> groupIds) {
    int allBits = 0;
    for (final g in groupIds) {
      if (g < 0 || g > 63) throw ArgumentError('group out of range (0..63): $g');
      allBits |= (1 << (g - 1));
    }

    final int p0 =  allBits         & 0xFFFFFF;
    final int p1 = (allBits >> 24)  & 0xFFFFFF;
    final int p2 = (allBits >> 48)  & 0xFFFF;

    return <List<int>>[
      if (p0 != 0) [0, ..._to24(p0)],
      if (p1 != 0) [32, ..._to24(p1)],
      if (p2 != 0) [64, ..._to16as24(p2)],
    ];
  }

  List<int> getGroupIdsFromPage24List(List<int> bytes) {
    if (bytes.length != 4) {
      throw ArgumentError('Need exactly 4 bytes');
    }

    final int pageGrpCode = bytes[0];
    final int page = (pageGrpCode >> 5) & 0x07; // 0..7
    final int mask = (bytes[1]) | (bytes[2] << 8) | (bytes[3] << 16);
    final ids = <int>[];

    for (int bit = 0; bit < 24; bit++) {
      if ((mask & (1 << bit)) != 0) {
        ids.add(page * 24 + bit);
      }
    }

    return ids;
  }

  int getNextUnusedGroupId() {
    final usedGroups = getOwnNodes().map((n) => n.groupId).toSet();
    int i;
    for (i = 0; usedGroups.contains(i); i++);
    log("Next unused group ID: $i", name: "CP.findNextUnusedGroupId");
    return i;
  }

  Future<bool> nodeAssignGroupId(CentronicPlusNode node, {bool save = true}) async {
    final stick = CentronicPlusNode(
      panId: pan,
      mac: mac ?? CP_EMPTY_MAC,
      cp: this,
    );

    final nextGroupId = getNextUnusedGroupId();

    unawaited(node.assignGroups(stick, [nextGroupId]));
    node.groupId = nextGroupId;
    
    if(save) {
      await dbPutNode?.call(node);
    }

    node.enableFeedback();
    return true;
  }

  Future<bool> nodeUnassignGroupId(CentronicPlusNode node) async {
    if (node.groupId == 0) {
      node.visible = false;
      await dbPutNode?.call(node);
      notifyListeners();
      return true;
    }

    final stick = CentronicPlusNode(
      panId: pan,
      mac: mac ?? CP_EMPTY_MAC,
      cp: this,
    );

    unawaited(node.unassignGroups(stick));
    node.visible = false;
    node.groupId = 0;
    unawaited(dbPutNode?.call(node));
    notifyListeners();
    return true;
  }

  List<CentronicPlusNode> getNodesForGroupId(int group) {
    return getOwnNodes().where((node) => (node.groupId & group) != 0).toList();
  }

  Future<Version> readUsbVersion() async {
    unawaited(writeAscii(V2Message.encode(
      accessId: CPAccId.readSwVersion.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    )));
    final result = await _waitFor(CPAccId.replyReadSwVersion);
    return Version(result.payload[8], result.payload[9], result.payload[10]);
  }

  Future<CPReadPanResult> readPanId() async {
    unawaited(writeAscii(V2Message.encode(
      accessId: CPAccId.readPanId.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    )));
    
    final result = await _waitFor(CPAccId.replyReadPanId);
    final panResult = CPReadPanResult.fromV2Message(result);

    pan = panResult.pan;
    coupled = panResult.coupled;
    mac = panResult.mac;

    return panResult;
  }

  void stickUpdate() {
    unawaited(writeAscii(V2Message.encode(
      accessId: CPAccId.updateUsb.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    )));
  }

  void stickReset() {
    unawaited(writeAscii(V2Message.encode(
      accessId: CPAccId.resetFactory.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    )));

    unawaited(dbDeleteAllNodes?.call(pan));

    pan = "";
    coupled = false;
    mac = null;
    nodes.clear();
    // notifyListeners();
  }

  Future<void> _setCoupledFlag(String mac) async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.tiSendCoupleCmd.hex, // 0x15,
      mac: mac,
      extraPayload: "00 01 00",
    ));

    final result = await _waitFor(CPAccId.replyTiSendCoupleCmd, messageFilter: (message) => message.macAddress == mac);

    log("$result", name: "CP set coupled flag");
  }

  Future<void> startReadRoutingTable() async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.readRoutingTab.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    ));
    await _waitFor(CPAccId.replyReadRoutingTab);
  }

  Future<void> _startReadAllNodes() async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.readAllNodesStart.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    ));
    await _waitFor(CPAccId.replyReadAllNodesStart);
  }

  Future<void> _stopReadAllNodes() async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.readAllNodesStop.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 00 00",
    ));
    await _waitFor(CPAccId.replyReadAllNodesStop);
  }

  Timer? _readNodesTimer;

  Future<void> readAllNodes(
      {Duration duration = const Duration(minutes: 15)}) async {
    discovery = true;
    notifyListeners();

    _readNodesTimer?.cancel();
    _readNodesTimer = Timer(duration, () => stopReadAllNodes());
    await _startReadAllNodes();
  }

  Future<void> stopReadAllNodes() async {
    _readNodesTimer?.cancel();
    _readNodesTimer = null;

    nodes.removeWhere((node) => node.panId != pan);

    if (discovery) {
      discovery = false;
      notifyListeners();
      await _stopReadAllNodes();
    } else {
      notifyListeners();
    }
  }

  Future<void> restartReadAllNodes(
      {Duration duration = const Duration(minutes: 15)}) async {
    _readNodesTimer?.cancel();
    _readNodesTimer = null;

    if (discovery) {
      await stopReadAllNodes();
      await Future.delayed(const Duration(seconds: 1));
      await readAllNodes(duration: duration);
    }
  }

  Future<int> _updateUnnamedNodes({bool save = false}) async {
    int count = 0;
    for (final node in getOwnNodes().where((n) => n.name == null)) {
      try {
        await node.updateInfo(save: save);
        await Future.delayed(const Duration(milliseconds: 200));
        count++;
      } catch (e) {/* No work */}
    }
    return count;
  }

  Future<void> _updateNamedNodes() async {
    for (final node in getOwnNodes().where((n) => n.name != null)) {
      try {
        if(node.isCentral == false) {
          await node.updateProperties();
          await node.updateSoftwareInfo();
          node.notifyListeners();
        }
        node.getProductName();
      } catch (e) {
        log("Error updating node ${node.mac}: $e", name: "CP Node Update");
      }
    }
  }

  Future<V2Message> _readNeighborTable() async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.readNeighborTab.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 04 00",
    ));
    return await _waitFor(CPAccId.replyReadNeighborTab);
  }

  Future<List<CentronicPlusNode>> readNeighborTable() async {
    final result = await _readNeighborTable();
    int repeat = result.payload[result.payload.length - 3];

    if (result.macAddress != CP_EMPTY_MAC) {
      _addNodeIfNew(CentronicPlusNode(
        mac: result.macAddress,
        panId: pan,
        cp: this
      ));
    }

    while(repeat > 0) {
      final result = await _readNeighborTable();
      if (result.macAddress != CP_EMPTY_MAC) {
        _addNodeIfNew(CentronicPlusNode(
          mac: result.macAddress,
          panId: pan,
          cp: this
        ));
      }
      repeat--;
    }

    // _updateUnnamedNodes();
    notifyListeners();
    return nodes;
  }
  
  Future<V2Message> _readRoutingTable() async {
    await writeAscii(V2Message.encode(
      accessId: CPAccId.readRoutingTab.hex,
      mac: CP_EMPTY_MAC,
      extraPayload: "00 04 00",
    ));
    return await _waitFor(CPAccId.replyReadRoutingTab);
  }

  Future<List<CentronicPlusNode>> readRoutingTable() async {
    final result = await _readRoutingTable();
    int repeat = result.payload[result.payload.length - 3];

    if (result.macAddress != CP_EMPTY_MAC) {
      _addNodeIfNew(CentronicPlusNode(
        mac: result.macAddress,
        panId: pan,
        cp: this
      ));
    }

    while(repeat > 0) {
      final result = await _readRoutingTable();
      if (result.macAddress != CP_EMPTY_MAC) {
        _addNodeIfNew(CentronicPlusNode(
          mac: result.macAddress,
          panId: pan,
          cp: this
        ));
      }
      repeat--;
    }

    // _updateUnnamedNodes();

    notifyListeners();
    return nodes;
  }

  setAutoResponse(bool enable) {
    unawaited(writeAscii(V2Message.encodeDTCommand(
      accessId: CPAccId.dataSendPanRMulticast,
      dataType: CPDatatype.db,
      command: CommandFlags(),
      control: ControlFlags(),
      mac: mac ?? CP_EMPTY_MAC,
      payload: [0x00, 0x00, 0x84, enable ? 0x01 : 0x00, 0x00],
    )));
  }
}
