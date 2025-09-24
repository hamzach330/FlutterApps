part of '../module.dart';

class CPNodeStatus extends StatelessWidget {
  const CPNodeStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CentronicPlusNode>(
      builder: (context, node, _) {
        return Column(
          children: [
            if(node.updating) const UICSpacer(),
            if(node.updating) Material(
              color: theme.colorScheme.warnVariant.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UICSpacer(),
                    UICProgressIndicator(
                      size: 24,
                      color: theme.colorScheme.warnVariant.onPrimaryContainer
                    ),
                    const UICSpacer(2),
                    Text("Informationen werden gelesen. Es stehen eventuell nicht alle Funktionen zur Verfügung oder die Bedienung ist eingeschränkt.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                    const SizedBox(height: 20),
                    Text("Bitte haben Sie einen Moment Geduld.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                    const UICSpacer(),
                  ],
                ),
              ),
            ),
        
            if(node.readError || ((node.isRemote && node.isBatteryPowered || node.initiator == CPInitiator.sunDusk) && node.version == null) && !node.loading) const UICSpacer(),
            if(node.readError || ((node.isRemote && node.isBatteryPowered || node.initiator == CPInitiator.sunDusk) && node.version == null) && !node.loading) Material(
              color: theme.colorScheme.warnVariant.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UICSpacer(),

                    Icon(Icons.warning, size: 60, color: theme.colorScheme.warnVariant.onPrimaryContainer),

                    const UICSpacer(),

                    Text("Es konnten nicht alle Informationen gelesen werden.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),

                    const UICSpacer(),

                    if(!node.isRemote && !node.isBatteryPowered) Text("Bitte versuchen Sie es gleich erneut.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),

                    if(!node.isRemote && !node.isBatteryPowered) const UICSpacer(2),
              
                    if(!node.isRemote && !node.isBatteryPowered) Center(
                      child: UICElevatedButton(
                        // style: UICColorScheme.variant,
                        elevation: 10,
                        onPressed: node.updateInfo,
                        leading: const Icon(Icons.refresh),
                        child: Text("Wiederholen".i18n),
                      ),
                    ),

                    if((node.isRemote && node.isBatteryPowered)) Text("Stellen Sie sicher, dass die LED-Anzeige Ihres Handsenders nicht leuchtet. Verlassen Sie gegebenfalls den Einlernbetrieb durch langes Drücken der Einlerntaste. Drücken Sie dann die Stopp Taste Ihrer Fernbedienung erneut.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),

                    if(node.isBatteryPowered && node.isSensor) Text("Drücken Sie die Stopp Taste Ihres Sensors erneut".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                    
                    const UICSpacer(),
                  ],
                ),
              ),
            ),
        
            if(node.statusFlags.obstacleDetected == true) const UICSpacer(),
            if(node.statusFlags.obstacleDetected == true) Material(
              color: theme.colorScheme.errorContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(Icons.download_for_offline_rounded, size: 60,)
                    ),
                    Text("Das Gerät hat ein Hindernis erkannt.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),
        
            if(node.statusFlags.windAlert == true || node.sensorLoss == true) const UICSpacer(),
            if(node.statusFlags.windAlert == true || node.sensorLoss == true) Material(
              color: theme.colorScheme.errorContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: node.sensorLoss == false
                        ? const Icon(BeckerIcons.wind, size: 60)
                        : const Icon(Icons.warning_amber_rounded, size: 60)
                    ),
                    if(node.sensorLoss == true) Text("Sensorverlust!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ) else Text("Windalarm - Gerät gesperrt!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),

            if(node.statusFlags.sunProtectionPosition == true) const UICSpacer(),
            if(node.statusFlags.sunProtectionPosition == true) Material(
              color: theme.colorScheme.successVariant.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(BeckerIcons.weather_sun, size: 60,)
                    ),
                    Text("Beschattung aktiv".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.successVariant.onSurface
                      )
                    ),
                  ],
                ),
              ),
            ),
        
