part of '../module.dart';

class EvoSpecial extends StatefulWidget {
  const EvoSpecial({super.key});

  @override
  State<EvoSpecial> createState() => _EvoSpecialState();
}

class _EvoSpecialState extends State<EvoSpecial> {
  final GlobalKey<TooltipState> tipFlyScreen = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> tipAntiFreeze = GlobalKey<TooltipState>();
  late final evo = Provider.of<Evo>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<Evo>(
      builder: (context, evo, _) => Column(
        children: [
          const UICSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                key: tipAntiFreeze,
                triggerMode: TooltipTriggerMode.manual,
                showDuration: const Duration(seconds: 0),
                message: "Aktivierbar, wenn die obere Endlage auf Anschlag eingestellt ist. Der Behang fährt nicht gegen den oberen Anschlag, sondern bleibt kurz vorher stehen um ein Anfrieren (bspw. bei Verwendung einer Winkelendleiste) zu verhindern.".i18n,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.info, color: theme.colorScheme.secondary),
                ),
              ),
              Expanded(child: Text("Festfrierschutz".i18n)),
              
              UICSwitch(
                value: evo.freezeProtectEnabled,
                onChanged: () async{
                  await evo.setFreezeProtection(!evo.freezeProtectEnabled);
                  await evo.wink();
                }
              ),
            ],
          ),
          
          const UICSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                triggerMode: TooltipTriggerMode.manual,
                showDuration: const Duration(seconds: 0),
                message: "Der Antrieb reagiert im oberen Bereich des Verfahrwegs deutlich früher auf Hindernisse. So wird die Beschädigung von Insektenschutztüren verhindert, die unmittelbar unter der oberen Endlage montiert sind.".i18n,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.info, color: theme.colorScheme.secondary),
                ),
              ),
                    
              Expanded(child: Text("Fliegengitterschutz".i18n)),
              
              UICSwitch(
                value: evo.flyScreenEnabled,
                onChanged: () async {
                  await evo.setFlyScreen(!evo.flyScreenEnabled);
                  await evo.wink();
                }
              ),
            ],
          ),
        ],
      )
    );
  }
}