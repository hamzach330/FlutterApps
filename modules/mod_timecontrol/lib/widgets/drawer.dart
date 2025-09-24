part of '../module.dart';

class TCDrawer extends StatefulWidget {
  static const path = '${TCHome.path}/drawer';

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
      child: const TCDrawer(),
    )
  );

  static go(BuildContext context) {
    context.go(path);
  }

  const TCDrawer({
    super.key,
  });

  @override
  State<TCDrawer> createState() => _TCDrawerState();
}

class _TCDrawerState extends State<TCDrawer> {
  late final Timecontrol timecontrol;

  @override
  initState() {
    super.initState();
    timecontrol = Provider.of<Timecontrol>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return UICDrawer(
      leading: Column(
        children: [
          const UICSpacer(2),
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/timecontrol/timecontrol.png"),
                fit: BoxFit.contain,
              )
            ),
          ),
          const UICSpacer(2),
          const Divider(),
          const UICSpacer(),
          const TCAutomatic(),
          const UICSpacer(),
        ],
      ),
      
      trailing: UICDrawerTile(
        leading: const Icon(Icons.logout),
        title: Text('Verbindung trennen'.i18n, style: const TextStyle()),
        onPressed: (_) async {
          context.read<TCModule>().quit(context);
        },
      ),

      children: [
        UICDrawerTile(
          leading: const Icon(Icons.settings_remote),
          title: Text('Bedienung'.i18n, style: const TextStyle()),
          onPressed: (_) => TCHome.go(context),
        ),
        
        const UICSpacer(),
        
        UICDrawerTile(
          leading: const Icon(Icons.access_time_rounded),
          title: Text('Schaltzeiten'.i18n, style: const TextStyle()),
          onPressed: (_) => TimecontrolClocksView.go(context),
        ),
        
        const UICSpacer(),
        
        UICDrawerTile(
          leading: const Icon(Icons.wb_sunny_outlined),
          title: Text('Sonnenschutz'.i18n, style: const TextStyle()),
          onPressed: (_) => TimecontrolSunProtectionView.go(context),
        ),
        
        const UICSpacer(),
        
        UICDrawerTile(
          leading: const Icon(Icons.settings_rounded),
          title: Text('System'.i18n, style: const TextStyle()),
          onPressed: (_) => TimecontrolSystemView.go(context),
        ),
        
        const UICSpacer(),

        UICDrawerTile(
          onPressed: (_) => TimecontrolInformationView.go(context),
          leading: const Icon(Icons.info_rounded),
          title: Text('Informationen'.i18n, style: const TextStyle()),
        ),
      ],
    );
  }
}
