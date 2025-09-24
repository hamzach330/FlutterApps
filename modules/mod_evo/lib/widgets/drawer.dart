part of '../module.dart';

class EvoDrawer extends StatefulWidget {
  static const path = '${EvoHome.path}/drawer';

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
      child: const EvoDrawer(),
    )
  );

  static go(BuildContext context, Evo evo) {
    context.go(path, extra: evo);
  }

  const EvoDrawer({
    super.key,
  });

  @override
  State<EvoDrawer> createState() => _EvoDrawerState();
}

class _EvoDrawerState extends State<EvoDrawer> {
  late final evo = Provider.of<Evo>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return UICDrawer(
      leading: Column(
        children: [
          const UICSpacer(2),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 100,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/evo/evolution_small.png"),
                  fit: BoxFit.contain,
                )
              ),
            ),
          ),
          const UICSpacer(2),
          const Divider()
        ],
      ),
      
      trailing: UICDrawerTile(
        leading: const Icon(Icons.exit_to_app_rounded),
        title: Text('Konfiguration beenden'.i18n, style: const TextStyle()),
        onPressed: (_) async {
          final answer = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
            title: 'Konfiguration beenden'.i18n,
            child: Text("Möchten Sie die Konfiguration wirklich beenden?".i18n),
          ));

          if(answer == true) {
            evo.endpoint.close();
          }
        },
      ),

      children: [
        UICDrawerTile(
          leading: const Icon(Icons.settings_remote),
          title: Text('Bedienung'.i18n, style: const TextStyle()),
          onPressed: (_) => EvoHome.go(context),
        ),
        
        // FIXME: Not for EVO Classic
        UICDrawerTile(
          leading: const Icon(Icons.unfold_less_double),
          title: Text('Zwischenpositionen'.i18n, style: const TextStyle()),
          onPressed: (_) => EvoIntermediatePositionsView.go(context),
        ),

        // FIXME: Not for EVO Classic
        UICDrawerTile(
          leading: const Icon(Icons.expand),
          title: Text('Endlagen'.i18n, style: const TextStyle()),
          onPressed: (_) => EvoEndPositionsView.go(context),
        ),
        
        UICDrawerTile(
          leading: const Icon(Icons.speed),
          title: Text('Fahrprofil / Geschwindigkeiten'.i18n, style: const TextStyle()),
          onPressed: (_) => EvoProfilesView.go(context),
        ),

        UICDrawerTile(
          leading: const Icon(Icons.auto_awesome),
          title: Text('Sonderfunktionen'.i18n, style: const TextStyle()),
          onPressed: (_) => EvoSpecialFunctionsView.go(context),
        ),
      ],
    );
  }
}
