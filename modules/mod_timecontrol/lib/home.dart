part of 'module.dart';

class TCHome extends StatefulWidget {
  static const path = '/timecontrol';

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
      child: TCHome(),
    ),
  );

  static go (BuildContext context) {
    context.go(path);
  }

  const TCHome({super.key});

  @override
  State<TCHome> createState() => _TCHomeState();
}

class _TCHomeState extends State<TCHome> {
  late final Timecontrol timecontrol = Provider.of<Timecontrol>(context, listen: false);
  late final messenger = UICMessenger.of(context);

  bool loading = true;
  DateTime? time;
  String? timeString;
  TCOperationModeType? operationType;

  @override
  void initState() {
    super.initState();
    unawaited(asyncInit());
  }

  @override
  void dispose() {
    try {
      // timecontrol.stopPolling();
      // timecontrol.closeEndpoint();
    } catch(e) {
      // Do nothing
    }
    super.dispose();
  }

  Future<void> asyncInit () async {
    operationType = await timecontrol.getType();
    setState(() {
      loading = false;
    });

    await setTime(DateTime.now());

    if(timecontrol.operationMode.setupComplete == false) {
      await runSetup();
    }
  }

  setTime (DateTime newTime) async {
    time = newTime;
    await timecontrol.setDateTime(newTime);
    if(timecontrol.operationMode.amTimeDisplay == true) {
      timeString = DateFormat("dd.MM.y - hh:mm a").format(time!);
    } else {
      timeString = "%s Uhr".i18n.fill([DateFormat("dd.MM.y - HH:mm").format(time!)]);
    }
  }

  readTime () async {
    time = await timecontrol.getDateTime();
    if(time != null) {
      if(timecontrol.operationMode.amTimeDisplay == true) {
        timeString = DateFormat("dd.MM.y - hh:mm a").format(time!);
      } else {
        timeString = "%s Uhr".i18n.fill([DateFormat("dd.MM.y - HH:mm").format(time!)]);
      }
    }
  }

  runSetup([TCSetupData? data]) async {
    final messenger = UICMessenger.of(context);
    final setupData = await messenger.alert(UICSetupRunnerAlert(
      setupData: data ?? TCSetupData(
        version: await timecontrol.getVersion(),
        title: "Einrichtungsassistent".i18n,
        providers: [
          StreamProvider.value(
            initialData: timecontrol,
            value: timecontrol.updateStream.stream,
            updateShouldNotify: (_, __) => true,
          ),
        ],
        step: (route, setupData) {
          switch (route) {
            case TCSetupStep1.path:
              return TCSetupStep1(data: setupData);
            case TCSetupStep2.path:
              return TCSetupStep2(data: setupData);
            case TCSetupStep2One.path:
              return TCSetupStep2One(data: setupData);
            case TCSetupStep3.path:
              return TCSetupStep3(data: setupData);
            case TCSetupStep3One.path:
              return TCSetupStep3One(data: setupData);
            case TCSetupStep3Two.path:
              return TCSetupStep3Two(data: setupData);
            case TCSetupStep4.path:
              return TCSetupStep4(data: setupData);
            case TCSetupStep5.path:
              return TCSetupStep5(data: setupData);
            case TCSetupStep6.path:
              return TCSetupStep6(data: setupData);
            case TCSetupStep7.path:
              return TCSetupStep7(data: setupData);
            case TCSetupStep8.path:
              return TCSetupStep8(data: setupData);
            case TCSetupStep9.path:
              return TCSetupStep9(data: setupData);
            default:
              return TCSetupStep1(data: setupData);
          }
        }
      )
    ));

    if(setupData?.complete != true) {
      await messenger.alert(UICSimpleAlert(
        title: "Einrichtung unvollständig".i18n,
        child: Text("Bitte schließen Sie die Einrichtung vollständig ab.".i18n),
      ));
      
      runSetup(setupData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffold = UICScaffold.of(context);
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return UICPage(
          loading: loading,
          // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          // floatingActionButton: FloatingActionButton.small(
          //   child: Icon(Icons.refresh_rounded),
          //   onPressed: () {}
          // ),
          slivers: [
            UICPinnedHeader(
              leading:
                  scaffold.breakPointLXLXXL
                      ? null
                      : RotatedBox(
                        quarterTurns: 2,
                        child: IconButton(
                          tooltip: "Verbindung trennen".i18n,
                          onPressed: () {
                            context.read<TCModule>().quit(context);
                          },
                          icon: Icon(Icons.exit_to_app_outlined, size: 28),
                        ),
                      ),
              body: UICTitle("Bedienung".i18n),
            ),
            UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                if(timecontrol.operationMode.sensorLoss) Container(
                  margin: EdgeInsets.only(top: theme.defaultWhiteSpace),
                  padding: EdgeInsets.all(theme.defaultWhiteSpace),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.errorVariant.primaryContainer,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("Sensorverlust!".i18n,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.errorVariant.primaryContainer),
                    textAlign: TextAlign.center,
                  )
                ),
              
                if(timecontrol.operationMode.windalert) Container(
                  margin: EdgeInsets.only(top: theme.defaultWhiteSpace),
                  padding: EdgeInsets.all(theme.defaultWhiteSpace),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.errorVariant.primaryContainer,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("Windalarm - Gerät gesperrt!".i18n,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.errorVariant.primaryContainer),
                    textAlign: TextAlign.center,
                  )
                ),
              
                if(timecontrol.operationMode.rainAlert) Container(
                  margin: EdgeInsets.only(top: theme.defaultWhiteSpace),
                  padding: EdgeInsets.all(theme.defaultWhiteSpace),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.warnVariant.primaryContainer,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("Regen erkannt.".i18n,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.warnVariant.primaryContainer),
                    textAlign: TextAlign.center,
                  )
                ),
              
                if(timecontrol.operationMode.winter) const UICSpacer(),
            
                if(timecontrol.operationMode.winter) Material(
                  color: Colors.lightBlue.shade100,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Icon(BeckerIcons.anti_freeze, color: Colors.blue, size: 42),
                        const SizedBox(height: 10,),
                        Text("Die Uhr befindet sich im Wintermodus!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.lightBlue.shade900)),
                        const SizedBox(height: 10,),
                        UICElevatedButton(
                          child: Text("Deaktivieren".i18n),
                          onPressed: () async {
                            timecontrol.operationMode.winter = !(timecontrol.operationMode.winter);
                            await timecontrol.setOperationMode();
                            setState(() {});
                          }
                        )
                      ],
                    ),
                  ),
                ),
            
