part of '../module.dart';

enum OtaFSM {
  init,
  checkVersion,
  v0Transfer,
  v1WaitTargetOk,
  v1Transfer,
  v1SendSignature,
  v1WaitSignatureOk,
  waitForRestart,
  done,
}

class OtaView extends StatefulWidget {
  static const pathName = 'ota';
  static const path = '${CPNodeAdminView.basePath}/:id/$pathName';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: const OtaView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const OtaView({super.key, this.extend = false, this.nodes});

  final bool extend;
  final List<CentronicPlusNode>? nodes;

  @override
  State<OtaView> createState() => _OtaViewState();
}

class _OtaViewState extends State<OtaView> {
  late final int chunkSize  = Theme.of(context).platform != TargetPlatform.macOS ? 32 : 32;
  // final chunkSize    = 63;
  late final otaInfo        = Provider.of<OtauInfoProvider>(context, listen: false);
  late final centronicPlus  = Provider.of<CentronicPlus>(context, listen: false);
  late final extended       = Provider.of<CPExpandSettings>(context, listen: false);

  CentronicPlusNode get node {
    final nodes = widget.nodes;
    if(nodes != null && nodes.length > nodeIndex) {
      return nodes[nodeIndex];
    } else if (nodes != null) {
      throw OtaNoMoreNodes();
    }
    return Provider.of<CentronicPlusNode>(context, listen: false);
  }

  RemoteOTAUInfo? update;

  static const hydroContext = "CPOTA000";
  static const publicKey    = [
    0xba, 0x2e, 0x37, 0x3b, 0x9d, 0xc2, 0x1e, 0xa4, 0xd5, 0x00, 0xa3,
    0x1f, 0x98, 0xf7, 0xe4, 0xf4, 0xf2, 0x28, 0x10, 0x45, 0x29, 0x95,
    0xf6, 0x20, 0xf1, 0x9e, 0x6e, 0xeb, 0x6f, 0x83, 0x3f, 0x41,
  ];

  OtaProgressProvider progress = OtaProgressProvider();

  int?             otaTarget;      //uint8:  0 = Funk, 1 = Motor
  int?             otaTargetId;    //uint32: Hardware ID
  List<int>?       eepromExpected;
  int?             eepromAddress;
  String?          otaType;
  List<int>?       eepromData;
  String?          checkVersion;
  Archive?         archive;
  YamlMap?         metadata;
  String?          filename;
  String?          otaFileName;
  Uint8List?       otaFileData;
  bool?            compatible;
  Uint8List?       signature;
  bool?            signatureValid;
  Uint8List?       crcChecksum;
  List<Uint8List>? chunks;
  List<Uint8List>? signatureChunks;
  Exception?       error;
  List<String>?    messages;
  bool             running = false;
  int              nodeIndex = 0;

  bool             _multiUpdateComplete = false;
  bool             _closingState = false;

  OtaFSM _otaState = OtaFSM.init;

