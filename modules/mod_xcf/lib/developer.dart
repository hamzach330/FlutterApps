part of 'module.dart';

class XCFDeveloperView extends StatefulWidget {
  static const path = '${XCFHome.path}/developer';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFDeveloperView(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFDeveloperView({
    super.key
  });

  @override
  State<XCFDeveloperView> createState() => _XCFDeveloperViewState();
}

class _XCFDeveloperViewState extends State<XCFDeveloperView> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  final positionTextController = TextEditingController(text: "60");

  Timer? timer;
  XCFSetupState? setupState;

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    setupState = await xcf.readSetup();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return UICPage(
      slivers: [
        UICConstrainedSliverList(
          maxWidth: 600,
          children: [
            UICGridTile(
              elevation: 0,
              borderColor: Colors.transparent,
              bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
              // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                title: Text("Inbetriebnahme Informationen".i18n, style: subtitle),
              ),


              body: Column(
                spacing: theme.defaultWhiteSpace,
                children: [
                  Text("posZUbekannt ${setupState?.posZuBekannt}"),
                  Text("posRWABekannt ${setupState?.posRWABekannt}"),
                  Text("posTeilAuf ${setupState?.posTeilAuf}"),
                  Text("posAufBekannt ${setupState?.posAufBekannt}"),
                  Text("drehsinnBekannt ${setupState?.drehsinnBekannt}"),
                  Text("drehsinn ${setupState?.drehsinn}"),

                  UICElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      timer = null;
                      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                        xcf.sendCommand(XCFCommand.DI_FE1);
                      });
                    },
                    child: Text("TEL_SET_INPUT FE 1".i18n),
                  ),

                  UICElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      timer = null;
                      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                        xcf.sendCommand(XCFCommand.DI_FE2);
                      });
                    },
                    child: Text("TEL_SET_INPUT FE 2".i18n),
                  ),

                  UICElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      timer = null;
                      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                        xcf.sendCommand(XCFCommand.DI_SE1);
                      });
                    },
                    child: Text("TEL_SET_INPUT SE 1".i18n),
                  ),

                  UICElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      timer = null;
                    },
                    child: Text("Stop".i18n),
                  ),

                  UICElevatedButton(
                    onPressed: () {
                      xcf.sendCommand(XCFCommand.DI_PROG);
                    },
                    child: Text("TEL_SET_INPUT DI_PROG".i18n),
                  ),
                ]
              )
            ),

            const XCFParametersConfiguration(),
          ],
        )
      ]
    );
  }
}
