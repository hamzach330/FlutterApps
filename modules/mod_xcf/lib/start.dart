part of 'module.dart';

class XCFStart extends StatefulWidget {
  static const path = '${XCFHome.path}/start';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFStart(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFStart({super.key});

  @override
  State<XCFStart> createState() => _XCFStartState();
}

class _XCFStartState extends State<XCFStart> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);

  @override
  initState() {
    super.initState();
    asyncInit();
  }  

  asyncInit() async {
    await xcf.getBusVersion();
    await xcf.getVersion();
    await xcf.getName();
    await xcf.getLevel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      //pop: () => Navigator.of(context).pop(),
      //title: "XCF-400e",
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(leading: UICTitle("XCF-400e")),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.warnVariant.primaryContainer, size: 64),
            const UICSpacer(),
            Text("Die Inbetriebnahme und Wartung von XCF Steuerungen erfordert einen Hardware-Dongle.\nBitte stecken Sie den Dongle in Ihren PC.".i18n, textAlign: TextAlign.center),
            const UICSpacer(5),
            
            UICElevatedButton(
              onPressed: () => XCFMaintenanceView.go(context),
              child: Text("Wartung".i18n)
            ),
            
            const UICSpacer(),
            
            UICElevatedButton(
              onPressed: () async {
                await UICMessenger.of(context).alert(UICSimpleAlert(
                  title: "Warnung".i18n,
                  child: Text("Während der Inbetriebnahme dürfen keine Anschlüsse an der Steuerung vorgenommen werden.".i18n),
                ));
              },
              child: Text("Inbetriebnahme".i18n)
            ),
            
            const Divider(),

            UICElevatedButton(
              onPressed: () {},
              leading: const Icon(Icons.picture_as_pdf_rounded),
              child: Text("Bedienungsanleitung".i18n)
            ),

            const UICSpacer(5),
            
            UICElevatedButton(
              style: UICColorScheme.error,
              onPressed: () {
                final xcf = Provider.of<XCFProtocol>(context, listen: false);
                xcf.closeEndpoint();
              },
              trailing: const Icon(Icons.exit_to_app_rounded),
              child: Text("Konfiguration beenden".i18n)
            ),
          ]
        )
      ],
    );
  }
}
