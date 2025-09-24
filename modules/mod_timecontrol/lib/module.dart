library timecontrol_module;

import 'dart:developer' as dev;

import 'package:timecontrol_protocol/timecontrol.dart';
export 'package:timecontrol_protocol/timecontrol.dart';
import 'package:modules_common/modules_common.dart';

part 'debug.dart';
part 'home.dart';
part 'settings.dart';
part 'clocks.dart';
part 'information.dart';
part 'sun_protection.dart';
part 'operation_mode.dart';
part 'presets.dart';
part 'alerts/setup_runner.dart';
part 'alerts/slider_alert.dart';
part 'widgets/clock.dart';
part 'widgets/presets.dart';
part 'widgets/astro.dart';
part 'widgets/drawer.dart';
part 'widgets/location_ensurer.dart';
part 'widgets/automatic.dart';
part 'models/astro_entry.dart';
part 'models/astro_calc.dart';
part 'widgets/footer.dart';

class TCModule extends UICModule {
  final GlobalKey<NavigatorState> _tcPrimaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_tcPrimaryBodyKey');

  final GlobalKey<NavigatorState> _tcDrawerKey =
      GlobalKey<NavigatorState>(debugLabel: '_tcDrawerKey');

  Timecontrol? timecontrol;

  dispose () {
    timecontrol?.stopPolling();
    navigatorState?.currentContext?.go("/");
  }

  init (MTEndpoint endpoint) async {
    final messenger = UICMessenger.of(navigatorState!.currentContext!);
    final barrier = await messenger.createBarrier(title: "Verbindung wird hergestellt".i18n, child: Container());
    try {
      timecontrol = Timecontrol();

      await endpoint.openWith(timecontrol!);
      endpoint.onClose = dispose;
      
      await Future.delayed(const Duration(milliseconds: 250));
      await timecontrol?.startPolling();

      barrier?.remove();

      TCHome.go(navigatorState!.currentContext!);
    } catch(e) {
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Text("Es konnte keine Verbindung hergestellt werden".i18n),
      ));
    }
  }

  Widget navigatorContainerBuilder (BuildContext context, StatefulNavigationShell navShell, List<Widget> children) {
    return MultiProvider(
      providers: [
        StreamProvider<Timecontrol>.value(
          value: timecontrol!.updateStream.stream,
          initialData: timecontrol!,
          updateShouldNotify: (_, __) => true,
        ),
      ],
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            dev.log("test");
          },
          child: UICScaffold(
            navigationShell: navShell,
            primaryBody: children[0],
            drawer: children[1],
            footer: const TCFooter(),
          ),
        );
      }
    );
  }

  final List<DiscoveryConfig> discoveryConfigurations = [
    BLEDiscoveryConfig(
      protocolName: "Timecontrol72",
      primaryServiceId: "0000abf0-0000-1000-8000-00805f9b34fb",
      vendorId: 2065,
      productId: [0x54, 0x43, 0x37, 0x32],
      services: [
        BLEDiscoveryService(
          protocolName: "Timecontrol72",
          serviceId: "0000abf0-0000-1000-8000-00805f9b34fb",
          tx: "0000abf1-0000-1000-8000-00805f9b34fb",
          rx: "0000abf2-0000-1000-8000-00805f9b34fb",
          txWithResponse: false,
        )
      ]
    )

    // MTDiscoveryConfiguration<LEEndpoint>(
    //   blePrimaryService: "0000abf0-0000-1000-8000-00805f9b34fb",
    //   bleTX: "0000abf1-0000-1000-8000-00805f9b34fb",
    //   bleRX: "0000abf2-0000-1000-8000-00805f9b34fb",
    //   protocol: "Timecontrol72",
    //   bleTxWithResponse: false,
    //   bleAdvertisementInterval: 5000
    // ),

    // MTDiscoveryConfiguration<LEWinEndpoint>(
    //   blePrimaryService: "0000abf0-0000-1000-8000-00805f9b34fb",
    //   bleTX: "0000abf1-0000-1000-8000-00805f9b34fb",
    //   bleRX: "0000abf2-0000-1000-8000-00805f9b34fb",
    //   protocol: "Timecontrol72",
    //   bleTxWithResponse: false,
    //   bleAdvertisementInterval: 5000
    // ),
  ];

  Future<void> quit(BuildContext context) async {
    final answer = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
          title: 'Verbindung trennen'.i18n,
          child: Text("Möchten Sie die Bluetooth-Verbindung wirklich trennen?".i18n),
    ));

    if(answer == true) {
      timecontrol?.stopPolling();
      timecontrol?.endpoint.close();
    }
  }

  @override
  Provider<TCModule> get provider => Provider<TCModule>.value(value: this);
  
  @override
  get routes => [
    TimecontrolDebugView.route,
    StatefulShellRoute(
      builder: (context, state, navShell) => navShell,
      navigatorContainerBuilder: navigatorContainerBuilder,
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _tcPrimaryBodyKey,
          routes: [
            TCHome.route,
            TimecontrolClocksView.route,
            TimecontrolSystemView.route,
            TimecontrolSunProtectionView.route,
            TimecontrolOperationModeView.route,
            TimecontrolPresetsView.route,
            TimecontrolInformationView.route,
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _tcDrawerKey,
          initialLocation: TCDrawer.path,
          preload: true,
          routes: [
            TCDrawer.route,
          ],
        ),
      ],
    )
  ];
}
