part of '../module.dart';

class MulticastControlAlert extends UICAlert<void> {
  static open(BuildContext context) {
    UICMessenger.of(context).alert(MulticastControlAlert(
      centronicPlus: Provider.of<CentronicPlus>(context, listen: false),
      extendedSettings: Provider.of<CPExpandSettings>(context, listen: false).expand
    ));
  }

  final CentronicPlus centronicPlus;
  final bool extendedSettings;
  
  MulticastControlAlert({
    super.key,
    required this.centronicPlus,
    required this.extendedSettings
  });
  
  @override
  get title => "Globale Befehle".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 460;

  @override
  get backdrop => true;

  @override
  get dismissable => true;

  @override
  get closeAction => pop;
  
  @override
  Widget build(BuildContext context) {
    return _MulticastPopover(centronicPlus: centronicPlus, extendedSettings: extendedSettings);
  }
}
class _MulticastPopover extends StatefulWidget {
  final CentronicPlus centronicPlus;
  final bool extendedSettings;

  const _MulticastPopover({
    required this.centronicPlus,
    required this.extendedSettings
  });

  @override
  State<_MulticastPopover> createState() => _MulticastControlAlertState();
}

class _MulticastControlAlertState extends State<_MulticastPopover> {
  final mac = "0000000000000000";
  final confirmationTextController = TextEditingController();
  String? confirmationString;
  

  double position = 0;

