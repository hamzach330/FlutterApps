part of 'module.dart';

class CCElevenClocks extends StatefulWidget {
  static const path = '${CCElevenHome.path}/clocks';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: CCElevenClocks(),
    ),
  );

  static go (BuildContext context) {
    UICScaffold.of(context).hideSecondaryBody();
    context.go(path);
  }

  const CCElevenClocks({
    super.key,
  });

  @override
  State<CCElevenClocks> createState() => _CCElevenClocksState();
}

class _CCElevenClocksState extends State<CCElevenClocks> {
  late final CCEleven cc = context.read<CCEleven>();
  late final store = cc.store;
  StreamSubscription<CCEleven>? subscription;
  
  bool loading = true;
  List<CCElevenTimer> timers = [];

  @override
  void initState() {
    super.initState();
    unawaited(asynInit());
  }

  Future<void> asynInit() async {
    // await cc.removeAllTimers();

    // subscription = cc.updateStream.stream.listen((event) async {
    //   await readNames();
    //   setState(() {});
    // });

    timers = await cc.readActiveTimers(cacheFirst: false);
    // await readNames();
    loading = false;

    setState(() {});
  }

  // Future<void> readNames () async {
  //   for (final timer in timers) {
  //     timer.name = (await store?.getStringById([...List.filled(7, 0x00), timer.appId]))?.content ?? "Unbenannte Uhr".i18n;
  //   }
  // }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      loading: loading,
      slivers: [
        UICPinnedHeader(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UICTitle("Uhren".i18n),
            ],
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              elevation: 2,
            ),
            onPressed: () {
              final nextFreeIndex = cc.getNextFreeIndex(timers);
              CCElevenClock.go(context, nextFreeIndex, CCElevenTimer(
                nextTime: DateTime.now(),
                type: CCElevenTimerState(
                  active: true,
                  type: CCElevenTimerType.fixedTime
                ),
                bitdays: 0x00,
                index: nextFreeIndex,
                offset: 0,
                minute: DateTime.now().minute,
                hour: DateTime.now().hour,
                command: CCElevenTimerCommand(
                  cDevices: 0,
                  cpDevices: List.filled(8, 0),
                  cmd: CPAvailableCommands.up,
                  lift: 0,
                  tilt: 0,
                  evoPro: null
                ),
                appId: nextFreeIndex,
                name: "Unbenannte Uhr".i18n,
              ));
            },
            child: Row(
              children: [
                Text("Neu".i18n),
                UICSpacer(),
                Icon(Icons.more_time_rounded, size: 16, color: theme.colorScheme.onPrimaryContainer,),
              ],
            ),
          ),
        ),

        Consumer<CentronicPlus>(
          builder: (context, cp, _) {
            return SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 200,
                crossAxisSpacing: theme.defaultWhiteSpace,
                mainAxisSpacing: theme.defaultWhiteSpace,
                childAspectRatio: 3/4,
              ),
              itemCount: timers.length,
              itemBuilder: (BuildContext context, int index) => Consumer<CentronicPlus>(
                builder: (context, centronicPlus, _) => CCElevenClockTile(
                  clock: timers[index],
                  index: index,
                )
              )
            );
          }
        ),
      ],
    );
  }
}
