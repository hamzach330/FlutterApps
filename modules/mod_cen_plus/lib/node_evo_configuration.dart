part of 'module.dart';

class CPNodeEvoConfigurationView extends StatefulWidget {
  static const pathName = 'evo_configuration';
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
      child: const CPNodeEvoConfigurationView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const CPNodeEvoConfigurationView({super.key});

  @override
  State<CPNodeEvoConfigurationView> createState() => _CPNodeEvoConfigurationViewState();
}

class _CPNodeEvoConfigurationViewState extends State<CPNodeEvoConfigurationView> {
  late final node = Provider.of<CentronicPlusNode>(context, listen: false);
  late final evo = Evo();

  @override
  initState() {
    super.initState();
    CPEvoTunnel(
      write: (message) async => (await node.evoTunnelCommand(message: message)),
    ).openWith(evo);

    asyncInit();
  }

  asyncInit() async {
    await evo.getRampConfiguration();
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
    //final theme = Theme.of(context);
    return UICPage(
      // backgroundColor: theme.colorScheme.surfaceContainerLow,
      // pop: () => context.pop(),
      // close: (context) => close(context),
      // title: "Fahrprofil".i18n,
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(
          leading: UICTitle("Fahrprofil".i18n),
        ),
        const SliverToBoxAdapter(child: CPNodeInfo(readOnly: true,)),
        StreamProvider.value(
          initialData: evo,
          value: evo.updateStream.stream,
          updateShouldNotify: (_, __) => true,
          builder: (context, _) => Consumer<Evo>(
            builder: (context, evo, _) => UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                const EvoProfiles(),
        
                UICTitle("Geschwindigkeiten".i18n),
                
                const EvoSpeed()
              ],
            )
          )
        ),
      ],
    );
  }
}