  Future<bool?> multicastConfirmTeachinDisable(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleProceedAlert(
      title: "Achtung!".i18n,
      child: Text("Durch das Aktivieren der Sicherheitsfunktion wird das Herstellen der Lernbereitschaft nach einem Power-On dauerhaft deaktiviert! Wenn kein Zugriff mehr auf dieses Netz besteht (kein Handsender oder USB-Stick mehr vorhanden), ist eine Änderung des Netzes nicht mehr möglich. Eine Rücksetzung kann ausschließlich über einen Werksreset erfolgen - bei Antrieben erfordert dies ein Universal-Einstellset sowie Zugang zum Anschlusspunkt!".i18n)
    ));
  }

  Future<bool?> multicastConfirm(BuildContext context, String title) async {
    return await UICMessenger.of(context).alert(MulticastNetDeleteAlert());
  }

  Future<bool?> confirmLock(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
      title: "Achtung!".i18n,
      child: Text("Sollen wirklich alle Antriebe der Installation gegen Bedienung gesperrt werden?".i18n),
    ));
  }

  Future<bool?> confirmDeleteSensorAssignment(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
      title: "Achtung!".i18n,
      child: Text("Sollen wirklich alle Sensorzuordnungen gelöscht werden?".i18n),
    ));
  }

  Future<bool?> confirmDeleteEndposition(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
      title: "Achtung!".i18n,
      child: Text("Sollen wirklich alle Endlagen gelöscht werden?".i18n),
    ));
  }

  Future<bool?> confirmUnlock(BuildContext context) async {
    return await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
      title: "Achtung!".i18n,
      child: Text("Sollen wirklich alle Antriebe der Installation entsperrt werden?".i18n),
    ));
  }

  void lockUnlock({
    required bool up,
    required bool down,
  }) {
    widget.centronicPlus.multicast.lockUnlock(
      up: up,
      down: down,
    );
  }

  @override
  Widget build (BuildContext context) {
    final theme = Theme.of(context);
    confirmationString = "Ja".i18n;

    return UICConstrainedColumn(
      maxWidth: 400,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: theme.defaultWhiteSpace,
              children: [
                UICBigSlider(
                  value: position,
                  onChangeEnd: (v) {
                    position = v;
                    widget.centronicPlus.multicast.sendPositionCommand(v);
                  },
                  onChanged: (v) { },
                ),
                const Icon(Icons.swap_vert_rounded, size: 32),
              ],
            ),

            Column(
              spacing: theme.defaultWhiteSpace,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Opacity(opacity: 1, child: Text("0%")),
                UICBigMove(
                  onUp: () {
                    widget.centronicPlus.multicast.sendUpCommand();
                  },
                  onStop: () {
                    widget.centronicPlus.multicast.sendStopCommand();
                  },
                  onDown: () {
                    widget.centronicPlus.multicast.sendDownCommand();
                  },
                ),
                const Icon(Icons.height_rounded, size: 32),
              ],
            ),

            Column(
              spacing: theme.defaultWhiteSpace,
              children: [
                UICBigSlider(
                  width: 50,
                  value: 0,
                  onChangeEnd: (v) {
                    widget.centronicPlus.multicast.sendSlatPositionCommand(v);
                  },
                  onChanged: (v) {},
                ),
                const Icon(Icons.line_weight_rounded, size: 32),
              ],
            )
          ]
        ),

        const UICSpacer(),
        const Divider(),
        const UICSpacer(),

        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.movePreset1();
          },
          leading: const Icon(BeckerIcons.one),
          child: Text("Lüftungsposition (ZP1) anfahren".i18n)
        ),

        const UICSpacer(),
        
        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.movePreset2();
          },
          leading: const Icon(BeckerIcons.two),
          child: Text("Beschattungsposition (ZP2) anfahren".i18n)
        ),

        const UICSpacer(),
        const Divider(),
        const UICSpacer(),

        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.setEnableSunProtection(enable: true);
          },
          leading: const Icon(BeckerIcons.weather_sun),
          child: Text("Sonnenschutzautomatik aktivieren".i18n)
        ),

        const UICSpacer(),

        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.setEnableSunProtection(enable: false);
          },
          leading: const Icon(BeckerIcons.weather_sun),
          child: Text("Sonnenschutzautomatik deaktivieren".i18n)
        ),

        const UICSpacer(),
        const Divider(),
        const UICSpacer(),

        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.setEnableMemoryFunction(enable: true);
          },
          leading: const Icon(BeckerIcons.clock),
          child: Text("Memo-Funktion aktivieren".i18n)
        ),

        const UICSpacer(),
        
        UICElevatedButton(
          shrink: false,
          onPressed: () {
            widget.centronicPlus.multicast.setEnableMemoryFunction(enable: false);
          },
          leading: const Icon(BeckerIcons.clock),
          child: Text("Memo-Funktion deaktivieren".i18n)
        ),

        const UICSpacer(),
        const Divider(),
        const UICSpacer(),

        UICElevatedButton(
          shrink: false,
          onPressed: () async {
            final answer = await UICMessenger.of(context).alert(UICSimpleProceedAlert(
              title: "Geräte neu starten".i18n,
              child: Text("Alle Geräte werden neu gestartet. Es kann einen Moment dauernd, bis alle Funktionen wieder verfügbar sind.".i18n)
            ));
        
            if(answer == true) {
              widget.centronicPlus.multicast.restartAllDevices();
            }
          },
          leading: const Icon(Icons.refresh),
          child: Text("Alle Geräte neu starten".i18n)
        ),

        const UICSpacer(3),
    
        UICButtonTitle(
          title: "Antriebssperre".i18n
        ),
        
        const UICSpacer(),
        
        UICElevatedButton(
          shrink: false,
          style: UICColorScheme.success,
          onPressed: () async {
            lockUnlock(up: false, down: false);
          },
          leading: const Icon(Icons.lock_open_outlined),
          child: Text("Sperre aufheben".i18n)
        ),
    
        const UICSpacer(3),
            
        UICButtonTitle(
          style: UICColorScheme.error,
          title: "Funkzuordnung löschen".i18n
        ),
    
        const UICSpacer(),
    
        Center(
          child: UICElevatedButton(
            shrink: false,
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await multicastConfirm(context, "Centronic Funkzuordnung löschen".i18n);
              if(answer == true) {
                widget.centronicPlus.multicast.scFactoryResetCentronic();
              }
            },
            leading: const Icon(Icons.dnd_forwardslash_sharp),
            child: Text("Centronic löschen".i18n)
          ),
        ),
    
        const UICSpacer(),
        
        Center(
          child: UICElevatedButton(
            shrink: false,
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await multicastConfirm(context, "CentronicPLUS Funkzuordnung löschen".i18n);
              if(answer == true) {
                widget.centronicPlus.multicast.scFactoryResetCentronicPlus();
                widget.centronicPlus.stickReset();
              }
            },
            leading: const Icon(Icons.dnd_forwardslash_sharp),
            child: Text("CentronicPLUS löschen".i18n)
          ),
        ),
        
        const UICSpacer(),
    
        Center(
          child: UICElevatedButton(
            shrink: false,
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await multicastConfirm(context, "Alle Funkzuordnungen löschen".i18n);
              if(answer == true) {
                widget.centronicPlus.multicast.scFactoryResetAll();
                await widget.centronicPlus.dbDeleteAllNodes?.call(widget.centronicPlus.pan);
                widget.centronicPlus.stickReset();
              }
            },
            leading: ImageIcon(
              const AssetImage("assets/images/biohazard.png"),
              color: theme.colorScheme.errorVariant.onPrimaryContainer,
            ),
            child: Text("Alle Funkzuordnungen löschen".i18n)
          ),
        ),

        const UICSpacer(3),
        
        UICButtonTitle(
          title: "Erweitert".i18n
        ),

        const UICSpacer(),

        Center(
          child: UICElevatedButton(
            shrink: false, 
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await confirmDeleteEndposition(context);
              if(answer == true) {
                widget.centronicPlus.multicast.deleteEndposition();
              }
            },
            leading: const Icon(Icons.warning_amber_rounded),
            child: Text("Alle Endlagen löschen".i18n)
          ),
        ),

        const UICSpacer(),
    
        Center(
          child: UICElevatedButton(
            shrink: false, 
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await confirmLock(context);
              if(answer == true) {
                widget.centronicPlus.multicast.lockUnlock(up: true, down: true);
              }
            },
            leading: const Icon(Icons.warning_amber_rounded),
            child: Text("Alle Antriebe sperren".i18n)
          ),
        ),

        const UICSpacer(),
        
        Center(
          child: UICElevatedButton(
            shrink: false,
            style: UICColorScheme.error,
            onPressed: () async {
              final answer = await confirmDeleteSensorAssignment(context);
              if(answer == true) {
                widget.centronicPlus.multicast.removeSensorAssignments();
              }
            },
            leading: const Icon(Icons.warning_amber_rounded),
            child: Text("Alle Sensorzuordnungen löschen".i18n)
          ),
        ),
        //   ]
        // ),
      ],
    );
  } 
}