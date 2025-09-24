part of 'module.dart';

class EvoProfilesView extends StatelessWidget {
  static const path = '${EvoHome.path}/profiles';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) =>const NoTransitionPage(
      child: EvoProfilesView(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const EvoProfilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<Evo>(
          builder: (context, evo, _) => UICPage(
            //elevation: 0,
            //menu: true,
            //title: "Fahrprofil".i18n,
            slivers:[
              //Todo FIXME : Empty Header
              UICPinnedHeader(leading : UICTitle("Fahrprofil".i18n)),
              UICConstrainedSliverList(
                maxWidth: 640,
                children: [
                  UICSpacer(5),
                  EvoProfiles(),
                  EvoSpeed()
                ],
              ),
            ] // const [ EvoProfiles(), EvoSpeed() ],
          )
        );
      }
    );
  }
}
