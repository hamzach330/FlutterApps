part of 'module.dart';

class EvoSpecialFunctionsView extends StatelessWidget {
  static const path = '${EvoHome.path}/special_functions';

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
      child: const EvoSpecialFunctionsView(),
    )
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const EvoSpecialFunctionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Evo>(
      builder: (context, evo, _) => UICPage(
        //elevation: 0,
        //menu: true,
        //title: "Sonderfunktionen".i18n,
        slivers: [
              //Todo FIXME : Empty Header
              UICPinnedHeader(leading: UICTitle("Sonderfunktionen".i18n)),
              UICConstrainedSliverList(
                maxWidth: 400,
                children: [UICSpacer(5), EvoSpecial()],
              ),
            ] // const [ EvoProfiles(), EvoSpeed() ],
      )
    );
  }
}
