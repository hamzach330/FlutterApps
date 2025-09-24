part of 'main.dart';

class HomeView extends StatefulWidget {
  static const pathName = "home";
  static const path = '/';

  static final route = GoRoute(
    path: path,
    pageBuilder:(context, state) => const NoTransitionPage(
      child: HomeView(),
    ),
  );

  static go (BuildContext context) {
    context.go(path);
  }

  const HomeView({
    super.key
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{
  late final MTInterface multiTransport;
  late final UICMessengerState messenger;

  late final TCModule tcModule;
  late final CCElevenModule ccElevenModule;

  @override
  void initState() {
    super.initState();
    multiTransport = Provider.of<MTInterface>(context, listen: false);
    messenger = UICMessenger.of(context);

    tcModule = context.read<TCModule>();
    ccElevenModule = context.read<CCElevenModule>();

    asyncInit();
  }

  @override
  void dispose() {
    multiTransport.stopScan();
    super.dispose();
  }

  void asyncInit() async {
    await Future.delayed(const Duration(seconds: 1));
    multiTransport.startScan([
      ...tcModule.discoveryConfigurations,
      ...ccElevenModule.discoveryConfigurations,
    ]);
  }

  Widget itemBuilder(BuildContext context, MTEndpoint endpoint, Animation<double> animation) {
    if(endpoint.protocolName == "Timecontrol72") {
      return UICFatListTile(
        onTap: () => tcModule.init(endpoint),
        animation: animation,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          child: Transform.scale(
            scale: 0.7, // Adjust the scale factor as neededº
            child: const Image(
              image: AssetImage("assets/timecontrol/timecontrol.png"),
            ),
          ),
        ),
        title: endpoint.name ?? "",
        subtitle: "Bluetooth".i18n,
      );
    } else if(endpoint.protocolName == "CCEleven") {
      return UICFatListTile(
        onTap: () => ccElevenModule.init(endpoint),
        animation: animation,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          backgroundImage: const AssetImage("assets/images/ph_cc11.png"),
          radius: 40,
        ),
        title: endpoint.name ?? "Unbenannt".i18n,
        subtitle: "Bluetooth".i18n,
      );
    }
    return UICFatListTile(
      onTap: () => ccElevenModule.init(endpoint),
      animation: animation,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundImage: const AssetImage("assets/images/centronic_plus.png"),
        radius: 40,
      ),
      title: endpoint is LEEndpoint || endpoint is LEWinEndpoint ? "CentronicPLUS Bluetooth" : "CentronicPLUS USB-Stick".i18n,
      subtitle: endpoint is LEEndpoint || endpoint is LEWinEndpoint ? "Bluetooth" : "USB".i18n,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const UICSpacer(),
    
        SafeArea(
          child: Container(
            width: 400,
              
            margin: EdgeInsets.only(
              left: theme.defaultWhiteSpace * 5,
              right: theme.defaultWhiteSpace * 5,
              top: theme.defaultWhiteSpace * 2
            ),
            padding: EdgeInsets.all(theme.defaultWhiteSpace * 5),
            height: 85,
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.center,
                opacity: .75,
                fit: BoxFit.contain,
                image: const AssetImage("assets/images/becker_logo_claim.png"),
                colorFilter: theme.brightness == Brightness.light ? ColorFilter.mode(
                  Colors.black.withAlpha(255),
                  BlendMode.srcATop
                ) : null,
              )
            ),
          ),
        ),
    
        Expanded(
          child: Consumer<List<MTEndpoint>>(
            builder: (context, endpoints, _) {
              return UICFatList<MTEndpoint>(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                title: "Startklar!".i18n,
                subTitle: "Bitte stecken Sie einen Centronic PLUS USB-Stick ein oder bringen Sie ein Bluetooth-fähiges Becker-Antriebe Produkt in Lernbereitschaft".i18n,
                items: endpoints,
                itemBuilder: itemBuilder
              );
            }
          ),
        ),
    
        SafeArea(
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<UICPackageInfoProvider>(
                    builder: (context, packageInfo, _) {
                      return Text("%s".i18n.fill([packageInfo.version?.version ?? ""]));
                    }
                  ),
              
                  const OTAUSync(),
              
                  UICTextButton(
                    shrink: true,
                    text: "Lizenzen".i18n,
                    onPressed: () => LicensesView.go(context),
                  )
                ]
              )
            )
          ),
        )
      ]
    );
  }
}
