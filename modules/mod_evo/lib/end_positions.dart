part of 'module.dart';

class EvoEndPositionsView extends StatelessWidget {
  static const path = '${EvoHome.path}/end_positions';

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
      child: const EvoEndPositionsView(),
    )
  );

  static go(BuildContext context) {
    context.push(path);
  }
  
  const EvoEndPositionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Evo>(
      builder: (context, evo, _) => UICPage(
        //elevation: 0,
        //menu: true,
        //title: "Endlagen".i18n,
        slivers:[
          //Todo FIXME : Empty Header
          UICPinnedHeader(leading : UICTitle("Endlagen".i18n)),
          UICConstrainedSliverList(
            maxWidth: 400,
            children: [
              UICSpacer(5),
              EvoEndposition()
            ],
          ),
        ] // const [ EvoProfiles(), EvoSpeed() ],
      )
    );
  }
}