                if(timecontrol.operationMode.winter) const UICSpacer(),
            
                const UICSpacer(5),
            
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      spacing: theme.defaultWhiteSpace,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Opacity(
                          opacity: 0,
                          child: Text("0%")
                        ), // Fix 1px offset glitch
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
                            if(timecontrol.operationMode.sensorLoss || timecontrol.operationMode.windalert || timecontrol.operationMode.rainAlert) {
                              timecontrol.moveStop(TCClockChannel.wired);
                              timecontrol.moveStop(TCClockChannel.wired);
                              timecontrol.moveStop(TCClockChannel.wired);
                            }
                          },
                        ),
              
                        const Icon(Icons.swap_vert_rounded, size: 32),
                      ],
                    ),
              
                    if(!timecontrol.operationMode.sensorLoss && !timecontrol.operationMode.windalert && !timecontrol.operationMode.rainAlert) const UICSpacer(),
              
                    if(!timecontrol.operationMode.sensorLoss && !timecontrol.operationMode.windalert && !timecontrol.operationMode.rainAlert) Column(
                      spacing: theme.defaultWhiteSpace,
                      children: [
                        UICBigSlider(
                          value: min(100, timecontrol.position?.$1.toDouble() ?? 0.0),
                          onChanged: (value) {},
                          onChangeEnd: (value) {
                            double slat = min(100, timecontrol.position?.$2.toDouble() ?? 0.0);
                            if(value > min(100, timecontrol.position?.$1.toDouble() ?? 0.0)) {
                              slat = 100;
                            } else {
                              slat = 0;
                            }
                            timecontrol.moveToPosition(value.toInt(), TCClockChannel.wired, slat: slat.toInt());
                            
                          },
                        ),
                        const Icon(Icons.height_rounded, size: 32),
                      ],
                    ),
                    
                    if(operationType == TCOperationModeType.Venetian && !timecontrol.operationMode.sensorLoss && !timecontrol.operationMode.windalert && !timecontrol.operationMode.rainAlert) const UICSpacer(),
              
                    if(operationType == TCOperationModeType.Venetian && !timecontrol.operationMode.sensorLoss && !timecontrol.operationMode.windalert && !timecontrol.operationMode.rainAlert) Column(
                      spacing: theme.defaultWhiteSpace,
                      children: [
                        UICBigSlider(
                          width: 50,
                          value: min(100, timecontrol.position?.$2.toDouble() ?? 0.0),
                          onChanged: (value) {},
                          onChangeEnd: (value) {
                            timecontrol.moveToPosition(
                              timecontrol.position?.$1 ?? 0,
                              TCClockChannel.wired,
                              slat: value.toInt()
                            );
                          },
                        ),
                        const Icon(Icons.line_weight_rounded, size: 32),
                      ],
                    ),
                  ],
                ),
            
                const UICSpacer(3),
            
                Center(
                  child: SizedBox(
                    width: 110,
                    child: UICElevatedButton(
                      onPressed: () {
                        timecontrol.movePreset1(TCClockChannel.wired);
                      },
                      child: const Icon(BeckerIcons.one, size: 16,)
                    ),
                  ),
                ),
            
                const UICSpacer(),
              
                Center(
                  child: Text("Lüftungsposition".i18n),
                ),
              
                const UICSpacer(2),
              
                Center(
                  child: SizedBox(
                    width: 110,
                    child: UICElevatedButton(
                      onPressed: () {
                        timecontrol.movePreset2(TCClockChannel.wired);
                      },
                      child: const Icon(BeckerIcons.two, size: 16,)
                    ),
                  ),
                ),
              
                const UICSpacer(),
              
                Center(
                  child: Text("Beschattungsposition".i18n),
                ),
              
                const UICSpacer(3),
            
                Center(
                  child: GestureDetector(
                    onTap: () {
                      TimecontrolSunProtectionView.go(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(timecontrol.sunValue != null && timecontrol.operationMode.lightSensorExternal) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/sun.jpg",
                            name: "Sonne (Fassade)".i18n,
                            value: "${timecontrol.sunValue} / 15",
                            borderColor: (timecontrol.sunValue ?? 0) < (timecontrol.thresSunInternal ?? 0) ? null : theme.colorScheme.warnVariant.primaryContainer,
                            borderWidth: (timecontrol.sunValue ?? 0) < (timecontrol.thresSunInternal ?? 0) ? null : 5
                          ),
                        ),
              
                        if(timecontrol.sunValue != null && timecontrol.operationMode.lightSensorExternal) const UICSpacer(),
              
                        if(timecontrol.operationMode.dawnMode && timecontrol.dawnValue != null) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/dawn.jpg",
                            name: "Dämmerung".i18n,
                            value: "${min(timecontrol.dawnValue ?? 0, 15)} / 15",
                            borderColor: (timecontrol.dawnValue ?? 0) < (timecontrol.thresDawnInternal ?? 0) ? null : theme.colorScheme.warnVariant.primaryContainer,
                            borderWidth: (timecontrol.dawnValue ?? 0) < (timecontrol.thresDawnInternal ?? 0) ? null : 5
                          ),
                        ),
            
                        if(timecontrol.operationMode.dawnMode && timecontrol.dawnValue != null) const UICSpacer(),
              
                        if(timecontrol.sunValue != null && timecontrol.operationMode.lightSensorInternal) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/sun.jpg",
                            name: "Sonne (Fenster)".i18n,
                            value: "${timecontrol.sunValue} / 15",
                            borderColor: (timecontrol.sunValue ?? 0) < (timecontrol.thresSunInternal ?? 0) ? null : theme.colorScheme.warnVariant.primaryContainer,
                            borderWidth: (timecontrol.sunValue ?? 0) < (timecontrol.thresSunInternal ?? 0) ? null : 5
                          ),
                        ),
                        
                        if(timecontrol.operationMode.windSensor && timecontrol.sunValue != null) const UICSpacer(),
                  
                        if(timecontrol.operationMode.windSensor) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/wind.jpg",
                            name: "Wind".i18n,
                            value: "${timecontrol.windValue} / 11",
                            borderColor: (timecontrol.windValue ?? 0) < (timecontrol.thresWind ?? 0)  ? null : theme.colorScheme.errorVariant.primaryContainer,
                            borderWidth: (timecontrol.windValue ?? 0) < (timecontrol.thresWind ?? 0)  ? null : 5
                          ),
                        ),
                        
                        if(timecontrol.rain == true) const UICSpacer(),
                  
                        if(timecontrol.rain == true) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/rain.jpg",
                            name: "Regen".i18n,
                            borderWidth: 5,
                            borderColor: theme.colorScheme.warnVariant.primaryContainer,
                          ),
                        ),
                      
                        if(timecontrol.frost == true) const UICSpacer(),
              
                        if(timecontrol.frost == true) SizedBox(
                          width: 180,
                          height: 180 * 3 / 4,
                          child: UICSmallTile(
                            image: "assets/images/sensor/temp.jpg",
                            name: "Temperatur".i18n,
                            borderWidth: 5,
                            borderColor: theme.colorScheme.errorVariant.primaryContainer,
                          ),
                        ),
              
                        const UICSpacer(2),
                      
                        if(timecontrol.sunValue != null && (timecontrol.operationMode.lightSensorExternal || timecontrol.operationMode.lightSensorInternal)) Center(
                          child:
                            Text("Hinweis: Manuelle oder automatische Fahrbefehle im aktivierten Sonnenschutzbetrieb führen zu einer Unterbrechung der Automatik bis der nächste Schwellwert über- oder unterschritten wird.".i18n, textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }
}
