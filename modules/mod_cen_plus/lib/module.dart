// library cp_module;
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter/foundation.dart';
/// Common
import 'package:modules_common/modules_common.dart';
import 'package:modules_common/path.dart' as path;
import 'package:cc_eleven_protocol/cc_eleven.dart';

import 'dart:io' show Directory, File;
import 'dart:convert';

/// We also depend on other modules
import 'package:mod_evo/module.dart';
import 'package:mod_update_file/module.dart';
import 'package:centronic_plus_protocol/centronic_plus.dart';
export 'package:centronic_plus_protocol/centronic_plus.dart';

// Over the Air Update
part 'ota/ota_info_extension.dart';
part 'ota/view.dart';
part 'ota/alert.dart';
part 'ota/exceptions.dart';
part 'ota/ota_all_alert.dart';
part 'ota/progress_provider.dart';
part 'ota/unsupported.dart';

// Lists scan results etc
part 'home.dart';

// Storage management
part 'store/store.dart';
part 'store/nodes.dart';

// Pages
part 'remote_view.dart';
part 'node_advanced_settings_view.dart';
part 'node_endposition_view.dart';
part 'node_presets_view.dart';
part 'node_operation_mode_view.dart';
part 'node_remote_channel_selector.dart';
part 'channel_selector_base.dart';
part 'node_sun_protection_view.dart';
part 'node_admin_view.dart';
part 'node_user_view.dart';
part 'node_evo_configuration.dart';

// Module level providers
part 'providers/selection.dart';
part 'providers/settings_expander.dart';
part 'providers/node.dart';

// Widgets
part 'widgets/node_status_message.dart';
part 'widgets/node_sensor_values.dart';
part 'widgets/remote_color_wheel.dart';
part 'widgets/app_bar.dart';
part 'widgets/drawer.dart';
part 'widgets/footer.dart';
part 'widgets/sidebar.dart';
part 'widgets/node_info.dart';
part 'widgets/foreign_nodes.dart';
part 'widgets/own_nodes.dart';
part 'widgets/node_admin_tile.dart';
part 'widgets/node_user_tile.dart';
part 'widgets/foreign_node_tile.dart';
part 'widgets/node_name.dart';
part 'widgets/log_view.dart';
part 'widgets/menu_more.dart';
part 'widgets/session_info.dart';

// Custom alerts
part 'alerts/remote_setup_runner.dart';
part 'alerts/multicast_control.dart';
part 'alerts/remote_assign.dart';
part 'alerts/stick_update.dart';
part 'alerts/stick_reset.dart';
part 'alerts/quit.dart';
part 'alerts/net_confirm_join.dart';
part 'alerts/multicast_net_delete.dart';
part 'alerts/teachin.dart';
part 'alerts/info.dart';

enum CPViewMode {
  admin,
  user,
}

class CPModule extends UICModule {
  CPModule({this.viewMode = CPViewMode.user});

  final CPViewMode viewMode;

  final GlobalKey<NavigatorState> primaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpPrimaryBodyKey');

  final GlobalKey<NavigatorState> secondaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpSecondaryBodyKey');

  final GlobalKey<NavigatorState> drawerKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpDrawerKey');

