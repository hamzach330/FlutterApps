part of 'module.dart';

class TimecontrolPresetsView extends StatefulWidget {
  static const path = '${TCHome.path}/presets';

  static final route = GoRoute(
    path: path,
    pageBuilder:
        (context, state) =>
            const NoTransitionPage(child: TimecontrolPresetsView()),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const TimecontrolPresetsView({super.key});

  @override
  State<TimecontrolPresetsView> createState() => _TimecontrolPresetsViewState();
}

class _TimecontrolPresetsViewState extends State<TimecontrolPresetsView> {
  late final Timecontrol timecontrol = Provider.of<Timecontrol>(
    context,
    listen: false,
  );
  late final messenger = UICMessenger.of(context);

  @override
  Widget build(BuildContext context) {
    return UICPage(
      //title: "Zwischenpositionen".i18n,
      //elevation: 0,
      //menu: true,
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(
          leading: UICTitle("Zwischenpositionen".i18n),
        ),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            const UICSpacer(2),
            Row(
              children: [
                UICBigMove(
                  onUp: () {
                    timecontrol.moveUp(TCClockChannel.wired);
                  },
                  onStop: () {
                    timecontrol.moveStop(TCClockChannel.wired);
                  },
                  onDown: () {
                    timecontrol.moveDown(TCClockChannel.wired);
                  },
                  onRelease: () {
                    timecontrol.moveStop(TCClockChannel.wired);
                    setState(() {});
                  },
                ),

                const UICSpacer(),

                Expanded(
                  child: Column(
                    children: [
                      UICElevatedButton(
                        onPressed: () {
                          timecontrol.movePreset1(TCClockChannel.wired);
                        },
                        leading: Transform.rotate(
                          angle: 3.14159, // Drehen 180°
                          child: const Icon(Icons.download),
                        ),
                        child: Text("Lüftungsposition (ZP1) anfahren".i18n),
                      ),

                      const UICSpacer(),

                      UICElevatedButton(
                        onPressed: () {
                          timecontrol.movePreset2(TCClockChannel.wired);
                        },
                        leading: const Icon(Icons.download),
                        child: Text("Beschattungsposition (ZP2) anfahren".i18n),
                      ),

                      const UICSpacer(3),

                      UICElevatedButton(
                        onPressed: () {
                          timecontrol.configurePreset(
                            TCClockChannel.wired,
                            1,
                            1,
                          );
                        },
                        leading: const Icon(Icons.settings_applications),
                        child: Text("Lüftungsposition (ZP1) setzen".i18n),
                      ),

                      const UICSpacer(),

                      UICElevatedButton(
                        onPressed: () {
                          timecontrol.configurePreset(
                            TCClockChannel.wired,
                            2,
                            1,
                          );
                        },
                        leading: const Icon(Icons.settings_applications),
                        child: Text("Beschattungsposition (ZP2) setzen".i18n),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const UICSpacer(3),

            Center(
              child: UICElevatedButton(
                style: UICColorScheme.error,
                onPressed: () async {
                  final messenger = UICMessenger.of(context);
                  final answer = await messenger.alert(
                    UICSimpleQuestionAlert(
                      title: "Zwischenpositionen löschen".i18n,
                      child: Text(
                        "Möchten Sie wirklich alle Zwischenpositionen löschen?"
                            .i18n,
                      ),
                    ),
                  );

                  if (answer == true) {
                    await timecontrol.configurePreset(
                      TCClockChannel.wired,
                      1,
                      2,
                    );
                    await timecontrol.configurePreset(
                      TCClockChannel.wired,
                      2,
                      2,
                    );
                  }
                },
                leading: const Icon(Icons.remove_circle_outline_rounded),
                child: Text("Zwischenpositionen löschen".i18n),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
