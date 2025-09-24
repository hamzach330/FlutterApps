library centronic_plus_tool;

import 'package:modules_common/modules_common.dart';

import 'package:mod_cen_plus/module.dart';
import 'package:mod_evo/module.dart';
import 'package:mod_update_file/module.dart';
import 'package:mod_timecontrol/module.dart';
import 'package:mod_xcf/module.dart';

part 'package:centronic_plus_tool/home.dart';
part 'package:centronic_plus_tool/extra_translations.dart';
part 'package:centronic_plus_tool/oss_licenses.dart';
part 'package:centronic_plus_tool/licenses_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await Localization.loadTranslations();
  await WakelockPlus.toggle(enable: true);

  runApp(const CentronicPlusTool());
}

class CentronicPlusTool extends StatelessWidget {
  const CentronicPlusTool({super.key});

  @override
  Widget build(BuildContext context) {
    return UICApp(
      appTitle: "Becker Tool",
      postInit: (context) async {
        Provider.of<OtauInfoProvider>(context, listen: false).init(context);
      },
      modules: [
        CPModule(),
        TCModule(),
        EvoModule(),
        XCFModule(),
      ],
      providers: [
        StreamProvider(
          initialData: MTInterface.instance,
          create: (context) => MTInterface.notifyer.stream,
          updateShouldNotify: (_, __) => true,
        ),
        StreamProvider(
          initialData: MTInterface.scanResults,
          create: (context) => MTInterface.scanResult.stream,
          updateShouldNotify: (_, __) => true,
        ),
        ChangeNotifierProvider(
          create: (context) => UICPackageInfoProvider()
        ),
        ChangeNotifierProvider(
          create: (context) => OtauInfoProvider()
        ),
      ],
      routes: [
        HomeView.route,
        LicensesView.route,
      ],
      contentRoutes: const {},
      endDrawerRoutes: const {},
      supportedLocales: const [
        Locale('de'),
        Locale('cs'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('hu'),
        Locale('it'),
        Locale('nl'),
        Locale('sv'),
        Locale('tr'),
        Locale('pl'),
      ],
    );
  }
}