  final List<DiscoveryConfig> discoveryConfigurations = [
    USBAndroidDiscoveryConfig(
      protocolName: "CentronicPLUS",
      usbManufacturerName: "Becker-Antriebe GmbH",
      usbProductId: 48,
      usbVendorId: 9784,
    ),
    USBDiscoveryConfig(
      protocolName: "CentronicPLUS",
      usbManufacturerName : "Becker-Antriebe GmbH",
      usbProductId: 48,
      usbVendorId: 9784,
    ),
    USBAndroidDiscoveryConfig(
      protocolName: "CentronicPLUS",
      usbManufacturerName: "Becker-Antriebe GmbH",
      usbProductId: 50,
      usbVendorId: 9784,
    ),
    USBDiscoveryConfig(
      protocolName: "CentronicPLUS",
      usbManufacturerName : "Becker-Antriebe GmbH",
      usbProductId: 50,
      usbVendorId: 9784,
    ),
    BLEDiscoveryConfig(
      protocolName: "CCEleven",
      primaryServiceId: "585dee07-ba10-278b-ba4c-4554ba70b216",
      vendorId: 2065,
      productId: [0x43, 0x43, 0x31, 0x31],
      services: [
        BLEDiscoveryService(
          protocolName: "CCEleven",
          serviceId: "585dee07-ba10-278b-ba4c-4554ba70b216",
          tx: "585dee07-ba11-278b-ba4c-4554ba70b216",
          rx: "585dee07-ba12-278b-ba4c-4554ba70b216",
        ),
        BLEDiscoveryService(
          protocolName: "CentronicPlus",
          serviceId: "585dee07-ba00-278b-ba4c-4554ba70b216",
          tx: "585dee07-ba01-278b-ba4c-4554ba70b216",
          rx: "585dee07-ba02-278b-ba4c-4554ba70b216",
        ),
      ]
    ),
  ];

  CentronicPlus? centronicPlus;
  CCEleven? ccEleven;
  CPStore cpStore = CPSQLStore();
  

  dispose () {
    navigatorState!.currentContext!.go("/");
    // final messenger = UICMessenger.of(navigatorState!.currentContext!);
    // messenger.clear();
  }

