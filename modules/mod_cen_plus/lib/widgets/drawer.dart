part of '../module.dart';

class CPDrawer extends StatefulWidget {
  static const path = '${CPHome.path}/drawer';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      return NoTransitionPage(
        key: ValueKey(state.matchedLocation),
        child: const CPDrawer(),
      );
    }
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const CPDrawer({
    super.key,
  });

  @override
  State<CPDrawer> createState() => _CPDrawerState();
}

class _CPDrawerState extends State<CPDrawer> {
  late final CentronicPlus centronicPlus;
  late final NavigatorState? navigator;
  late final UICMessengerState messenger;
  late final OtauInfoProvider otauProvider;
  late final CPExpandSettings extendedSettings;
  bool enableAutoResponse     = false;
  bool betaUpdateChannel      = false;
  RemoteStickInfo? updateFile;

  @override
  initState() {
    super.initState();
    centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
    navigator = UICApp.of(context).navigator;
    messenger = UICMessenger.of(context);
    otauProvider = Provider.of<OtauInfoProvider>(context, listen: false);
    extendedSettings = Provider.of<CPExpandSettings>(context, listen: false);
  }

  void stickAutoUpdate() async {
    final theme = Theme.of(context);
    final centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
    final answer = await messenger.alert(AlertStickUpdate(centronicPlus: centronicPlus));

    if(updateFile != null && (answer ?? false)) {
      final inputPath = await updateFile?.getLocalPath();

      if (inputPath != null) {
        final file = File(inputPath);
        final bytes = await file.readAsBytes();

        try {
          final outputPath = await FilePicker.platform.saveFile(
            type: FileType.custom,
            allowedExtensions: ['uf2'],
            dialogTitle: 'Auf CPLUSstick speichern'.i18n,
            bytes: bytes,
            fileName: (updateFile?.fileName?.split(".")?..removeLast())?.join(".") // remove file extension
          );
          if(theme.platform != TargetPlatform.android && outputPath != null) {
            final output = File(outputPath);
            await output.writeAsBytes(bytes);
          }
        } catch(e) {
          dev.log("$e");
        }
      }
    }
  }

  void stickUpdate () async {
    final centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
    await messenger.alert(AlertStickUpdate(centronicPlus: centronicPlus));
  }

  RemoteStickInfo? checkForUpdates() {
    if(updateFile != null) {

    }

    int pid = 0;
    if(centronicPlus.endpoint is USBDesktopEndpoint) {
      pid = (centronicPlus.endpoint as USBDesktopEndpoint).info.productId ?? 0;
    }

    if(centronicPlus.endpoint is USBAndroidEndpoint) {
      pid = (centronicPlus.endpoint as USBAndroidEndpoint).info.productId ?? 0;
    }

    if(pid == 0) {
      return null;
    }

    updateFile = otauProvider.localInfo?.stickFiles?.firstWhereOrNull((stickFile) {
      return stickFile.pid == pid;
    });

    if(updateFile == null) {
      return null;
    }

    if((updateFile?.version ?? Version(0,0,0)) > centronicPlus.version) {
      return updateFile;
    }
    
    return null;
  }

  void quit (BuildContext context) async {
    final module = Provider.of<CPModule>(context, listen: false);
    module.quit(context);
  }

  void toggleAutoResponse() async {
    if(enableAutoResponse) {
      enableAutoResponse = false;
      // centronicPlus.setAutoResponse(false);
    } else {
      final answer = await messenger.alert(UICSimpleConfirmationAlert(
        title: "Rückmeldung aktivieren".i18n,
        child: Text("Hiermit werden alle eingelernten Geräte aufgefordert, alle Statusänderungen direkt an das Tool zu senden. Denken Sie unbedingt daran, diese Rückmeldung wieder zu deaktivieren, wenn der USB Stick nach Abschluss der Installation nicht in der Installation verbleibt (da sonst unnötige Rückmeldungen in die Installation erfolgen). Ältere Softwarestände unterstützen diese Funktion gegebenenfalls noch nicht.".i18n),
      ));
      if(answer == true) {
        centronicPlus.setAutoResponse(true);
        enableAutoResponse = true;
      }
    }
    setState(() {});
  }