  /// Not set to null on reset();
  bool             pending = false;
  StreamSubscription? tunnelSubscription;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdates();
    });
  }

  checkForUpdates() async {
    update = otaInfo.getOtaForNode(node);
    if(update != null) {
      await initOta(await update?.getLocalPath());
    }
  }

  /// Pick ota file. only returns [Archive] if metadata.yaml is found
  Future<void> pickOta(String? path) async {
    if(path == null) {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ["zip"],
        type: FileType.custom,
        lockParentWindow: true,
      );
      path = result?.files.single.path;
    }

    if (path == null) {
      throw OtaUserAbortException();
    } else {
      final inputStream = InputFileStream(path);
      archive = ZipDecoder().decodeStream(inputStream);
      filename = path.split('/').last;

      for (ArchiveFile file in archive?.files ?? []) {
        if (file.isFile) {
          if(file.name == "metadata.yml") {
            metadata = loadYaml(String.fromCharCodes(file.content));
            return;
          }
        }
      }
      throw OtaInvalidFileException();
    }
  }

  initOta (String? path) async {
    reset();
    pending = true;
    setState(() {});
    try {
      await pickOta(path);
      configure();

      if(otaType == "EEPROM") {
        await eepromRead();
        eepromCompare();
      } else if(otaType == "STATUS") {
        statusCompare();
      } else if(otaType == "USER") {

      }

      loadOtaFile();
      if(signature != null) {
        await verifySignature();
      }
      await getCrc();
      getChunks();

    } on Exception catch (e) {
      reset();
      error = e;
    } catch(e) {
      error = e is Exception ? e : Exception(e);
    }
    pending = false;
    setState(() {});
  }

  runOta() async {
    _otaState = OtaFSM.init;
    _sentPackage = -1;

    progress.done = false;
    progress.current = 0;
    progress.data = [
      ...List.filled(4, Uint8List.fromList([])),
      ...(chunks ?? []),
      ...List.filled(4, Uint8List.fromList([]))
    ];
    progress.length = (chunks?.length ?? 0);

    if(widget.nodes == null) {
      UICMessenger.of(context).alert(OTAAlert(
        progress: progress,
        onClose: () {
          closeOta();
        } // closeOta
      ));
    }
    tunnelSubscription = centronicPlus.openTunnel(node.mac)?.stream.listen(onTunnelMessage);
  }

  closeOta() async {
    if(_closingState) {
      dev.log("TUNNEL ALREADY IN CLOSING STATE!");
      dev.log("====================================");
      return;
    }
    if(widget.nodes != null) _closingState = true;
    tunnelSubscription?.cancel();
    tunnelSubscription = null;
    node.resetLocalInfo();

    if(widget.nodes == null) progress.done = true;
    await Future.delayed(const Duration(seconds: 5));
    await centronicPlus.closeTunnel();

    if(widget.nodes != null) {
      nodeIndex += 1;
      if(nodeIndex >= widget.nodes!.length) {
        nodeIndex = 0;
        _multiUpdateComplete = true;
        _closingState = false;
        progress.done = true;
      } else {
        _closingState = false;
        setState(reset);
        await checkForUpdates();
        await runOta();
      }
    } else {
      _closingState = false;
    }
  }

  reset() {
    metadata        = null;
    otaTarget       = null;
    otaTargetId     = null;
    eepromExpected  = null;
    eepromAddress   = null;
    otaType         = null;
    checkVersion    = null;
    archive         = null;
    compatible      = null;
    signature       = null;
    signatureValid  = null;
    filename        = null;
    eepromData      = null;
    error           = null;
    archive         = null;
    otaFileName     = null;
    otaFileData     = null;
    chunks          = null;
    messages        = null;
    running         = false;
    progress        = OtaProgressProvider();

    _sentPackage    = -1;

    _otaState = OtaFSM.init;
    // _closingState   = false;

    tunnelSubscription?.cancel();
    tunnelSubscription = null;
  }

  configure() {
    if(metadata?['CompatibleFirmware']?.isNotEmpty == true) {
      if (metadata?['Files'] is List == false || metadata?['CompatibleFirmware'] is List == false) {
        throw OtaInvalidFileException();
      }

      final YamlMap fwFiles  = metadata?['Files'].first;
      final YamlMap fwCompat = metadata?['CompatibleFirmware'].first;

      otaType     = fwCompat["Type"];
      if(otaType != "EEPROM" && otaType != "STATUS" && otaType != "USER") {
        throw OtaFwIncompatibleException();
      } else if(otaType == "EEPROM") {
        eepromExpected = List.from(fwCompat["Expected"]);
      } else if(otaType == "STATUS") {
        eepromExpected = [fwCompat["Expected"]];
      }

      eepromAddress  = fwCompat["Address"];
      checkVersion   = fwCompat["Version"];

      otaTarget = metadata?["Target"];
      otaTargetId = metadata?["TargetId"];

      otaFileName    = fwFiles["FileName"];
      final sig      = fwFiles["Signature"];
      if(sig != null) signature = base64.decode(sig);

      if(otaFileName == null) throw OtaInvalidFileException();

    } else {
      throw OtaInvalidFileException();
    }
  }

  eepromRead () async {
    try {
      eepromData = await node.readEeprom(
        mac: node.mac,
        length: eepromExpected?.length ?? 1,
        address: [0, eepromAddress ?? 0]
      );
    } catch(e) {
      throw OtaEepromReadException();
    }
  }

  eepromCompare () {
    compatible = (const ListEquality()).equals(eepromData, eepromExpected);
    if(compatible != true) {
      throw OtaFwIncompatibleException();
    }
  }

  statusCompare () {
    final len = node.artId?.length ?? 0;
    final artLo = node.artId?.substring(len - 4, len) ?? "0";
    final status = [int.parse(artLo)];

    compatible = (const ListEquality()).equals(status, eepromExpected);
    if(compatible != true) {
      throw OtaFwIncompatibleException();
    }
  }

  loadOtaFile () {
    for (ArchiveFile file in archive?.files ?? []) {
      if (file.isFile) {
        if(file.name == otaFileName) {
          otaFileData = file.content;
          return;
        }
      }
    }
    throw OtaMissingUpdateFileException();
  }

  verifySignature () async {
    final valid = await compute((params) {
      final pContext   = hydroContext.toNativeUtf8().cast<Char>();

      final pSignature = calloc<Uint8>(params.$2.length);
      final signature  = pSignature.asTypedList(params.$2.length);

      final pOtaData   = calloc<Uint8>(params.$1.length);
      final otaData    = pOtaData.asTypedList(params.$1.length);

      final pKey       = calloc<Uint8>(publicKey.length);
      final key        = pKey.asTypedList(publicKey.length);
      
      signature.setAll(0, params.$2);
      otaData.setAll(0, params.$1);
      key.setAll(0, publicKey);
      final valid = bindings.hydro_sign_verify(pSignature, pOtaData.cast<Void>(), params.$1.length, pContext, pKey);

      calloc.free(pSignature);
      calloc.free(pKey);
      calloc.free(pContext);
      calloc.free(pOtaData);

      return valid == 0;
    }, (otaFileData!, signature!));

    if(!valid) throw OtaSignatureException();

    signatureValid = valid;
  }

  getChunks () {
    chunks = [];
    final length = otaFileData?.length ?? 0;
    for (var i = 0; i < length; i += chunkSize) {
      chunks?.add((otaFileData ?? Uint8List.fromList([])).sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }

  getSignatureChunks() {
    signatureChunks = [];
    final length = signature?.length ?? 0;
    for (var i = 0; i < length; i += chunkSize) {
      signatureChunks!.add(signature!.sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return signatureChunks;
  }

  getCrc () async {
    crcChecksum = await compute((data) {
      final acc = CentronicPlus.crc16Data(Uint8List.fromList(data), data.length, 0);
      return Uint8List.fromList([0, 0, 0, 0, 0, 0, acc >> 8 & 0xFF, acc & 0xFF]);
    }, otaFileData ?? Uint8List.fromList([]));
  }

  Uint8List getOtaFileLength () {
    final size = otaFileData?.length ?? 0;
    final length = Uint8List.fromList(List.filled(4, 0x00));
    length[0] = size >> 24 & 0xFF;
    length[1] = size >> 16 & 0xFF;
    length[2] = size >> 8  & 0xFF;
    length[3] = size & 0xFF;
    return length;
  }

  int  _sentPackage = -1;
  Stopwatch? stopwatch;

  Duration elapsed = Duration.zero;
  void onTunnelMessage(String data) async {
    if(stopwatch != null) elapsed = stopwatch!.elapsed;
    final logPrefix = "$elapsed TUNNEL ${_otaState.name}";

    if (data.isEmpty) return;


    if (data.contains("\x1b")) {
      dev.log("$logPrefix: RECV ESC '$data', closeOta");
      closeOta();
      return;
    }

    if (data.startsWith("\u0002072B") == false) {
      dev.log("$logPrefix: RCV UNKNOWN: '$data'");
      dev.log("====================================");
      return;
    }

    final incoming = data.substring(5, data.length - 1);
    final bytes = HEX.decode(incoming);
    final [blnr, blen, ...binData] = bytes;

    dev.log("$logPrefix: RCV: '$data'");
    dev.log("$logPrefix: RCV: $blnr, $blen, $binData");

    switch (_otaState) {
      case OtaFSM.init:
        if (blnr == 1) {
          stopwatch = Stopwatch()..start();
          dev.log("$logPrefix: -> CheckVersion");
          dev.log("====================================");
          _otaState = OtaFSM.checkVersion;
          Timer.periodic(const Duration(milliseconds: 500), (Timer timer){
            if(stopwatch != null) elapsed = stopwatch!.elapsed;
            if (_otaState == OtaFSM.checkVersion && elapsed.inMilliseconds > 500) {
              timer.cancel();
              final payload = "${HEX.encode(getOtaFileLength())}\n";
              centronicPlus.tunnelWrite(ascii.encode(payload), true);
              dev.log("$logPrefix: timeout OTA0.0");
              dev.log("$logPrefix: SND: ${ascii.encode(payload)}");
              dev.log("====================================");

              _otaState = OtaFSM.v0Transfer;
              return;
            }
          });
        }

      case OtaFSM.checkVersion:

        if (blnr != 2) return;
        if (ascii.decode(binData).startsWith("OTA1.0")) {

          final payload = "BA07A001"
              "${otaTarget?.toRadixString(16).padLeft(2, "0")}"
              "${otaTargetId?.toRadixString(16).padLeft(8, "0")}"
              "${otaFileData?.length.toRadixString(16).padLeft(8, "0")}"
              "00000000\n";
          centronicPlus.tunnelWrite(ascii.encode(payload), true);
          dev.log("$logPrefix: OTA1.0, OfferTarget");
          dev.log("$logPrefix: SND: ${ascii.encode(payload)}");
          dev.log("====================================");
          _otaState = OtaFSM.v1WaitTargetOk;
          return;
        }

      case OtaFSM.v0Transfer:
        if (blnr != 1) return; //no ack
        if (_sentPackage < (chunks?.length ?? 0) - 1) {
          _sentPackage += 1;
          progress.current = _sentPackage;
          centronicPlus.tunnelWrite(ascii.encode("${HEX.encode(chunks![_sentPackage])}\r"), true);
          dev.log("$logPrefix: SND: ${Mutators.toHexString(chunks![_sentPackage])}");
          dev.log("====================================");
          return;
        }
        // send crc
        final payload = "${HEX.encode(crcChecksum ?? Uint8List.fromList([]))}\n";
        centronicPlus.tunnelWrite(ascii.encode(payload), true);

        dev.log("$logPrefix: SND CRC: ${Mutators.toHexString(crcChecksum ?? Uint8List.fromList([]))}");
        dev.log("$logPrefix: OTA COMPLETE!");
        dev.log("====================================");
        _otaState = OtaFSM.waitForRestart;
        closeOta();

      case OtaFSM.v1WaitTargetOk:
        if (blnr != 2) return;
        if (listEquals(binData, [0xba, 0x07, 0xa0, 0x02])) {
          dev.log("$logPrefix: TargetOK received");
          dev.log("====================================");
          _otaState = OtaFSM.v1Transfer;
          return onTunnelMessage(data);
        }
        dev.log("$logPrefix: invalid response from target, close ota");
        dev.log("====================================");
        closeOta();

      case OtaFSM.v1Transfer:
        if (blnr != 1 && blnr != 2) return; //noack
        if (_sentPackage < (chunks?.length ?? 0) - 1) {
          _sentPackage += 1;
          progress.current = _sentPackage;
          centronicPlus.tunnelWrite(ascii.encode("${HEX.encode(chunks![_sentPackage])}\r"), true);
          dev.log("$logPrefix: SND: ${Mutators.toHexString(chunks![_sentPackage])}");
          dev.log("====================================");
          return;
        }
        _otaState = OtaFSM.v1SendSignature;
        _sentPackage = -1;
        getSignatureChunks();
        centronicPlus.tunnelWrite(ascii.encode("BA07A003\n"), true);

      case OtaFSM.v1SendSignature:
        if (blnr != 1 && blnr != 2) return; //noack
        if (_sentPackage < (signatureChunks?.length ?? 0) - 1) {
          _sentPackage += 1;
          final payload = "${HEX.encode(signatureChunks![_sentPackage])}\n";
          centronicPlus.tunnelWrite(ascii.encode(payload), true);
          dev.log("$logPrefix: SND: ${Mutators.toHexString(signatureChunks![_sentPackage])}");
          dev.log("====================================");
          return;
        }
        _otaState = OtaFSM.v1WaitSignatureOk;

      case OtaFSM.v1WaitSignatureOk:
        if(blnr != 2) return; //no ack
        if (listEquals(binData, [0xba, 0x07, 0xa0, 0x04])) {
          dev.log("$logPrefix: SIGNATURE VERIFIED BY DEVICE, DONE");
          dev.log("====================================");
          closeOta();
        }
      case OtaFSM.done:
      case OtaFSM.waitForRestart:
    }
  }


  Future close () async {
    final scaffold = UICScaffold.of(context);
    scaffold.hideSecondaryBody();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invalidUsbVersion = (centronicPlus.version) < Version(1,6,9);

    return UICPage(
      loading: pending,
      // pop: () => context.pop(),
      // close: (context) => close(),
      // title: "Firmware aktualisieren".i18n,
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(
          leading : UICTitle("Firmware aktualisieren".i18n),
        ),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            const CPNodeInfo(readOnly: true),

            if(invalidUsbVersion) Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text("Bitte aktualisieren Sie zuerst die Firmware Ihres USB-Sticks".i18n, textAlign: TextAlign.center,),
              ),
            ),

            if(update == null && extended.expand != true && invalidUsbVersion != true) Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text("Keine Aktualisierung verfügbar".i18n),
              ),
            ),

            if(widget.nodes != null) Text("Update: ${nodeIndex + 1} / ${widget.nodes?.length}".i18n),
        
            if(widget.nodes != null) ChangeNotifierProvider.value(
              value: progress,
              builder: (context, _) => Consumer<OtaProgressProvider>(
                builder: (context, progress, _) {
                  if (progress.done) {
                    return Text("Fertig".i18n);
                  }
                  return Text("Fortschritt: ${progress.current} / ${progress.length}".i18n);
                },
              ),
            ),
        
            const UICSpacer(2),
        
            if(update == null) const UICSpacer(2),
        
            if(extended.expand) Center(
              child: UICElevatedButton(
                style: UICColorScheme.variant,
                onPressed: () => initOta(null),
                leading: const Icon(Icons.file_open_rounded),
                child: Text("Updatedatei auswählen".i18n),
              ),
            ),
        
            if(extended.expand || error != null) const UICSpacer(),
        
            if(error != null) _OtaErrorView(error: error!),
        
            if(metadata != null) Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _OtaYamlInfo(metadata, filename, crcChecksum),
              ),
            ),
        
            const UICSpacer(2),
        
            if(compatible == true && archive != null) Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.successVariant.primary),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("Das Update ist für dieses Gerät geeignet.".i18n),
                )
              ],
            ),
        
            if(signatureValid == true && archive != null) Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.successVariant.primary),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text("Das Update wurde durch die Becker-Antriebe GmbH signiert.".i18n),
                    ),
                  )
                ],
              ),
            ),
        
            if(signatureValid != true && archive != null) Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("Das Update ist nicht signiert.".i18n),
                  )
                ],
              ),
            ),
        
            if(otaType == "USER") Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  const ImageIcon(
                    AssetImage("assets/images/biohazard.png"),
                    color: Colors.red,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("Die Kompatibilitätsprüfung für dieses Update ist deaktiviert!".i18n),
                  )
                ],
              ),
            ),
        
            const UICSpacer(2),
        
            if((signatureValid == true && archive != null) || (signature == null && archive != null)) Center(
              child: UICElevatedButton(
                style: UICColorScheme.success,
                onPressed: runOta,
                leading: const RotatedBox(
                  quarterTurns: 2,
                  child: Icon(Icons.security_update),
                ),
                child: Text("Firmware aktualisieren".i18n),
              ),
            ),
          ],
        ),
      ]
    );
  }
}

