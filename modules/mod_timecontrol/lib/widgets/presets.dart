part of '../module.dart';

class TCClockPresetsView extends StatelessWidget {
  final List<TCClockParam> clocks;
  final TCOperationModeType type;
  final Function (TCPresets preset) preset;

  const TCClockPresetsView({
    super.key,
    required this.clocks,
    required this.type,
    required this.preset,
  });



  @override
  Widget build(BuildContext context) {
    return Consumer<TCClockUnsaved>(
      builder: (context, unsaved, _) {
        return Column(
          children: [
            const UICSpacer(2),
            Center(
              child: UICElevatedButton(
                style: UICColorScheme.variant,
                onPressed: () async {
                  clocks.add(TCClockParam()
                    ..days = List.filled(7, true)
                    ..hour = DateTime.now().hour
                    ..minute = DateTime.now().minute);
                  unsaved.changes = true;
                },
                leading: const Icon(Icons.add_alarm_rounded),
                child: Text("Neue Schaltzeit anlegen".i18n)
              ),
            ),
        
            if(clocks.isEmpty) const UICSpacer(2),
        
            if(clocks.isEmpty) Text("Es wurden noch keine Schaltzeiten angelegt. Konfigurieren Sie Ihre Schaltzeit individuell, oder verwenden Sie eine Vorlage".i18n, textAlign: TextAlign.center),
            
            const UICSpacer(2),
        
            if(clocks.isEmpty && type == TCOperationModeType.Awning) Column(
              children: [
                Center(
                  child: TextButton(
                    onPressed: () async {
                      preset(TCPresets.awningShade);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(BeckerIcons.weather_sun),
                        const UICSpacer(),
                        Text("Beschattungsautomatik".i18n)
                      ],
                    )
                  ),
                ),
        
                const UICSpacer(),
        
                Center(
                  child: TextButton(
                    onPressed: () async {
                      preset(TCPresets.awningPermanent);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(BeckerIcons.weather_dark_cloud),
                        const UICSpacer(),
                        Text("Dauerbeschattung".i18n)
                      ],
                    )
                  ),
                ),
              ],
            ),
        
            if(clocks.isEmpty && (type == TCOperationModeType.Shutter || type == TCOperationModeType.Venetian)) Column(
              children: [
                Center(
                  child: TextButton(
                    onPressed: () async {
                      preset(TCPresets.shutterLiving);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.living_rounded),
                        const UICSpacer(),
                        Text("Wohnraum".i18n)
                      ],
                    )
                  ),
                ),
        
                const UICSpacer(),
        
                Center(
                  child: TextButton(
                    onPressed: () async {
                      preset(TCPresets.shutterSleeping);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bed),
                        const UICSpacer(),
                        Text("Schlafraum".i18n)
                      ],
                    )
                  ),
                ),
        
                const UICSpacer(),
        
                Center(
                  child: TextButton(
                    onPressed: () async {
                      preset(TCPresets.shutterAstro);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sunny),
                        const UICSpacer(),
                        Text("Astrofunktion".i18n)
                      ],
                    )
                  ),
                ),
              ],
            ),
          ]
        );
      }
    );
  }
}