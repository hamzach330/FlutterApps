import 'dart:developer' as dev;
import 'package:modules_common/modules_common.dart';
import 'package:evo_protocol/evo.dart';
export 'package:evo_protocol/evo.dart';


part 'home.dart';
part 'widgets/profile.dart';
part 'widgets/speed.dart';
part 'widgets/control.dart';
part 'end_positions.dart';
part 'intermediate_positions.dart';
part 'profiles.dart';
part 'special_functions.dart';
part 'widgets/drawer.dart';
part 'widgets/endposition.dart';
part 'widgets/special.dart';

class EvoModule extends UICModule {
  final GlobalKey<NavigatorState> _evoPrimaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_evoPrimaryBodyKey');

  final GlobalKey<NavigatorState> _evoDrawerKey =
      GlobalKey<NavigatorState>(debugLabel: '_evoDrawerKey');

  Evo? evo;

  final List<DiscoveryConfig> discoveryConfigurations = [
    BLEDiscoveryConfig(
      protocolName: "Evo",
      primaryServiceId: "0783b03e-8535-b5a0-7140-a304d2495cb7",
      vendorId: 2065,
      productId: [45, 45, 16, 23],
      services: [
        BLEDiscoveryService(
          protocolName: "Evo",
          serviceId: "0783b03e-8535-b5a0-7140-a304d2495cb7",
          tx: "0783b03e-8535-b5a0-7140-a304d2495cba",
          rx: "0783b03e-8535-b5a0-7140-a304d2495cb8",
          txWithResponse: false,
        )
      ]
    )

    // MTDiscoveryConfiguration<LEEndpoint>(
    //   blePrimaryService: "0783b03e-8535-b5a0-7140-a304d2495cb7",
    //   bleTX: "0783b03e-8535-b5a0-7140-a304d2495cba",
    //   bleRX: "0783b03e-8535-b5a0-7140-a304d2495cb8",
    //   protocol: "Evo",
    //   bleTxWithResponse: false,
    //   bleAdvertisementInterval: 15000
    // ),

    // MTDiscoveryConfiguration<LEWinEndpoint>(
    //   blePrimaryService: "0783b03e-8535-b5a0-7140-a304d2495cb7",
    //   bleTX: "0783b03e-8535-b5a0-7140-a304d2495cba",
    //   bleRX: "0783b03e-8535-b5a0-7140-a304d2495cb8",
    //   protocol: "Evo",
    //   bleTxWithResponse: false,
    //   bleAdvertisementInterval: 15000,
    //   wantsPairing: true,
    //   pairingMethod: "ProvidePin",
    //   pairingPin: "123456"
    // ),
  ];

  dispose () {
    navigatorState?.currentContext?.go("/");
  }

  init (MTEndpoint endpoint) async {
    final messenger = UICMessenger.of(navigatorState!.currentContext!);
    final barrier = await messenger.createBarrier(title: "Verbindung wird hergestellt".i18n, child: Container());
    try {
      evo = Evo(escape: true);

      await endpoint.openWith(evo!);
      endpoint.onClose = dispose;
      
      await Future.delayed(const Duration(milliseconds: 250));

      barrier?.remove();

      EvoHome.go(navigatorState!.currentContext!);
    } catch(e) {
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Text("Es konnte keine Verbindung hergestellt werden".i18n),
      ));
    }
  }

  @override
  Provider<EvoModule> get provider => Provider<EvoModule>.value(value: this);

  @override
  get routes => [
    StatefulShellRoute(
      builder: (context, state, navShell) => MultiProvider(
        providers: [
          StreamProvider<Evo>.value(
            value: evo!.updateStream.stream,
            initialData: evo!,
            updateShouldNotify: (_, __) => true,
          ),
        ],
        builder: (context, _) => navShell,
      ),
      navigatorContainerBuilder: (context, navShell, children) {
        return UICScaffold(
          navigationShell: navShell,
          primaryBody: children[0],
          drawer: children[1],
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _evoPrimaryBodyKey,
          routes: [
            EvoHome.route,
            EvoProfilesView.route,
            EvoSpecialFunctionsView.route,
            EvoEndPositionsView.route,
            EvoIntermediatePositionsView.route,
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _evoDrawerKey,
          initialLocation: EvoDrawer.path,
          preload: true,
          routes: [
            EvoDrawer.route,
          ],
        ),
      ],
    )
  ];
}