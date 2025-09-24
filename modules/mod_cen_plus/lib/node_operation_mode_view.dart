part of 'module.dart';

class CPNodeOperationModeView extends StatelessWidget {
  static const pathName = 'operation_mode';
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
      child: const CPNodeOperationModeView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const CPNodeOperationModeView({super.key});

  Future<void> setOpMode(Function() modeSwitch, BuildContext context) async {
    final navigator = Navigator.of(context);
    final answer = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: "Achtung!".i18n,
      child: Column(
        children: [
          Text("Die Änderung der Betriebsart hat zur Folge, dass ALLE Einstellungen des Empfängers zurückgesetzt werden! Davon sind alle programmierten Laufzeiten, Zwischenpositionen und Sonnenschutzeinstellungen betroffen. Gegebenenfalls müssen eingelernte Handsender noch einmal aus- und neu eingelernt werden, um die volle Funktionalität sicherzustellen.".i18n),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text("Sind Sie sicher, dass die Betriebsart des Geräts geändert werden soll?".i18n),
          )
        ],
      ),
    ));

    if(answer == true) {
      navigator.pop();
      modeSwitch();
    }
  }

  Future pop (BuildContext context) async {
    context.pop();
  }

  Future close (BuildContext context) async {
    final scaffold = UICScaffold.of(context);
    scaffold.hideSecondaryBody();
  }

  @override
  Widget build(BuildContext context) {
    return UICPage(
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => pop(context),
          ),
          body: UICTitle("Betriebsart".i18n),
        ),
        Consumer<CentronicPlusNode>(
          builder: (context, node, _) {
            return UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                const CPNodeInfo(readOnly: true),

                const UICSpacer(),
        
                if(node.isVC520 || node.isVC470 || node.isVC420 || node.isLC120) UICElevatedButton(
                  style: (node.initiator == CPInitiator.rolloDrive || (node.initiator == CPInitiator.actSwitchDim && node.isLightControl)) ? UICColorScheme.success : null,
                  onPressed: () => setOpMode(node.setVcOperationModeShutter, context),
                  leading: node.isLightControl ? const Icon(BeckerIcons.device_dimmer_1) : const Icon(BeckerIcons.device_shutter),
                  child:    Text(node.isLightControl ? "Schaltaktor".i18n : "Rollladen".i18n),
                ),
        
        
                const UICSpacer(),
                
                if(node.isVC520 || node.isVC470 || node.isVC420 || node.isLC120) UICElevatedButton(
                  style: (node.initiator == CPInitiator.sunDrive || node.initiator == CPInitiator.actImpulseLight) ? UICColorScheme.success : null,
                  onPressed: () => setOpMode(node.setVcOperationModeSunProtection, context),
                  leading: (node.isLightControl || node.isVC520) ? const Icon(BeckerIcons.device_dimmer_1) : const Icon(BeckerIcons.device_awning),
                  child: Text((node.isLightControl || node.isVC520) ? "Schaltaktor (Impuls)".i18n : "Sonnenschutz".i18n),
                ),
        
                const UICSpacer(),
        
                if(node.isVC520 || node.isVC470 || node.isVC420 || node.isLC120) UICElevatedButton(
                  style: (node.initiator == CPInitiator.sunDriveJal || node.initiator == CPInitiator.actWayLight) ? UICColorScheme.success : null,
                  onPressed: () => setOpMode(node.setVcOperationModeVenetian, context),
                  leading: node.isLightControl ? const Icon(BeckerIcons.device_dimmer_1) : const Icon(BeckerIcons.device_venetian),
                  child:    Text(node.isLightControl ? "Treppenlicht".i18n : "Jalousie".i18n),
                ),
        
                const UICSpacer(),
        
                if(node.isVC520 || node.isVC470 || node.isVC420) UICElevatedButton(
                  style: node.initiator == CPInitiator.actSwitchDim ? UICColorScheme.success : null,
                  onPressed: () => setOpMode(node.setVcOperationModeSwitch, context),
                  leading: const Icon(BeckerIcons.device_dimmer_1),
                  child:    Text("Schaltaktor".i18n),
                ),
        
                const UICSpacer(),
        
                if(node.isVC520) UICElevatedButton(
                  onPressed: () => setOpMode(node.setVcOperationModeShutterPulse, context),
                  leading: const Icon(BeckerIcons.device_shutter),
                  child:    Text("Rollladen (Impuls)".i18n),
                ),
        
                const UICSpacer(),
        
                if(node.isVC520) UICElevatedButton(
                  onPressed: () => setOpMode(node.setVcOperationModeSwitchPulse, context),
                  leading: const Icon(BeckerIcons.device_dimmer_1),
                  child: Text("Schaltaktor (Impuls)".i18n),
                ),
                
                const UICSpacer(),
              ],
            );
          }
        ),
      ],
    );
  }
}
