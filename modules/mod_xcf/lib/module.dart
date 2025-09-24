library xcf_module;

import 'dart:developer' as dev;
import 'package:modules_common/modules_common.dart';
import 'package:xcf_protocol/xcf.dart';
export 'package:xcf_protocol/xcf.dart';

// screens
part 'screens/wizard/step_final_positions.dart';
part 'screens/wizard/step_mid_position.dart';
part 'screens/wizard/step_project_info.dart';
part 'screens/wizard/step_summary.dart';
part 'screens/wizard/wizard_screen.dart';
part 'screens/wizard/setup_screen.dart';

// widgets
part 'widgets/wizard_stepper.dart';
part 'widgets/parameters_config.dart';
part 'widgets/drawer.dart';
part 'widgets/wizard_navigation.dart';

// pages
part 'start.dart';
part 'tx_units.dart';
part 'home.dart';
part 'maintenance.dart';
part 'manufacturer.dart';
part 'monitoring.dart';
part 'alerts/report.dart';
part 'screens/company_form.dart';
part 'developer.dart';

// state
part 'controllers/xcf_setup_controller.dart';

class XCFModule extends UICModule {
  final GlobalKey<NavigatorState> _evoPrimaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_evoPrimaryBodyKey');

  final GlobalKey<NavigatorState> _evoDrawerKey =
      GlobalKey<NavigatorState>(debugLabel: '_evoDrawerKey');

  final List<DiscoveryConfig> discoveryConfigurations = [
    USBAndroidDiscoveryConfig(
      protocolName: "XCF",
      usbManufacturerName: "Becker-Antriebe GmbH",
      usbProductId: 259,
      usbVendorId: 9784,
    ),
    USBDiscoveryConfig(
      protocolName: "XCF",
      usbManufacturerName : "Becker-Antriebe GmbH",
      usbProductId: 259,
      usbVendorId: 9784,
    ),
  ];

  XCFProtocol? xcf;

  dispose () {
    navigatorState?.currentContext?.go("/");
  }

  init (MTEndpoint endpoint) async {
    final messenger = UICMessenger.of(navigatorState!.currentContext!);
    final barrier = await messenger.createBarrier(title: "Verbindung wird hergestellt".i18n, child: Container());
    try {
      xcf = XCFProtocol();

      await endpoint.openWith(xcf!);
      endpoint.onClose = dispose;
      
      await Future.delayed(const Duration(milliseconds: 250));

      barrier?.remove();

      if (/* if setup incomplete - fetch necessary state before barrier removal */ false) {
        XCFSetupWizard.go(navigatorState!.currentContext!);
      } else {
        XCFStart.go(navigatorState!.currentContext!);
      }

    } catch(e) {
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Text("Es konnte keine Verbindung hergestellt werden".i18n),
      ));
    }
  }

  @override
  Provider<XCFModule> get provider => Provider<XCFModule>.value(value: this);

  @override
  get routes => [
    StatefulShellRoute(
      builder: (context, state, navShell) => MultiProvider(
        providers: [
          StreamProvider<XCFProtocol>.value(
            value: xcf!.updateStream.stream,
            initialData: xcf!,
            updateShouldNotify: (_, __) => true,
          ),
        ],
        builder: (context, _) => navShell,
      ),
      navigatorContainerBuilder: (context, navShell, children) {
        return UICScaffold(
          navigationShell: navShell,
          primaryBody: children[0],
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: [
            XCFStart.route,
          ],
        ),
      ],
    ),

    StatefulShellRoute(
      builder: (context, state, navShell) => MultiProvider(
        providers: [
          StreamProvider<XCFProtocol>.value(
            value: xcf!.updateStream.stream,
            initialData: xcf!,
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
          initialLocation: XCFSetupWizard.path,
          navigatorKey: _evoPrimaryBodyKey,
          routes: [
            XCFSetupWizard.route,
            XCFMaintenanceView.route,
            XCFMonitorView.route,
            XCFManufacturerView.route,
            XCFDeveloperView.route,
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _evoDrawerKey,
          initialLocation: XCFDrawer.path,
          preload: true,
          routes: [
            XCFDrawer.route,
          ],
        ),
      ],
    ),
  ];
}
