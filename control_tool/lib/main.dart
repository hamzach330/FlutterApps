library centronic_plus_tool;

import 'package:modules_common/modules_common.dart';
import 'package:mod_cc_eleven/module.dart';
import 'package:mod_timecontrol/module.dart';
import 'package:mod_evo/module.dart';
import 'package:mod_update_file/module.dart';

part 'home.dart';
part 'licenses/licenses_view.dart';
part 'licenses/oss_licenses.dart';
part 'extra_translations.dart';


void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await Localization.loadTranslations();
  await WakelockPlus.toggle(enable: true);

  runApp(CentronicPlusTool());
}


class CentronicPlusTool extends StatelessWidget {
  CentronicPlusTool({super.key});

  final title               = "Be:You";
  late final multiTransport = MTInterface.instance;
  final supportedLocales    = const [
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
  ];
  
  late final providers = [
    StreamProvider(
      initialData: multiTransport,
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
  ];

  @override
  Widget build(BuildContext context) {
    return UICApp(
      postInit: (context) async {
        Provider.of<OtauInfoProvider>(context, listen: false).init(context);
      },
      modules: [
        CCElevenModule(),
        TCModule(),
      ],
      providers: providers,
      routes: [
        HomeView.route,
        LicensesView.route,
      ],
      contentRoutes: const {},
      endDrawerRoutes: const {},
      appTitle: title,
      supportedLocales: supportedLocales,
    );
  }
}
