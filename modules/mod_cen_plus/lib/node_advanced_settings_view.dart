part of 'module.dart';

class NodeAdvancedSettingsView extends StatelessWidget {
  static const pathName = 'advanced';
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
      child: const NodeAdvancedSettingsView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const NodeAdvancedSettingsView({super.key});

  confirm(BuildContext context, String title) async {
    return await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: title,
      child: Text("Durch das Löschen der Funkzuordnung werden alle Einstellungen zum gewählten Funksystem zurückgesetzt! Eingelernte Handsender verlieren dadurch die Funktion und müssen neu verbunden werden. Sind Sie sicher dass das Funksystem zurückgesetzt werden soll?".i18n)
    ));
  }

  confirmRmInitiator(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: "Achtung!".i18n,
      child: Text("Durch das Löschen der Sensorzuordnung werden alle verbundenen Sensoren von diesem Gerät entfernt! Sämtliche Überwachungsfunktionen werden deaktiviert.\nSind Sie sicher?".i18n)
    ));
  }

  confirmTeachinDisable(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleProceedAlert(
      title: "Achtung!".i18n,
      child: Text("Durch das Aktivieren der Sicherheitsfunktion wird das Herstellen der Lernbereitschaft nach einem Power-On dauerhaft deaktiviert! Wenn kein Zugriff mehr auf dieses Netz besteht (kein Handsender oder USB-Stick mehr vorhanden), ist eine Änderung des Netzes nicht mehr möglich. Eine Rücksetzung kann ausschließlich über einen Werksreset erfolgen - bei Antrieben erfordert dies ein Universal-Einstellset sowie Zugang zum Anschlusspunkt!".i18n)
    ));
  }

  scSwReset(BuildContext context, CentronicPlusNode node) async {
    final answer = await UICMessenger.of(context).alert(UICSimpleProceedAlert(
      title: "Gerät neu starten".i18n,
      child: Text("Das Gerät wird neu gestartet. Es kann einen Moment dauernd, bis alle Funktionen des Geräts wieder verfügbar sind.".i18n)
    ));

    if(answer == true) {
      node.scSwReset();
    }
  }

  Future pop (BuildContext context) async {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final centronicPlus = Provider.of<CentronicPlusNode>(context, listen: false).cp;
    final scaffold = UICScaffold.of(context);
    // final settings = Provider.of<CPExpandSettings>(context, listen: false);
    final theme = Theme.of(context);

    return UICPage(
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          body: UICTitle("Erweiterte Einstellungen".i18n),
        ),
        Consumer<CentronicPlusNode>(
          builder: (context, node, _) {
            return UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                const CPNodeInfo(),

                const UICSpacer(),
            
                UICElevatedButton(
                  shrink: false,
                  onPressed: () => scSwReset(context, node),
                  leading: const Icon(Icons.refresh),
                  child: Text("Gerät neu starten".i18n)
                ),
            
                const UICSpacer(),
            
                UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.success,
                  onPressed: () => OtaView.go(context, node),
                  leading: const RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.security_update),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  child: Text("Firmware aktualisieren".i18n),
                ),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) const UICSpacer(3),
                
                if(!node.isRemote && !node.isSensor && !node.isSwitch) UICButtonTitle(title: "Antriebssperre".i18n),
                
                if(!node.isRemote && !node.isSensor && !node.isSwitch) const UICSpacer(),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.success,
                  onPressed: () async {
                    node.lockUnlock(up: false, down: false);
                  },
                  leading: const Icon(Icons.lock_open_outlined),
                  child: Text("Sperre aufheben".i18n)
                ),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) const UICSpacer(),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.warn,
                  onPressed: () async {
                    node.lockUnlock(up: true, down: false);
                  },
                  leading: const Icon(Icons.lock_outline),
                  child: Text("AUF-Richtung sperren".i18n)
                ),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) const UICSpacer(),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.warn,
                  onPressed: () async {
                    node.lockUnlock(up: false, down: true);
                  },
                  leading: const Icon(Icons.lock_outline),
                  child: Text("AB-Richtung sperren".i18n)
                ),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) const UICSpacer(),
            
                if(!node.isRemote && !node.isSensor && !node.isSwitch) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.warn,
                  onPressed: () async {
                    node.lockUnlock(up: true, down: true);
                  },
                  leading: const Icon(Icons.lock_outline),
                  child: Text("AUF- & AB-Richtung sperren".i18n)
                ),
            
                const UICSpacer(3),
            
                UICButtonTitle(title: "CentronicPLUS".i18n),
                
                const UICSpacer(),
            
                UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.success,
                  onPressed: () => node.scTiRestart(),
                  leading: const Icon(Icons.play_circle),
                  child: Text("Einlernbereitschaft aktivieren".i18n),
                ),
            
                const UICSpacer(),
            
                UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.warn,
                  onPressed: () => node.scTiStop(),
                  leading: const Icon(Icons.stop_circle),
                  child: Text("Einlernbereitschaft deaktivieren".i18n),
                ),
            
                if(!node.isSensor && !node.isVC421) const UICSpacer(3),
            
                if(!node.isSensor && !node.isVC421) UICButtonTitle(title: "Centronic".i18n),
                
                if(!node.isSensor && !node.isVC421) const UICSpacer(),
            
                if(!node.isSensor && !node.isVC421) UICElevatedButton(
                  shrink: false,
                  onPressed: () => node.scCentronicPowerOnTimerStart(),
                  leading: const Icon(Icons.play_circle),
                  child: Text("Einlernbereitschaft aktivieren (Master)".i18n),
                ),
            
                if(!node.isSensor && !node.isVC421) const UICSpacer(),
            
                if(!node.isSensor && !node.isVC421) UICElevatedButton(
                  shrink: false,
                  onPressed: () => node.scCentronicLearnTimerStart(),
                  leading: const Icon(Icons.play_circle),
                  child: Text("Einlernbereitschaft aktivieren".i18n),
                ),
            
                if(!node.isSensor && !node.isVC421) const UICSpacer(),
            
                if(!node.isSensor && !node.isVC421) UICElevatedButton(
                  shrink: false,
                  onPressed: () => node.scCentronicDeleteTimerStart(),
                  leading: const Icon(Icons.play_circle),
                  child: Text("Auslernbereitschaft aktivieren".i18n),
                ),
            
                if(!node.isSensor && !node.isVC421) const UICSpacer(),
            
                if(!node.isSensor && !node.isVC421) UICElevatedButton(
                  shrink: false,
                  onPressed: () => node.scCentronicLearnDeleteTimersStop(),
                  leading: const Icon(Icons.stop_circle),
                  child: Text("Ein-/Auslernbereitschaft deaktivieren".i18n),
                ),
            
                if(!node.isSensor && !node.isRemote) const UICSpacer(3),
            
                if(!node.isSensor && !node.isRemote) UICButtonTitle(
                  style: UICColorScheme.error,
                  title: "Sensorzuordnung".i18n
                ),
            
                if(!node.isSensor && !node.isRemote) const UICSpacer(),
            
                if(!node.isSensor && !node.isRemote) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.error,
                  onPressed: () async {
                    if(await confirmRmInitiator(context) == true) {
                      await node.unassignGroupInitiator(CPInitiator.sunDuskWindHumTempout);
                      await node.unassignGroupInitiator(CPInitiator.sunDuskWind);
                    }
                  },
                  leading: const Icon(Icons.highlight_remove_rounded),
                  child: Text("Alle Sensorzuordnungen löschen".i18n)
                ),
            
                const UICSpacer(3),
            
                UICButtonTitle(
                  style: UICColorScheme.error,
                  title: "Funkzuordnung löschen".i18n,
                ),
            
                const UICSpacer(),
            
                if(!node.isSensor && !node.isVC421) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.error,
                  onPressed: () async {
                    final answer = await confirm(context, "Centronic Funkzuordnung löschen".i18n);
                    if(answer == true) {
                      // scaffold.closeEndDrawer();
                      node.scFactoryResetCentronic();
                      await Future.delayed(const Duration(seconds: 5));
                      node.scSwReset();
                    }
                  },
                  leading: const Icon(Icons.highlight_remove_rounded),
                  child: Text("Centronic löschen".i18n)
                ),
            
                if(!node.isSensor && !node.isVC421) const UICSpacer(),
            
                if(!node.isSensor) UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.error,
                  onPressed: () async {
                    final answer = await confirm(context, "CentronicPLUS Funkzuordnung löschen".i18n);
                    if(answer == true) {
                      scaffold.hideSecondaryBody();
                      node.scFactoryResetCentronicPlus();
                      await centronicPlus.restartReadAllNodes();
                    }
                  },
                  leading: const Icon(Icons.highlight_remove_rounded),
                  child: Text("CentronicPLUS löschen".i18n)
                ),
            
                if(!node.isSensor) const UICSpacer(),
            
                UICElevatedButton(
                  shrink: false,
                  style: UICColorScheme.error,
                  onPressed: () async {
                    final answer = await confirm(context, "Alle Funkzuordnungen löschen".i18n);
                    if(answer == true) {
                      scaffold.hideSecondaryBody();
                      try {
                        node.scFactoryResetAll();
                      } catch(e) {
                        dev.log("ERROR: $e");
                      }
                      await centronicPlus.restartReadAllNodes();
                    }
                  },
                  leading: const Icon(Icons.highlight_remove_rounded),
                  child: Text("Alle Funkzuordnungen löschen".i18n)
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
