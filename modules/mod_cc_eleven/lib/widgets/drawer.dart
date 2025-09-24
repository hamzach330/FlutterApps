part of '../module.dart';

class CCElevenDrawer extends StatefulWidget {
  static const path = '${CPHome.path}/drawer';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      return NoTransitionPage(
        child: const CCElevenDrawer(),
      );
    }
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const CCElevenDrawer({
    super.key,
  });

  @override
  State<CCElevenDrawer> createState() => _CCElevenDrawerState();
}

class _CCElevenDrawerState extends State<CCElevenDrawer> {
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
    final module = Provider.of<CCElevenModule>(context, listen: false);
    module.quit(context);
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
    final otaAvailable = CCSettings.getOtaForCC11(context) != null;

    return Consumer<CentronicPlus>(
      builder: (context, centronicPlus, _) {
        return Consumer<CPExpandSettings>(
          builder: (context, settings, _) {
            final theme = Theme.of(context);
            return UICDrawer(
              leading: GestureDetector(
                onTap: settings.unlock,
                child: Container(
                  height: 150,
                  margin: EdgeInsets.all(theme.defaultWhiteSpace),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/images/CC11_Steckdose_1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            
              trailing: UICDrawerTile(
                leading: const Icon(Icons.exit_to_app_rounded, ),
                title: Text('Konfiguration beenden'.i18n, style: const TextStyle()),
                onPressed: (context) => quit(context),
              ),
            
              children: [
    
                Divider(
                  indent: theme.defaultWhiteSpace,
                  endIndent: theme.defaultWhiteSpace
                ),

                UICDrawerTile(
                  onPressed: (context) {
                    centronicPlus.unselectNodes();
                    CCElevenHome.go(context);
                  },
                  leading: Icon(Icons.home_rounded),
                  title: Text("Übersicht".i18n),
                ),

                UICDrawerTile(
                  onPressed: (context) {
                    centronicPlus.unselectNodes();
                    CCElevenClocks.go(context);
                  },
                  leading: Icon(Icons.watch_later_outlined),
                  title: Text("Schaltzeiten".i18n),
                ),

                UICDrawerTile(
                  onPressed: (context) {
                    centronicPlus.unselectNodes();
                    CCElevenSunProtection.go(context);
                  },
                  leading: Icon(Icons.wb_sunny_rounded),
                  title: Text("Sonnenschutz".i18n),
                ),

                UICDrawerTile(
                  onPressed: (context) {
                    centronicPlus.unselectNodes();
                    CCSettings.go(context);
                  },
                  leading: otaAvailable ? UICBadge(
                    label: Icon(Icons.upgrade_rounded, size: 12, color: Theme.of(context).colorScheme.successVariant.onPrimary),
                    backgroundColor: Theme.of(context).colorScheme.successVariant.primary,
                    child: Icon(Icons.settings_rounded)
                  ) : Icon(Icons.settings_rounded),
                  title: Text("System".i18n),
                ),

              ]
            );
          }
        );
      }
    );
  }
}