part of 'module.dart';

class EvoHome extends StatefulWidget {
  static const path = '/evo';

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
      child: const EvoHome(),
    )
  );

  static go(BuildContext context) {
    context.go(path);
  }

  const EvoHome({super.key});

  @override
  State<EvoHome> createState() => _EvoHomeState();
}

class _EvoHomeState extends State<EvoHome> {
  late final Evo evo = Provider.of<Evo>(context, listen: false);
  
  @override
  initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Evo>(
      builder: (context, evo, _) => UICPage(
        //elevation: 0,
        // menu: true,
        // title: "Bedienung".i18n,
        slivers:[
          //Todo FIXME : Empty Header
          UICPinnedHeader(leading: UICTitle("Bedienung".i18n)),
          UICConstrainedSliverList(
            maxWidth: 640,
            children: [
              UICSpacer(5),
              EvoControl()
            ],
          ),
        ] // const [ EvoProfiles(), EvoSpeed() ],
      )
    );
  }
}