            if(node.statusFlags.rainAlert == true) const UICSpacer(),
            if(node.statusFlags.rainAlert == true) Material(
              color: theme.colorScheme.warnVariant.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(Icons.warning, size: 60,)
                    ),
                    Text("Regen erkannt.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),
        
            if(node.statusFlags.sensorValueOverride == true) const UICSpacer(),
            if(node.statusFlags.sensorValueOverride == true) Material(
              color: theme.colorScheme.warnVariant.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(Icons.warning, size: 60,)
                    ),
                    Text("Schwellwertüberschreitung".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),
        
            if(node.statusFlags.overheated == true) const UICSpacer(),
            if(node.statusFlags.overheated == true && node.isSensor == false) Material(
              color: theme.colorScheme.errorContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(Icons.thermostat_rounded, size: 60,)
                    ),
                    Text("Das Gerät hat ein thermisches Problem erkannt.".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),
        
            if(!node.isRemote && node.statusFlags.locked == true) const UICSpacer(),
            if(!node.isRemote && node.statusFlags.locked == true) Material(
              color: theme.colorScheme.warnVariant.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(node.analogValues?.upLock == true && node.analogValues?.downLock == true) Text("Das Gerät ist in AUF- und AB-Richtung gesperrt!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ) else if(node.analogValues?.downLock == true) Text("Das Gerät ist in AB-Richtung gesperrt!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ) else if(node.analogValues?.upLock == true) Text("Das Gerät ist in AUF-Richtung gesperrt!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ) else if(node.statusFlags.locked == true) Text("Das Gerät ist in AUF- oder AB-Richtung gesperrt!!".i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.warnVariant.onPrimaryContainer
                      )
                    ),
        
                    const UICSpacer(),
        
                    Center(
                      child: UICElevatedButton(
                        onPressed: () async {
                          node.lockUnlock(up: false, down: false);
                        },
                        leading: const Icon(Icons.lock_open_outlined),
                        child: Text("Sperre aufheben".i18n),
                      ),
                    ),
        
                  ],
                ),
              ),
            ),

            if(node.initiator == CPInitiator.sunDusk && node.isBatteryPowered) const UICSpacer(),
            if(node.initiator == CPInitiator.sunDusk && node.isBatteryPowered) Material(
              color: theme.colorScheme.primaryContainer,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Icon(Icons.info_outline_rounded, size: 60,)
                    ),
                    Text("Dieser Sensor sendet ausschließlich Fahrbefehle! Die Konfiguration von Schwellwerten muss direkt am %s erfolgen.".i18n.fill([node.initiator?.name.i18n ?? "Sensor".i18n]),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CPNodeStatusIcon extends StatelessWidget {

  const CPNodeStatusIcon({
    super.key
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CentronicPlusNode>(
      builder: (context, node, _) {
        if(node.name == null) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Es wurden noch nicht alle Empfängerinformationen gelesen.".i18n.fill([node.statusFlags.warningCount]),
            child: const Icon(Icons.error_rounded),
          );
        } else if ((node.statusFlags.warningCount) > 1) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Das Gerät hat %s mehrere Fehler festgestellt".i18n.fill([node.statusFlags.warningCount]),
            child: const Icon(Icons.error_rounded),
          );
        } else if (node.statusFlags.locked == true) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Das Gerät ist in AUF- oder AB-Richtung gesperrt!!".i18n,
            child: const Icon(Icons.lock_rounded),
          );
        } else if (node.statusFlags.windAlert == true && node.sensorLoss == false) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Windalarm - Gerät gesperrt!".i18n,
            child: const Icon(BeckerIcons.wind),
          );
        } else if (node.sensorLoss == true) {
          return UICGridTileAction(
            style: UICColorScheme.error,
            tooltip: "Sensorverlust".i18n,
            child: const Icon(Icons.warning_amber_rounded),
          );
        } else if (node.statusFlags.overheated == true) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Das Gerät hat ein thermisches Problem erkannt.".i18n,
            child: const Icon(Icons.thermostat_rounded),
          );
        } else if (node.statusFlags.rainAlert == true) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Regen erkannt.".i18n,
            child: const Icon(BeckerIcons.weather_x_7),
          );
        } else if (node.statusFlags.sunProtectionPosition == true) {
          return UICGridTileAction(
            style: UICColorScheme.success,
            tooltip: "Beschattung aktiv".i18n,
            child: const Icon(BeckerIcons.weather_sun),
          );
        } else if (node.statusFlags.obstacleDetected == true) {
          return UICGridTileAction(
            style: UICColorScheme.error,
            tooltip: "Das Gerät hat ein Hindernis erkannt.".i18n,
            child: const Icon(Icons.download_for_offline_rounded),
          );
        } else if (node.statusFlags.sensorValueOverride == true) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Schwellwertüberschreitung".i18n,
            child: const Icon(Icons.error_rounded),
          );
        } else if (node.readError) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Es konnten nicht alle Informationen gelesen werden.".i18n,
            child: const Icon(Icons.error_rounded),
          );
        } else if (!node.statusFlags.setupComplete && !node.isCentral && !node.isRemote && !node.isSensor) {
          return UICGridTileAction(
            style: UICColorScheme.error,
            tooltip: "Einrichtung unvollständig".i18n,
            child: const Icon(Icons.expand_rounded),
          );
        } else if(!node.isCentral && !node.isRemote && !node.isSensor) {
          return UICGridTileAction(
            style: UICColorScheme.warn,
            tooltip: "Es ist ein unbekanntes Problem aufgetreten.".i18n,
            child: const Icon(Icons.error_rounded),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