  void toggleUpdateChannel() {
    betaUpdateChannel = !betaUpdateChannel;
    if(betaUpdateChannel) {
      otauProvider.channel = OtauChannel.beta;
    } else {
      otauProvider.channel = OtauChannel.release;
    }
    otauProvider.update();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CPExpandSettings>(
      builder: (context, settings, _) {
        return Consumer<CentronicPlus>(
          builder: (context, centronicPlus, _) {
            final theme = Theme.of(context);
            final bodyMediumMuted = theme.bodyMediumMuted;
            return UICDrawer(
              leading: GestureDetector(
                onTap: settings.unlock,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: theme.brightness == Brightness.light
                    ? Image.asset("assets/images/centronic_plus_complete.png", filterQuality: FilterQuality.high)
                    : Image.asset("assets/images/centronic_plus_complete_dark.png",  filterQuality: FilterQuality.high),
                ),
              ),
            
              trailing: UICDrawerTile(
                leading: const Icon(Icons.exit_to_app_rounded, ),
                title: Text('Konfiguration beenden'.i18n, style: const TextStyle()),
                onPressed: (context) => quit(context),
              ),
            
              children: [
                UICInfo(
                  style: UICColorScheme.variant,
                  margin: EdgeInsets.all(theme.defaultWhiteSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informationen zum USB-Stick".i18n, style: theme.textTheme.titleMedium),
                      
                      const Divider(),
                      
                      Row(
                        children: [
                          Text("Teilnehmer einer Installation:".i18n, style: bodyMediumMuted),
                          Expanded(
                            child: centronicPlus.coupled == true
                              ? Text("Ja".i18n, textAlign: TextAlign.right, style: bodyMediumMuted?.copyWith(color: theme.colorScheme.successVariant.primary))
                              : Text("Nein".i18n, textAlign: TextAlign.right, style: bodyMediumMuted?.copyWith(color: theme.colorScheme.errorVariant.primary))
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("MAC-ID:".i18n, style: bodyMediumMuted),
                          Expanded(
                            child: Text(centronicPlus.mac ?? "",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right
                            )
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("Installations-ID:".i18n, style: bodyMediumMuted),
                          Expanded(child: Text(centronicPlus.pan, textAlign: TextAlign.right,))
                        ],
                      ),
                      Row(
                        children: [
                          Text("Firmware:".i18n, style: bodyMediumMuted),
                          Expanded(child: Text("${centronicPlus.swVersion}", textAlign: TextAlign.right))
                        ],
                      ),
                            
                      Consumer<UICPackageInfoProvider>(
                        builder: (context, packageInfo, _) {
                          return Row(
                            children: [
                              Text("App-Version:".i18n, style: bodyMediumMuted),
                              Expanded(
                                child: Text(packageInfo.version?.version ?? "", textAlign: TextAlign.right)
                              )
                            ],
                          );
                        }
                      ),
                      
                      const Divider(),
            
                      Row(
                        children: [
                          Text("Bekannte Geräte:".i18n, style: TextStyle(color: theme.colorScheme.successVariant.primary)),
                          Expanded(
                            child: Text("${centronicPlus.getOwnNodes().length}", textAlign: TextAlign.end, style: TextStyle(color: theme.colorScheme.successVariant.primary))
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                if(checkForUpdates() != null) UICDrawerTile(
                  onPressed: (_) => stickAutoUpdate(),
                  leading: const RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.security_update)
                  ),
                  title: Text("USB-Update verfügbar".i18n),
                ),
    
                if(settings.expand) UICDrawerTile(
                  onPressed: (_) => stickUpdate(),
                  title: Text("USB-Firmware aktualisieren".i18n),
                  leading: const RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.security_update),
                  )
                ),
            
                UICDrawerTile(
                  leading: const Icon(Icons.reset_tv),
                  title: Text('USB-Stick zurücksetzen'.i18n),
                  onPressed: (_) => AlertStickReset.open(context),
                ),
                
                Divider(
                  indent: theme.defaultWhiteSpace,
                  endIndent: theme.defaultWhiteSpace
                ),
                
                UICDrawerTile(
                  onPressed: (context) async {
                    centronicPlus.updateMesh();
                  },
                  leading: centronicPlus.meshUpdatePending
                    ? const Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: UICProgressIndicator(),
                      )
                    : const Icon(Icons.search),
                    title: Text("Ansicht aktualisieren".i18n),
                ),
                
                Padding(
                  padding: EdgeInsets.all(theme.defaultWhiteSpace),
                  child: UICElevatedButton(
                    shrink: false,
                    leading: const Icon(Icons.refresh_rounded),
                    style: UICColorScheme.warn,
                    onPressed: () async {
                      final scaffold = UICScaffold.of(context);
                      scaffold.hideSecondaryBody();
                      centronicPlus.clearNodes();
                      
                      centronicPlus.updateMesh();
                    },
                    child: Text("Alle Daten neu einlesen".i18n),
                  ),
                ),
            
                if(extendedSettings.expand) Divider(
                  indent: theme.defaultWhiteSpace,
                  endIndent: theme.defaultWhiteSpace
                ),
    
                if(extendedSettings.expand) Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Rückmeldung aktivieren".i18n)
                      ),
                      UICSwitch(
                        value: enableAutoResponse,
                        onChanged: toggleAutoResponse,
                      ),
                    ],
                  ),
                ),
    
                if(extendedSettings.expand) const UICSpacer(),
    
                if(extendedSettings.expand) Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Beta Updates".i18n)
                      ),
                      UICSwitch(
                        value: betaUpdateChannel,
                        onChanged: toggleUpdateChannel,
                      ),
                    ],
                  ),
                ),
    
                Divider(
                  indent: theme.defaultWhiteSpace,
                  endIndent: theme.defaultWhiteSpace
                ),
            
                UICDrawerTile(
                  onPressed: MulticastControlAlert.open,
                  leading: const Icon(Icons.broadcast_on_personal_rounded),
                  title: Text("Globale Befehle".i18n),
                ),
            
                if(extendedSettings.expand) UICDrawerTile(
                  onPressed: OTAAllAlert.open,
                  leading: const RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.security_update),
                  ),
                  title: Text("Alle Geräte aktualisieren".i18n),
                ),
            
                if(extendedSettings.expand) Divider(
                  indent: theme.defaultWhiteSpace,
                  endIndent: theme.defaultWhiteSpace
                ),
              ]
            );
          }
        );
      }
    );
  }
}
