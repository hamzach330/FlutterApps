part of 'module.dart';

class TimecontrolClocksView extends StatefulWidget {
  static const path = '${TCHome.path}/clocks';

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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => TCClockUnsaved(),
          ),
        ],
        builder: (context, _) => const TimecontrolClocksView(),
      ),
    ),
  );

  static go (BuildContext context) {
    context.push(path);
  }

  const TimecontrolClocksView({super.key});

  @override
  State<TimecontrolClocksView> createState() => _TimecontrolClocksViewState();
}

class _TimecontrolClocksViewState extends State<TimecontrolClocksView> {
  _TimecontrolClocksViewState();

  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  late final unsaved = Provider.of<TCClockUnsaved>(context, listen: false);
  late final messenger = UICMessenger.of(context);

  final TextEditingController astroOffset = TextEditingController(text: "0");
  TCOperationModeType type = TCOperationModeType.Shutter;
  TCOperationModeParam? operationMode;
  List<TCClockParam> clocks = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> save() async {
    bool overlaps = clocks.any((clock) => clock.overlaps);

    if (overlaps) {
      messenger.alert(UICSimpleOkAlert(
        title: "Überschneidende Schaltzeiten".i18n,
        child:
            Text("Es existiert bereits eine Uhr mit dieser Schaltzeit!".i18n),
      ));
      return;
    }

    final clocksWithDays =
        clocks.where((clock) => clock.days.contains(true)).toList();

    if (clocksWithDays.length != clocks.length) {
      final answer = await messenger.alert(UICSimpleProceedAlert(
        title: "Schaltzeit ohne Tage".i18n,
        child: Text(
            "Schaltzeiten ohne konfigurierte Tage werden entfernt.\nWollen Sie dennoch fortfahren?"
                .i18n),
      ));
      if (answer != true) return;
    }

    final barrier = await messenger.createBarrier(title: "Speichern".i18n, child: Container());

    setState(() => saving = true);

    clocks.clear();
    clocks.addAll(clocksWithDays);

    await timecontrol.setTimeProg(clocks);
    setState(() => saving = false);
    unsaved.changes = false;
    barrier?.remove();
  }

  Future<void> asyncInit() async {
    operationMode = await timecontrol.getOperationMode();
    type = await timecontrol.getType() ?? TCOperationModeType.Shutter;
    clocks = await timecontrol.getTimeProg(/*force: true*/);
    loading = false;
    unsaved.changes = false;

    if (mounted) {
      setState(() {});
    }
  }

  preset(TCPresets preset) async {
    clocks = await timecontrol.preset(mode: type, preset: preset);
    setState(() {});

    save();
  }

  toggleClockMode(TCClockParam clock, int index) {
    for (int i = 0; i < clock.clockType.length; i++) {
      clock.clockType[i] = false;
    }

    clock.clockType[index] = true;

    if (clock.blockTimeActive) {
      if (clock.clockType[1]) {
        clock.hour = 20;
        clock.minute = 0;
      } else {
        clock.hour = 7;
        clock.minute = 0;
      }
    } else {
      clock.hour = DateTime.now().hour;
      clock.minute = DateTime.now().minute;
    }
    markChanged();
  }

  // void checkClocks () {
  //   for(final clock in clocks) {
  //     for(final other in clocks) {
  //       clock.detectTimespecOverlap(other);
  //     }
  //   }
  // }

