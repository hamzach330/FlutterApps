// library cp_module;
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:cc_eleven_protocol/const.dart';
import 'package:cc_eleven_protocol/models.dart';
import 'package:cc_eleven_protocol/store/store.dart';

/// Common
import 'package:modules_common/modules_common.dart';
import 'package:mod_update_file/module.dart';

import 'package:cc_eleven_protocol/cc_eleven.dart';

/// We also depend on other modules
import 'package:mod_cen_plus/module.dart';

/// pages
part 'home.dart';
part 'clocks.dart';
part 'sun_protection.dart';
part 'group.dart';
part 'settings.dart';

/// alerts
part 'alerts/select_devices.dart';
part 'alerts/slider_alert.dart';

/// widgets
part 'widgets/drawer.dart';
part 'widgets/footer.dart';
part 'widgets/sidebar.dart';
part 'widgets/clock.dart';
part 'widgets/clock_tile.dart';
part 'widgets/group_list.dart';
part 'widgets/group_tile.dart';


class CCElevenModule extends UICModule {
  final GlobalKey<NavigatorState> primaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpPrimaryBodyKey');

  final GlobalKey<NavigatorState> secondaryBodyKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpSecondaryBodyKey');

  final GlobalKey<NavigatorState> drawerKey =
      GlobalKey<NavigatorState>(debugLabel: '_cpDrawerKey');

  final List<DiscoveryConfig> discoveryConfigurations = [
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

    // MTDiscoveryConfiguration<LEEndpoint>(
    //   blePrimaryService: "585dee07-ba10-278b-ba4c-4554ba70b216",
    //   bleTX: "585dee07-ba11-278b-ba4c-4554ba70b216",
    //   bleRX: "585dee07-ba12-278b-ba4c-4554ba70b216",

    //   bleSecondaryService: "585dee07-ba00-278b-ba4c-4554ba70b216",
    //   bleSecondaryTX: "585dee07-ba01-278b-ba4c-4554ba70b216",
    //   bleSecondaryRX: "585dee07-ba02-278b-ba4c-4554ba70b216",

    //   protocol: "CCEleven",
    //   bleTxWithResponse: false,
    //   bleAdvertisementInterval: 1000
    // ),

    // FIXME: Windows is unsupported right now, as secondaryService isn't implemented
    // MTDiscoveryConfiguration<LEWinEndpoint>(
    //   blePrimaryService: "585dee07-ba10-278b-ba4c-4554ba70b216",
    //   bleTX: "585dee07-ba11-278b-ba4c-4554ba70b216",
    //   bleRX: "585dee07-ba12-278b-ba4c-4554ba70b216",

    //   bleSecondaryService: "585dee07-ba00-278b-ba4c-4554ba70b216",
    //   bleSecondaryTX: "585dee07-ba01-278b-ba4c-4554ba70b216",
    //   bleSecondaryRX: "585dee07-ba02-278b-ba4c-4554ba70b216",
      
    //   protocol: "CCEleven",
    //   bleTxWithResponse: true,
    //   bleAdvertisementInterval: 15000
    // ),
  ];

  CentronicPlus? centronicPlus;
  CCEleven? ccEleven;

  dispose () {
    navigatorState?.currentContext?.go("/");
  }

  init (MTEndpoint endpoint) async {
    final messenger = UICMessenger.of(navigatorState!.currentContext!);
    final barrier = await messenger.createBarrier(
      title: "Verbindung wird hergestellt".i18n,
      child: Container(),
    );
    try {
      navigatorState!.currentContext!.read<MTInterface>().stopScan();
      ccEleven = CCEleven();
      
      centronicPlus = CentronicPlus(
        dbPutNode: ccEleven?.store.putNode,
        dbGetNode: ccEleven?.store.getNode,
        dbGetNodes: ccEleven?.store.getAllNodes,
        dbDeleteNode: ccEleven?.store.deleteNode,
        dbDeleteAllNodes: ccEleven?.store.removeAllNodes,
      ); 

      await ccEleven?.store.initializeTables(ccEleven!, endpoint.id!);
      await endpoint.openWith(ccEleven!);
      await ccEleven?.store.validateCache();
      
      centronicPlus?.nodes = await ccEleven?.store.getAllNodes(centronicPlus!) ?? [];
      ccEleven?.groups = await ccEleven?.store.getAllGroups() ?? [];

      if((endpoint is LEEndpoint) && endpoint.secondaryEndpoint != null) {
        await endpoint.secondaryEndpoint!.openWith(centronicPlus!);
        await centronicPlus?.initEndpoint(readMesh: false);
      } else if (endpoint is LEWinEndpoint && endpoint.secondaryEndpoint != null) {
        await endpoint.secondaryEndpoint!.openWith(centronicPlus!);
        await centronicPlus?.initEndpoint(readMesh: false);
      }

      CCElevenHome.go(navigatorState!.currentContext!);

      endpoint.onClose = dispose;
      barrier?.remove();
    } on MTPairingException catch (_) {
      barrier?.remove();
      final platform = Theme.of(navigatorState!.currentContext!).platform;
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Column(
          children: [
            Text("Bitte löschen Sie die Pairing-Informationen im System-Dialog und versuchen Sie es erneut.".i18n),
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
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Fehler".i18n,
        child: Text("Es konnte keine Verbindung hergestellt werden".i18n),
      ));
    }
  }

  Future<void> quit (BuildContext context) async {
    final messenger = UICMessenger.of(context);
    final navigator = GoRouter.of(context);
    final result = await messenger.alert(UICSimpleQuestionAlert(
      title: "Verbindung trennen".i18n,
      child: Text("Möchten Sie die Verbindung trennen?".i18n),
    ));
  
    if(result == true) {
      if(ccEleven?.endpoint.connected == true) {
        ccEleven?.closeEndpoint();
      } else {
        navigator.go("/");
      }
      return;
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
        Provider.value(value: ccEleven!.store),
        StreamProvider<CentronicPlus>.value(
          value: centronicPlus!.updateStream.stream,
          initialData: centronicPlus!,
          updateShouldNotify: (_, __) => true,
        ),
        StreamProvider<CCEleven>.value(
          value: ccEleven!.updateStream.stream,
          initialData: ccEleven!,
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
              builder: (context) {
                return children[1];
              }
            ),
            drawer: children[2],

            footer: CCElevenFooter(),
            sidebar: CCElevenSidebar(),
          ),
        );
      },
    );
  }

  @override
  Provider<CCElevenModule> get provider => Provider<CCElevenModule>.value(value: this);

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
          initialLocation: CCElevenHome.path,
          preload: true,
          routes: [
            CCElevenHome.route,
            CCSettings.route,
            CCElevenSunProtection.route,
            CCElevenClocks.route,
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
            CCElevenClock.route,
            CPNodeAdminView.route,
            CPNodeUserView.route,
            CPNodeSunProtectionView.route,
            CPNodeOperationModeView.route,
            CPRemoteChannelSelector.route,
            CPNodePresetsView.route,
            CPNodeEvoConfigurationView.route,
            CPNodeEndPositionsView.route,
            NodeAdvancedSettingsView.route,
            CCElevenGroupView.route,
            OtaView.route,
          ],
        ),
        StatefulShellBranch(
          navigatorKey: drawerKey,
          initialLocation: CPDrawer.path,
          preload: true,
          routes: [
            CCElevenDrawer.route,
          ],
        ),
      ],
    ),
  ];
}
