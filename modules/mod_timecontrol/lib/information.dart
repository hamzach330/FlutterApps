part of 'module.dart';

class TimecontrolInformationView extends StatefulWidget {
  static const path = '${TCHome.path}/information';

  static final route = GoRoute(
    path: path,
    pageBuilder:(context, state) => CustomTransitionPage(
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: TimecontrolInformationView(),
    ),
  );

  static go (BuildContext context) {
    context.push(path);
  }

  const TimecontrolInformationView({super.key});

  @override
  State<TimecontrolInformationView> createState() => _TimecontrolInformationViewState();
}

class _TimecontrolInformationViewState extends State<TimecontrolInformationView> {
  _TimecontrolInformationViewState();
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  late final messenger = UICMessenger.of(context);
  
  bool loading = true;
  bool isStored = false;
  
  Version? version;
  String? setupDate;
  int? cycles;
  int? operationTime;

  bool nameError = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit () async {
    loading = true;
    version = await timecontrol.getVersion();
    timecontrol.operationMode = await timecontrol.getOperationMode() ?? TCOperationModeParam();

    final setupTime = await timecontrol.getSetupDate();
    isStored = setupTime.$1;
    setupDate = DateFormat("dd.MM.y - HH:mm").format(setupTime.$2 ?? DateTime.now());

    final tcCycles = await timecontrol.getCycles();
    if(tcCycles != null) {
      cycles = ((tcCycles[1] << 8) | tcCycles[0]);
    }

    final tcOperationTime = await timecontrol.getOperationTime();
    if(tcOperationTime != null) {
      operationTime = ((tcOperationTime[1] << 8) | tcOperationTime[0]);
    }

    loading = false;
    setState(() { });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      //title: "Informationen".i18n,
      //elevation: 0,
      //menu: true,
      loading: loading,
      slivers: [

        // TODO FIXME: empty pinned Header
        UICPinnedHeader(

        ),
        UICConstrainedSliverList(
          maxWidth: 640,
          children: [
            Column(
              children: [

                const UICSpacer(2),

                UICGridTile(
                  bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                  borderColor: Colors.transparent,
                  title: UICGridTileTitle(
                    title: Text("Informationen".i18n),
                  ),
                  body: Column(
                    children: [
                              
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Version".i18n),
                            Text(version?.toString() ?? "-")
                          ],
                        ),
                      ),
                              
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Erstinbetriebnahme".i18n),
                            if(!isStored) Text("Unbekannt".i18n) else
                            Text(setupDate ?? "-")
                          ],
                        ),
                      ),
                              
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("Relais Zyklen".i18n)),
                            Text("${cycles ?? "-"}")
                          ],
                        ),
                      ),
                              
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("Fahrzeit gesamt".i18n)),
                            Text("${operationTime ?? "-"}")
                          ],
                        ),
                      ),
                              
                    ],
                  ),
                ),
              ]
            ),
          ]
        ),
      ],
    );
  }
}