  init (MTEndpoint endpoint) async {
    if(endpoint is BLEDiscoveryConfig) {

    }

    final messenger = UICMessenger.of(navigatorState!.currentContext!);
    final barrier = await messenger.createBarrier(title: "Verbindung wird hergestellt".i18n, child: Container());
    try {
      centronicPlus = CentronicPlus(
        dbPutNode: cpStore.putNode,
        dbGetNode: cpStore.getNode,
        dbGetNodes: cpStore.getAllNodes,
        dbDeleteNode: cpStore.deleteNode,
        dbDeleteAllNodes: cpStore.removeAllNodes,
      );

      if(endpoint is LEEndpoint && endpoint.protocolName == "CCEleven") {
        await endpoint.openWith(CCEleven());
        await endpoint.secondaryEndpoint!.openWith(centronicPlus!);
        await centronicPlus!.initEndpoint();
      } else if (endpoint is LEWinEndpoint && endpoint.protocolName == "CCEleven") {
        await endpoint.openWith(CCEleven());
        await endpoint.secondaryEndpoint!.openWith(centronicPlus!);
        await centronicPlus!.initEndpoint();
      } else {
        await endpoint.openWith(centronicPlus!);
        await centronicPlus!.initEndpoint();
      }
      
      endpoint.onClose = dispose;

      CPHome.go(navigatorState!.currentContext!);
    } on MTPairingException catch (_) {
      final platform = Theme.of(navigatorState!.currentContext!).platform;
      messenger.alert(UICSimpleAlert(
        title: "Veraltete Pairing Informationen".i18n,
        child: Column(
          children: [
            Text("Bitte löschen Sie die Pairing-Informationen im System-Dialog. Versetzen Sie die CC11 anschließend erneut in den Pairing-Modus.".i18n),
            if(platform == TargetPlatform.android || platform == TargetPlatform.iOS) const UICSpacer(),
            if(platform == TargetPlatform.android || platform == TargetPlatform.iOS)TextButton(
              onPressed: () {
                if(platform == TargetPlatform.android) {
                  OpenSettingsPlusAndroid().bluetooth();
                } else if(platform == TargetPlatform.iOS) {
                  OpenSettingsPlusIOS().bluetooth();
                }
              },
              child: Text("Bluetooth-Einstellungen öffnen".i18n),
            ),
          ]
        ),
      ));
    
    } catch(e) {
      endpoint.close();
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Text("Es konnte keine Verbindung hergestellt werden".i18n),
      ));
    }
    barrier?.remove();
  }

  Future<void> quit (BuildContext context) async {
    if(centronicPlus?.endpoint.connected == false) {
      return;
    }
    final messenger = UICMessenger.of(context);
    // centronicPlus?.setAutoResponse(false);

    int? answer;
    if(centronicPlus?.endpoint is MTWebSocketEndpoint) {
      answer = (await messenger.alert(UICSimpleConfirmationAlert(
        title: "Achtung!",
        child: Column(
          children: [
            Text("Soll die Einrichtung wirklich beendet werden?".i18n),
            const UICSpacer(),
            Text("Ihre CentralControl wird neu gestartet.".i18n),
          ],
        ),
      ))) == true ? 0 : null;
    } else {
      answer = await messenger.alert(AlertQuit());
    }

    if(answer != null && answer != 2) {
      if(answer == 1) {
        centronicPlus?.stickReset();
        await Future.delayed(const Duration(seconds: 1));
      }
      centronicPlus?.closeEndpoint();
    }
  }

  CentronicPlusNode? _node;
  Widget navigatorContainerBuilder (BuildContext context, StatefulNavigationShell navShell, List<Widget> children) {
    final nodeId = GoRouterState.of(context).pathParameters['id'];
    if(nodeId != null) {
      _node = centronicPlus?.nodes.firstWhereOrNull((element) => element.mac == nodeId) ?? _node;
    }
    return MultiProvider(
      providers: [
        Provider.value(value: cpStore),
        StreamProvider<CentronicPlus>.value(
          value: centronicPlus!.updateStream.stream,
          initialData: centronicPlus!,
          updateShouldNotify: (_, __) => true,
        ),
        ChangeNotifierProvider<CPExpandSettings>(create: (context) => CPExpandSettings()),
      ],
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if(GoRouterState.of(context).uri.path == CPHome.path) {
              try {
                await quit(context);
              } catch(e) {
                dev.log("Error while quitting", error: e);
              }
            }
          },
          child: UICScaffold(
            navigationShell: navShell,
            primaryBody: children[0],
            secondaryBody: PossiblyEmptyMultiProvider(
              providers: [
                if (_node != null) StreamProvider<CentronicPlusNode>.value(
                  key: ValueKey(_node!.mac),
                  value: _node!.updateStream.stream,
                  initialData: _node!,
                  updateShouldNotify: (_, __) => true,
                ),
              ],
              builder: (context) => children[1],
            ),
            drawer: children[2],
            sidebar: CPSidebar(),
            footer: CPFooter(),
          ),
        );
      }
    );
  }

  @override
  Provider<CPModule> get provider => Provider<CPModule>.value(value: this);

  @override
  List<RouteBase> get routes => [
    StatefulShellRoute(
      builder: (context, state, navShell) {
        return navShell;
      },
      navigatorContainerBuilder: navigatorContainerBuilder,
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: primaryBodyKey,
          initialLocation: CPHome.path,
          preload: true,
          routes: [
            CPHome.route,
          ],
        ),
        StatefulShellBranch(
          navigatorKey: secondaryBodyKey,
          preload: true,
          initialLocation: CPNodeAdminView.basePath,
          routes: [
            GoRoute( /// Initial route can't contain parameters
              path: CPNodeAdminView.basePath,
              builder: (context, state) {
                return Container();
              }
            ),
            CPNodeAdminView.route,
            CPNodeUserView.route,
            CPNodeSunProtectionView.route,
            CPNodeOperationModeView.route,
            CPNodePresetsView.route,
            CPNodeEvoConfigurationView.route,
            CPNodeEndPositionsView.route,
            NodeAdvancedSettingsView.route,
            OtaView.route,
            CPRemoteChannelSelector.route,
            CPNodeSessionInfo.route
          ],
        ),
        StatefulShellBranch(
          navigatorKey: drawerKey,
          initialLocation: CPDrawer.path,
          preload: true,
          routes: [
            CPDrawer.route,
          ],
        ),
      ],
    )
  ];
}