class _OtaErrorView extends StatelessWidget {
  final Exception error;
  const _OtaErrorView({
    required this.error
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer);

    /// not an error
    if(error is OtaUserAbortException) {
      return Container();
    }

    return Material(
      color: theme.brightness == Brightness.dark
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.errorContainer,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Icon(Icons.warning, size: 60, color: theme.colorScheme.onErrorContainer),
            const SizedBox(height: 20),
            switch (error) {
              (OtaEepromReadException _) => Text("Konnte EEPROM nicht lesen. Bitte versuchen Sie es erneut.".i18n, style: textStyle, textAlign: TextAlign.center),
              (OtaInvalidFileException _) => Text("Die ausgewählte Datei ist ungültig.".i18n, style: textStyle, textAlign: TextAlign.center),
              (OtaFwIncompatibleException _) => Text("Das ausgewählte Update ist nicht mit diesem Gerät kompatibel.".i18n, style: textStyle, textAlign: TextAlign.center),
              (OtaMissingSignatureException _) => Text("Das ausgewählte Update verfügt über keine Signatur.".i18n, style: textStyle, textAlign: TextAlign.center),
              (OtaMissingUpdateFileException _) => Text("Die ausgewählte Datei beinhaltet kein Update für Ihr Gerät.".i18n, style: textStyle, textAlign: TextAlign.center),
              (OtaSignatureException _) => Text("Das ausgewählte Update verfügt über keine gültige Signatur.".i18n, style: textStyle, textAlign: TextAlign.center),
              _ => Text("$error", style: textStyle, textAlign: TextAlign.center),
            },
          ],
        ),
      )
    );
  }
}

class _OtaYamlInfo extends StatelessWidget {
  final YamlMap? yml;
  final String? filename;
  final Uint8List? crc;

  const _OtaYamlInfo(this.yml, this.filename, this.crc);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OTAU Info ($filename)", style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text("Version".i18n)
            ),
            Text("${yml?["SrcVersion"]}", style: theme.bodyMediumMuted) 
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text("ArtNr".i18n)
            ),
            Text("${yml?["ArtNr"]}", style: theme.bodyMediumMuted) 
          ],
        ),
      ]
    );
  }
}
