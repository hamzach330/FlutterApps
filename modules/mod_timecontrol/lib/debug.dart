part of 'module.dart';

class TimecontrolDebugView extends StatefulWidget {
  static const path = '${TCHome.path}/debug';

  static final route = GoRoute(
    path: path,
    pageBuilder:(context, state) => NoTransitionPage(
      child: MultiProvider(
        providers: [
          StreamProvider<Timecontrol>.value(
            value: (state.extra as Timecontrol).updateStream.stream,
            initialData: (state.extra as Timecontrol),
            updateShouldNotify: (_, __) => true,
          ),
        ],
        builder: (context, _) => const TimecontrolDebugView(),
      ),
    ),
  );

  static go (BuildContext context, Timecontrol protocol) {
    context.go(path, extra: protocol);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   TCDrawer.go(context, protocol);
    // });
  }

  const TimecontrolDebugView({super.key});

  @override
  State<TimecontrolDebugView> createState() => _TimecontrolDebugViewState();
}

class _TimecontrolDebugViewState extends State<TimecontrolDebugView> {
  late final Timecontrol timecontrol = Provider.of<Timecontrol>(context, listen: false);
  String? version;

  int? pos1;
  int? pos1slat;

  int? pos2;
  int? pos2slat;

  int pos1Set = 0;
  int pos1slatSet = 0;

  int pos2Set = 0;
  int pos2slatSet = 0;

  @override
  initState () {
    super.initState();
    unawaited(updatePresets());
  }

  Future<void> updatePresets () async {
    final p1 = await timecontrol.readPreset(TCClockChannel.all, 1);
    final p2 = await timecontrol.readPreset(TCClockChannel.all, 2);

    pos1 = p1?[5];
    pos1slat = p1?[6];
    pos2 = p2?[5];
    pos2slat = p2?[6];

    setState(() {});
  }

  Future<void> setPreset1 () async {
    await timecontrol.configurePreset(TCClockChannel.all, 1, 3, pos1Set, pos1slatSet);
    updatePresets();
  }

  Future<void> setPreset2 () async {
    await timecontrol.configurePreset(TCClockChannel.all, 2, 3, pos2Set, pos2slatSet);
    updatePresets();
  }

  @override
  Widget build(BuildContext context) {
    return UICPage(
      //title: "Timecontrol",
      slivers: [
        //todo add the title for this
        UICPinnedHeader(
          
        ),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            FutureBuilder(
              future: () async {
                final version = await timecontrol.getVersion();
                return version;
              }(),
              builder: (context, snapshot) {
                return Text("Uhr-Version: ${snapshot.data}");
              }
            ),

            const UICSpacer(2),

            UICElevatedButton(
              onPressed: () async {
                await timecontrol.setTestMode(2);
                if(context.mounted) {
                  UICMessenger.of(context).alert(UICSimpleAlert(
                    title: "Testmodus".i18n,
                    child: Text("Der Testmodus ist jetzt aktiv.".i18n),
                  ));
                }
              },
              child: Text("Testmodus aktivieren".i18n)
            ),

            const UICSpacer(),

            UICElevatedButton(
              onPressed: () async {
                await updatePresets();
              },
              child: const Text("Aktualisieren"),
            ),
            
            const UICSpacer(),

            Text("Zwischenpos.1 Pos: ${pos1 ?? 0}% / Wendung: ${pos1slat ?? 0}%"),
            Text("Zwischenpos.2 Pos: ${pos2 ?? 0}% / Wendung: ${pos2slat ?? 0}%"),

            const UICSpacer(),

            UICTextFormField(
              label: "Zwischenposition 1",
              initialValue: pos1?.toString() ?? "0",
              onChanged: (value) {
                pos1Set = min(100, max(0, int.tryParse(value) ?? 0));
              },
            ),

            const UICSpacer(),

            UICTextFormField(
              label: "Zwischenposition 1 (Wendung)",
              initialValue: pos1slat?.toString() ?? "0",
              onChanged: (value) {
                pos1slatSet = min(100, max(0, int.tryParse(value) ?? 0));
              },
            ),

            const UICSpacer(),
            
            UICElevatedButton(
              onPressed: () async {
                await setPreset1();
              },
              child: const Text("1 setzen"),
            ),

            const UICSpacer(),
            
            UICElevatedButton(
              onPressed: () async {
                await timecontrol.movePreset1(TCClockChannel.wired);
              },
              child: const Text("1 anfahren"),
            ),

            const UICSpacer(3),

            UICTextFormField(
              label: "Zwischenposition 2",
              initialValue: pos2?.toString() ?? "0",
              onChanged: (value) {
                pos2Set = min(100, max(0, int.tryParse(value) ?? 0));
              },
            ),

            const UICSpacer(),

            UICTextFormField(
              label: "Zwischenposition 2 (Wendung)",
              initialValue: pos2slat?.toString() ?? "0",
              onChanged: (value) {
                pos2slatSet = min(100, max(0, int.tryParse(value) ?? 0));
              },
            ),

            const UICSpacer(),

            UICElevatedButton(
              onPressed: () async {
                await setPreset2();
              },
              child: const Text("2 setzen"),
            ),

            const UICSpacer(),
            
            UICElevatedButton(
              onPressed: () async {
                await timecontrol.movePreset2(TCClockChannel.wired);
              },
              child: const Text("2 anfahren"),
            ),

            const UICSpacer(2),

            const Divider(),

            const UICSpacer(2),

            UICElevatedButton(
              style: UICColorScheme.error,
              onPressed: () async {
                final answer = await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
                  title: 'Verbindung trennen'.i18n,
                  child: Text("Möchten Sie die Bluetooth-Verbindung wirklich trennen?".i18n),
                ));

                if(answer == true) {
                  timecontrol.endpoint.close();
                }
              },
              child: Text("Beenden".i18n)
            ),
          ],
        )
      ],
    );
  }
}
