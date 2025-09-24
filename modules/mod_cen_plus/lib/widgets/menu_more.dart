part of '../module.dart';

class CPMenuMore extends StatefulWidget {
  const CPMenuMore({super.key});

  @override
  State<CPMenuMore> createState() => _CPMenuMoreState();
}

class _CPMenuMoreState extends State<CPMenuMore> {
  late final centronicPlus = context.read<CentronicPlus>();
  late final OtauInfoProvider otauProvider;
  RemoteStickInfo? updateFile;

  bool enableAutoResponse     = false;
  bool betaUpdateChannel      = false;

  bool get showingMessage => _showingMessage;
  bool _showingMessage = false;
  set showingMessage(bool value) {
    if (_showingMessage != value) {
      setState(() {
        _showingMessage = value;
      });
    }
  }

  @override
  initState() {
    super.initState();
    otauProvider = Provider.of<OtauInfoProvider>(context, listen: false);
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

  void toggleAutoResponse() async {
    final messenger = UICMessenger.of(context);
    if(enableAutoResponse) {
      enableAutoResponse = false;
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

  void stickAutoUpdate() async {
    final theme = Theme.of(context);
    final centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
    final messenger = UICMessenger.of(context);
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
    final messenger = UICMessenger.of(context);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CPExpandSettings>(
      builder: (context, extendedSettings, _) {
        return MenuAnchor(
          menuChildren: [

            if(checkForUpdates() != null) MenuItemButton(
              onPressed: () => stickAutoUpdate(),
              leadingIcon: const RotatedBox(
                quarterTurns: 2,
                child: Icon(Icons.security_update)
              ),
              child: Text("USB-Update verfügbar".i18n),
            ),

            if(extendedSettings.expand) MenuItemButton(
              onPressed: () => stickUpdate(),
              leadingIcon: const RotatedBox(
                quarterTurns: 2,
                child: Icon(Icons.security_update),
              ),
              child: Text("USB-Firmware aktualisieren".i18n),
            ),

            MenuItemButton(
              onPressed: () {
                CPInfoAlert.open(context);
              },
              leadingIcon: const Icon(Icons.info_outline_rounded),
              child: Text("Info".i18n),
            ),
        
            MenuItemButton(
              onPressed: () {
                CPTeachinAlert.open(context, false);
              },
              leadingIcon: const Icon(Icons.add_box_outlined),
              child: Text("Neue Geräte hinzufügen".i18n),
            ),
        
            MenuItemButton(
              onPressed: () {
                centronicPlus.updateMesh();
              },
              leadingIcon: const Icon(Icons.refresh_rounded),
              child: Text("Ansicht aktualisieren".i18n),
            ),
        
            Divider(),
        
            MenuItemButton(
              onPressed: () async {
                final messenger = UICMessenger.of(context);
                final scaffold = UICScaffold.of(context);
        
                final answer = await messenger.alert(UICSimpleQuestionAlert(
                  title: "Lokale Daten löschen".i18n,
                  child: Text("Möchten Sie wirklich alle lokalen Daten löschen? Dies kann nicht rückgängig gemacht werden.".i18n),
                ));
        
                if (answer == true) {
                  scaffold.hideSecondaryBody();
                  centronicPlus.clearNodes();
                  centronicPlus.updateMesh();
                }
              },
              leadingIcon: const Icon(Icons.delete_forever_rounded),
              child: Text("Lokale Daten löschen".i18n),
            ),
        
            Divider(),
        
            MenuItemButton(
              onPressed: () {
                AlertStickReset.open(context);
              },
              leadingIcon: const Icon(Icons.reset_tv),
              child: Text("USB-Stick zurücksetzen".i18n),
            ),

            if(extendedSettings.expand) Divider(),

            if(extendedSettings.expand) PopupMenuItem(
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

            if(extendedSettings.expand) PopupMenuItem(
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
            
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
        );
      }
    );
  }
}