  Future<void> markChanged() async {
    for (final clock in clocks) {
      clock.overlaps = false;
    }

    for (final clock in clocks) {
      clock.isUniqueTimeSpec(clocks);
    }

    unsaved.changes = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final xAxisCount = max(1, (constraints.maxWidth ~/ 450));
      return Consumer<TCClockUnsaved>(builder: (context, unsaved, _) {
        for (final clock in clocks) {
          clock.isUniqueTimeSpec(clocks);
        }
        return UICPage(
          loading: loading,
          // menu: true,
          // floatingAction: unsaved.changes && !saving ? UICGridTileAction(
          //   size: 32,
          //   style: UICColorScheme.success,
          //   onPressed: saving ? null : save,
          //   child: saving
          //       ? UICProgressIndicator.large()
          //       : const Icon(Icons.save_rounded),
          // ): null,
          // title: "Schaltzeiten".i18n,
          // elevation: 0,
          slivers: [
            UICPinnedHeader(
              leading: UICTitle("Schaltzeiten".i18n),
            ),
            UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                TCClockPresetsView(clocks: clocks, type: type, preset: preset)
              ],
            ),

            //  if(overlaps) UICConstrainedSliverList(
            //   maxWidth: 400,
            //   children: [
            //     UICGridTile(
            //       borderColor: Theme.of(context).colorScheme.errorVariant.primary,
            //       title: UICGridTileTitle(
            //         title: Text("Überschneidende Schaltzeiten".i18n),
            //         backgroundColor: Colors.transparent,
            //         foregroundColor: Theme.of(context).colorScheme.errorVariant.primary,
            //       ),
            //       bodyPadding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
            //       body: Text("Es existiert bereits eine Uhr mit dieser Schaltzeit.".i18n)
            //     ),
            //     if(overlaps) const UICSpacer(2),
            //   ],
            // ),

            SliverUICDynamicHeightGridView(
              builder: (context, index) {
                final clock = clocks[clocks.length - index - 1];
                return ClockView(
                  clock: clock,
                  title:
                      "Schaltzeit %s".i18n.fill([""]),
                  type: type,
                  onDelete: () async {
                    final answer =
                        await messenger.alert(UICSimpleQuestionAlert(
                      title: "Schaltzeit löschen".i18n,
                      child: Text(
                          "Soll die Schaltzeit wirklich gelöscht werden?"
                              .i18n),
                    ));
                    if (answer == true) {
                      clocks.remove(clock);
                      markChanged();
                    }
                  },
                  toggleDay: (int day) {
                    final days = clock.days;
                    days[day] = !days[day];
                    clock.days = days;
                    markChanged();
                  },
                  toggleAction: (int action) async {
                    if (action == 0) {
                      clock.moveTo = 0;
                      clock.action = TCClockAction.move;
                    } else if (action == 1) {
                      clock.moveTo = 100;
                      clock.action = TCClockAction.move;
                    } else if (action == 2) {
                      final value = await UICMessenger.of(context)
                          .alert(TimecontrolSliderAlert(
                        position: clock.moveTo.toDouble(),
                        slat: type != TCOperationModeType.Venetian
                            ? null
                            : clock.moveSlatTo.toDouble(),
                      ));

                      if (value == null) return;

                      clock.moveTo = (value.$1 ?? 25.0).toInt();
                      clock.moveSlatTo = (value.$2 ?? 0.0).toInt();
                      clock.action = TCClockAction.move;
                    } else {
                      clock.action = TCClockAction
                          .values[action - 1]; // Skip TCClockAction.none
                    }
                    markChanged();
                  },
                  toggleClockMode: toggleClockMode,
                  onToggleBlockTime: () {
                    if (!clock.blockTimeActive) {
                      if (clock.clockType[1]) {
                        clock.hour = 20;
                        clock.minute = 0;
                      } else {
                        clock.hour = 7;
                        clock.minute = 0;
                      }
                    } else {
                      clock.hour = 0;
                      clock.minute = 0;
                    }
                    markChanged();
                  },
                  getTime: () async {
                    if ((clock.isAstroControlled) &&
                        clock.hour == 0 &&
                        clock.minute == 0) {
                      return;
                    }
                    final time = await messenger.selectTime(DateTime.now());
                    if (time != null) {
                      clock.hour = time.hour;
                      clock.minute = time.minute;
                    }
                    markChanged();
                  },
                  setAstroOffset: (astroOffset) =>
                      setAstroOffset(clock, astroOffset),
                  amTimeDisplay: operationMode?.amTimeDisplay == true,
                );
              },
              itemCount: clocks.length,
              crossAxisCount: xAxisCount,
            ),

            UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                if (clocks.isNotEmpty) const UICSpacer(3),
                if (clocks.isNotEmpty)
                  Center(
                    child: UICElevatedButton(
                      shrink: true,
                      style: UICColorScheme.error,
                      onPressed: () async {
                        final answer = await messenger.alert(
                          UICSimpleQuestionAlert(
                            title: "Alle Schaltzeiten löschen".i18n,
                            child: Text("Sollen wirklich alle Schaltzeiten gelöscht werden?".i18n,),
                          ),
                        );

                        if (answer != true) return;

                        final barrier = await messenger.createBarrier(
                          title: "Schaltzeiten werden gelöscht".i18n,
                          child: Container(),
                        );

                        timecontrol.clearTimeProg().then((value) {
                          barrier?.remove();
                          clocks.clear();
                          unsaved.changes = false;
                        });
                      },
                      leading: const Icon(Icons.alarm_off_rounded),
                      child: Text("Alle Schaltzeiten löschen".i18n),
                    ),
                  ),
              ],
            ),
          ],
        );
      });
    });
  }

  void setAstroOffset(TCClockParam clock, int astroOffset) {
    // astroOffset.text = astroOffset.toString();
    clock.astroOffset = astroOffset;
    markChanged();
  }
}

bool _changes = false;

class TCClockUnsaved extends ChangeNotifier {
  bool get changes => _changes;

  set changes(bool newVal) {
    _changes = newVal;
    notifyListeners();
  }
}

Future<dynamic> modalBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = false,
  Color backgroundColor = Colors.transparent,
  double elevation = 0,
  bool useRootNavigator = true,
  double blurRadius = 10,
  double borderRadius = 20,
}) async {
  await showModalBottomSheet(
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: elevation,
    useRootNavigator: useRootNavigator,
    context: context,
    builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.zero,
        // EdgeInsets.fromWindowPadding(ui.window.viewPadding, ui.window.devicePixelRatio),
        child: ClipRect(
          child: Container(color: backgroundColor, child: builder(ctx)),
        )),
  );
  return;
}
