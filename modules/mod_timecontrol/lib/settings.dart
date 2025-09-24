part of 'module.dart';

class TimecontrolSystemView extends StatefulWidget {
  static const path = '${TCHome.path}/system';

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
      child: TimecontrolSystemView(),
    ),
  );

  static go (BuildContext context) {
    context.push(path);
  }

  const TimecontrolSystemView({super.key});

  @override
  State<TimecontrolSystemView> createState() => _TimecontrolSystemViewState();
}

class _TimecontrolSystemViewState extends State<TimecontrolSystemView> {
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  late final messenger = UICMessenger.of(context);
  final nameController = TextEditingController();

  TCOperationModeType type = TCOperationModeType.Shutter;
  
  bool summerTime = false;
  bool loading = true;
  DateTime? time;
  String timeString = "";
  bool isStored = false;
  
  Version? version;
  String? setupDate;
  int? cycles;
  int? operationTime;
  int enableAdditionalSensors = 0;
  double? runtime;
  double? turnaround;

  double? correctionStart;
  int? correctionUpDownPercent;
  double? correctionReactionTime;

  bool nameError = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    loading = true;
    version = await timecontrol.getVersion();
    time = await timecontrol.getDateTime();
    timecontrol.operationMode = await timecontrol.getOperationMode() ?? TCOperationModeParam();
    

    final name = timecontrol.endpoint.name;
    final nameBytes = utf8.encode(name ?? "");
    final nameUint8List = List<int>.from(nameBytes)..removeWhere((v) => v == 0);
    final newName = utf8.decode(nameUint8List);

    nameController.text = newName.trim();

    if(time != null) {
      if(timecontrol.operationMode.amTimeDisplay == true) {
        timeString = DateFormat("dd.MM.y - hh:mm a").format(time!);
      } else {
        timeString = "%s Uhr".i18n.fill([DateFormat("dd.MM.y - HH:mm").format(time!)]);
      }
    }
    summerTime = await timecontrol.getSummerTime();

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

    enableAdditionalSensors = await timecontrol.getEnableAdditionalSensors() ?? 0;

    type = await timecontrol.getType() ?? TCOperationModeType.Shutter;

    runtime = await timecontrol.getRuntime();

    turnaround = await timecontrol.getTurnaround();

    final correctionFactors = await timecontrol.getCorrectionFactors();

    if(correctionFactors != null && correctionFactors.length == 3) {
      correctionStart = correctionFactors[0] / 100;
      correctionUpDownPercent = correctionFactors[1];
      correctionReactionTime = correctionFactors[2] / 100;
    }

    loading = false;
    setState(() { });
  }

  saveOperationMode() async {
    await timecontrol.setOperationMode();
    setState(() {});
  }

  Future<void> saveTurnaroundConfiguration (double value) async {
    await timecontrol.setTurnaround(value);
  }

  Future<void> saveRuntimeConfiguration (double value) async {
    await timecontrol.setRuntime(value);
  }

  runRuntimeSetup ([TCSetupData? data]) async {
    final messenger = UICMessenger.of(context);
    if(data == null) {
      version = await timecontrol.getVersion();
    }
    final setupData = data ?? TCSetupData(
      version: version ?? Version.parse("0.0.0"),
      title: "Einrichtungsassistent".i18n,
      providers: [
        StreamProvider.value(
          initialData: timecontrol,
          value: timecontrol.updateStream.stream,
          updateShouldNotify: (_, __) => true,
        ),
      ],
      step: (route, dynamic setupData) {
        switch (route) {
          case "/":
            return TCSetupStep3One(data: setupData, standalone: true);
          case TCSetupStep3One.path:
            return TCSetupStep3One(data: setupData);
          case TCSetupStep3Two.path:
            return TCSetupStep3Two(data: setupData);
          case TCSetupStep4.path:
            return TCSetupStep4(data: setupData);
          default:
            return TCSetupStep9(data: setupData);
        }
      }
    );

    setupData.operationMode = await timecontrol.getType() ?? TCOperationModeType.Shutter;
    
    try {
      await messenger.alert(UICSetupRunnerAlert(
        setupData: setupData
      ));
    } catch(e) {
      rethrow;
    }

    runtime = await timecontrol.getRuntime();
    turnaround = await timecontrol.getTurnaround();
    setState(() { });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boldText = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
        return UICPage(
          loading: loading,
          slivers: [
            UICPinnedHeader(
              leading: UICTitle("System".i18n),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: 640,
                  child: Column(
                    children: [
                      if(!loading) Column(
                        children: [
                  
                          const UICSpacer(2),
                          
                          UICGridTile(
                            collapsed: false,
                            collapsible: true,
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            elevation: 2,
                            title: UICGridTileTitle(
                              backgroundColor: Colors.transparent,
                              foregroundColor: theme.colorScheme.onSurface,
                              title: Text("Name".i18n),
                            ),
                            body: Padding(
                              padding: EdgeInsets.all(theme.defaultWhiteSpace),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: UICTextInput(
                                          controller: nameController,
                                          onChanged: (String value) {
                                            final len = utf8.encode(nameController.text).length;
                                            setState(() {
                                              if(len > 21) {
                                                nameError = true;
                                                nameController.text = nameController.text.substring(0, nameController.text.length - 1);
                                              } else {
                                                nameError = false;
                                                timecontrol.endpoint.name = nameController.text;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                  
                                      const UICSpacer(),
                                      
                                      UICGridTileAction(
                                        onPressed: () async {
                                          timecontrol.setDeviceName(nameController.text);
                                        },
                                        style: UICColorScheme.success,
                                        child: const Icon(Icons.save_rounded)
                                      )
                                    ],
                                  ),
                  
                                  if(nameError) Text("Der Name darf maximal 21 Zeichen lang sein".i18n),
                                ],
                              ),
                            ),
                          ),
                  
                          const UICSpacer(),
                  
                          UICGridTile(
                            collapsed: false,
                            collapsible: true,
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            elevation: 2,
                            title: UICGridTileTitle(
                              backgroundColor: Colors.transparent,
                              foregroundColor: theme.colorScheme.onSurface,
                              title: Text("Einstellungen".i18n),
                            ),
                            body: Padding(
                              padding: EdgeInsets.all(theme.defaultWhiteSpace),
                              child: Column(
                                children: [
                                  Center(child: Text(timeString, style: Theme.of(context).textTheme.headlineSmall,)),
                                  
                                  const UICSpacer(),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Automatische Sommerzeit".i18n),
                                      
                                      UICSwitch(
                                        value: summerTime,
                                        onChanged: () async {
                                          summerTime = !summerTime;
                                          await timecontrol.setSummerTime(summerTime);
                                          setState(() {});
                                        }
                                      ),
                                    ],
                                  ),
                                  
                                  const UICSpacer(),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("PM / AM".i18n),
                                      
                                      UICSwitch(
                                        value: timecontrol.operationMode.amTimeDisplay,
                                        onChanged: () async {
                                          timecontrol.operationMode.amTimeDisplay = !(timecontrol.operationMode.amTimeDisplay);
                                          if(time != null) {
                                            if(timecontrol.operationMode.amTimeDisplay == true) {
                                              timeString = DateFormat("dd.MM.y - hh:mm a").format(time!);
                                            } else {
                                              timeString = "%s Uhr".i18n.fill([DateFormat("dd.MM.y - HH:mm").format(time!)]);
                                            }
                                          }
                                      
                                          setState(() {});
                                          await timecontrol.setOperationMode();
                                        }
                                      ),
                                    ],
                                  ),
                  
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  
                      const UICSpacer(),
                  
                      UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        elevation: 2,
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Betriebsart & Einstellungen".i18n),
                        ),
                  
                        body: Padding(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Column(
                            spacing: theme.defaultWhiteSpace,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Betriebsart:".i18n),
                                  Text(
                                    type == TCOperationModeType.Shutter ? "Rollladen / Screen".i18n
                                      : type == TCOperationModeType.Awning ? "Markise".i18n
                                      : type == TCOperationModeType.Venetian ? "Jalousie".i18n
                                      : "",
                                  )
                                ]
                              ),
                  
                              Center(
                                child: UICElevatedButton(
                                  shrink: true,
                                  style: UICColorScheme.warn,
                                  onPressed: () async {
                                    final answer = await messenger.alert(UICSimpleConfirmationAlert(
                                      title: "Betriebsart ändern".i18n,
                                      child: Text("Ein Wechsel der Betriebsart führt dazu, dass das Gerät auf Werkseinstellungen zurückgesetzt wird - danach wird der Inbetriebnahmeassistent erneut ausgeführt.".i18n),
                                    ));
                                
                                    if(answer == true) {
                                      await timecontrol.reset();
                                    }
                                  },
                                  child: Text("Betriebsart ändern".i18n)
                                ),
                              ),
                  
                              const Divider(),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Memo-Funktion".i18n, style: boldText),
                                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.memo,
                                    onChanged: () async {
                                      timecontrol.operationMode.memo = !(timecontrol.operationMode.memo);
                                  
                                      setState(() {});
                                      await timecontrol.setOperationMode();
                                    }
                                  ),
                                ],
                              ),
                  
                              Padding(
                                padding: EdgeInsets.only(left: theme.defaultWhiteSpace * 2),
                                child: Text("Erlaubt das Abspeichern der aktuellen Uhrzeit als Schaltzeit durch langes Drücken der entsprechenden Fahrtaste (>6s).".i18n),
                              ),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Urlaubs-Funktion".i18n, style: boldText),
                                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.random,
                                    onChanged: () async {
                                      timecontrol.operationMode.random = !timecontrol.operationMode.random;
                                  
                                      setState(() {});
                                      await timecontrol.setOperationMode();
                                    }
                                  ),
                                ],
                              ),
                  
                              Padding(
                                padding: EdgeInsets.only(left: theme.defaultWhiteSpace * 2),
                                child: Text("Verschiebt die programmierten Schaltzeiten zufällig im Bereich von 30 Minuten. Soll eine Anwesenheit simulieren.".i18n),
                              ),
                            ],
                          ),
                        ),
                      ),
                  
                      const UICSpacer(),
                  
                      UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        elevation: 2,
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Sensoren & Eingänge".i18n),
                        ),
                  
                        body: Padding(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Column(
                            spacing: theme.defaultWhiteSpace,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  
                              if((version?.compareTo(Version.parse("2.0.0")) ?? 0) >= 0) Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Displayanzeige Sonne / Wind".i18n),
                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.showSunWindInDisplay,
                                    onChanged: () async {
                                      timecontrol.operationMode.showSunWindInDisplay = !(timecontrol.operationMode.showSunWindInDisplay);
                                      saveOperationMode();
                                    }
                                  ),
                                ],
                              ),

                              if((version?.compareTo(Version.parse("2.0.0")) ?? 0) >= 0) Divider(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Lichtsensor außen".i18n),
                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.lightSensorExternal,
                                    onChanged: () async {
                                      timecontrol.operationMode.lightSensorExternal = !(timecontrol.operationMode.lightSensorExternal);
                                      saveOperationMode();
                                    }
                                  ),
                                ],
                              ),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Lichtsensor innen".i18n),
                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.lightSensorInternal,
                                    onChanged: () async {
                                      timecontrol.operationMode.lightSensorInternal = !(timecontrol.operationMode.lightSensorInternal);
                                      saveOperationMode();
                                    }
                                  ),
                                ],
                              ),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Windsensor".i18n),
                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.windSensor,
                                    onChanged: () async {
                                      timecontrol.operationMode.windSensor = !(timecontrol.operationMode.windSensor);
                                      saveOperationMode();
                                    }
                                  ),
                  
                                ],
                              ),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Dämmerung".i18n),
                  
                                  UICSwitch(
                                    value: timecontrol.operationMode.dawnMode,
                                    onChanged: () async {
                                      timecontrol.operationMode.dawnMode = !(timecontrol.operationMode.dawnMode);
                                      saveOperationMode();
                                    }
                                  ),
                  
                                ],
                              ),
                  
                              Center(
                                child: UICElevatedButton(
                                  shrink: true,
                                  style: UICColorScheme.warn,
                                  onPressed: () async {
                                    final answer = await messenger.alert(UICSimpleConfirmationAlert(
                                      title: "Sensoren zurücksetzen".i18n,
                                      child: Text("Möchten Sie wirklich alle Sensoren zurücksetzen?".i18n),
                                    ));
                  
                                    if(answer == true) {
                                      timecontrol.operationMode.windSensor = false;
                                      timecontrol.operationMode.lightSensorExternal = false;
                                      timecontrol.operationMode.lightSensorInternal = false;
                                      timecontrol.operationMode.dawnMode = false;
                                      await saveOperationMode();
                                    }
                                  },
                                  child: Text("Sensoren zurücksetzen".i18n),
                                ),
                              ),
                  
                              const Divider(),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Externe Eingänge".i18n),
                                  
                                  UICSwitch(
                                    value: enableAdditionalSensors == 0,
                                    onChanged: () async {
                                      enableAdditionalSensors = 0;
                                      setState(() {});
                                      await timecontrol.setEnableAdditionalSensors(0);
                                      await timecontrol.getEnableAdditionalSensors();
                                    }
                                  ),
                                ],
                              ),
                              
                              if(enableAdditionalSensors == 0) Padding(
                                padding: EdgeInsets.only(left: theme.defaultWhiteSpace * 2),
                                child: Column(
                                  spacing: theme.defaultWhiteSpace,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Kurzer Tastendruck: \n".i18n, style: boldText),
                                          TextSpan(text: "Stoppt die Bewegung oder führt eine Wendung aus.".i18n),
                                        ],
                                      )
                                    ),
                                
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Langer Tastendruck: \n".i18n, style: boldText),
                                          TextSpan(text: "Startet einen Fahrbefehl".i18n),
                                        ],
                                      )
                                    ),
                                    
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Doppeltipp: \n".i18n, style: boldText),
                                          TextSpan(text: "Fährt zur entsprechenden Zwischenposition".i18n),
                                        ],
                                      )
                                    ),
                                
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Signal >5 Sekunden: \n".i18n, style: boldText),
                                          TextSpan(text: "Fahren und Sperren in der entsprechenden Richtung (Automatiken werden deaktiviert)".i18n),
                                        ],
                                      )
                                    ),
                  
                                    const UICSpacer(),
                                  ]
                                ),
                              ),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Zusätzliche Sensoren".i18n),
                                  
                                  UICSwitch(
                                    value: enableAdditionalSensors != 0,
                                    onChanged: () async {
                                      timecontrol.operationMode.temperatureActive = !(timecontrol.operationMode.temperatureActive);
                                      await timecontrol.setEnableAdditionalSensors(enableAdditionalSensors == 0 ? 1 : 0);
                                      enableAdditionalSensors = enableAdditionalSensors == 0 ? 1 : 0;
                                      await saveOperationMode();
                                    }
                                  ),
                                ],
                              ),
                  
                              if(enableAdditionalSensors == 1) Padding(
                                padding: EdgeInsets.only(left: theme.defaultWhiteSpace * 2),
                                child: Column(
                                  spacing: theme.defaultWhiteSpace,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Regensensor-Eingang: \n".i18n, style: boldText),
                                          TextSpan(text: "Startet eine Fahrt und sperrt die Bedienung (Automatiken bleiben aktiv)".i18n),
                                        ],
                                      )
                                    ),
                                
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: "Innentemperatur-Sensor: \n".i18n, style: boldText),
                                          TextSpan(text: "Die Sonnenautomatik wird erst ausgelöst, wenn die am Sensor eingestellte Temperatur erreicht ist.".i18n),
                                        ],
                                      )
                                    ),
                                    
                                  ]
                                ),
                              ),
                  
                            ]
                          )
                        ),
                      ),
                  
                      const UICSpacer(),
                  
                      UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderColor: Colors.transparent,
                        bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Laufzeiten".i18n),
                        ),
                        body: Column(
                          spacing: theme.defaultWhiteSpace,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Laufzeit".i18n)),
                                
                                SizedBox(
                                  width: 100,
                                  child: UICTextFormField(
                                    label: "Sekunden".i18n,
                                    initialValue: runtime?.toString(),
                                    onChanged: (String value) {
                                      runtime = double.tryParse(value);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            if(type == TCOperationModeType.Venetian) Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Wendezeit".i18n)),
                
                                SizedBox(
                                  width: 100,
                                  child: UICTextFormField(
                                    label: "Sekunden".i18n,
                                    initialValue: turnaround?.toString(),
                                    onChanged: (String value) {
                                      turnaround = double.tryParse(value);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UICElevatedButton(
                                  shrink: true,
                                  style: UICColorScheme.variant,
                                  onPressed: () => unawaited(runRuntimeSetup()),
                                  leading: const Icon(Icons.height_rounded),
                                  child: Text("Lernfahrt".i18n),
                                ),
                
                                UICElevatedButton(
                                  shrink: true,
                                  style: UICColorScheme.success,
                                  onPressed: () async {
                                    if(turnaround == null || runtime == null) return;
                                    dev.log("==============================================");
                                    
                                    await Future.delayed(const Duration(milliseconds: 1500));
                                    
                                    await saveTurnaroundConfiguration(turnaround!.toDouble());
                                    await Future.delayed(const Duration(milliseconds: 1500));
                                    await saveRuntimeConfiguration(runtime!.toDouble());

                                    await Future.delayed(const Duration(milliseconds: 1500));

                                    final tcTurnaround = await timecontrol.getTurnaround();
                                    final tcRunTime = await timecontrol.getRuntime();

                                    dev.log("Turnaround: $tcTurnaround");
                                    dev.log("Runtime: $tcRunTime");

                                    setState(() {});

                                  },
                                  leading: const Icon(Icons.save_rounded),
                                  child: Text("speichern".i18n),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),
                  
                      if(correctionStart != null) const UICSpacer(),

                      if(correctionStart != null) UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderColor: Colors.transparent,
                        bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Korrekturen".i18n),
                        ),
                        body: Column(
                          spacing: theme.defaultWhiteSpace,
                          children: [
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Expanded(child: Text("Anlaufkorrektur".i18n)),
                            //     SizedBox(
                            //       width: 100,
                            //       child: UICTextFormField(
                            //         label: "Sekunden".i18n,
                            //         initialValue: (correctionStart ?? 0).toString(),
                            //         onChanged: (String value) {
                            //           try {
                            //             correctionStart = double.parse(value);
                            //           } catch(e) {
                            //             correctionStart = 15;
                            //           }
                            //           setState(() {});
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Auf / Ab %".i18n)),
                                SizedBox(
                                  width: 100,
                                  child: UICTextFormField(
                                    label: "Prozent".i18n,
                                    initialValue: (correctionUpDownPercent ?? 0).toString(),
                                    onChanged: (String value) {
                                      try {
                                        correctionUpDownPercent = int.parse(value);
                                      } catch(e) {
                                        correctionUpDownPercent = 0;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Expanded(child: Text("Reaktionszeit".i18n)),
                                
                            //     SizedBox(
                            //       width: 100,
                            //       child: UICTextFormField(
                            //         label: "Sekunden".i18n,
                            //         initialValue: (correctionReactionTime ?? 0).toString(),
                            //         onChanged: (String value) {
                            //           try {
                            //             correctionReactionTime = double.parse(value);
                            //           } catch(e) {
                            //             correctionReactionTime = 0;
                            //           }
                            //           setState(() {});
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                UICElevatedButton(
                                  shrink: true,
                                  style: UICColorScheme.success,
                                  onPressed: () async {
                                    await timecontrol.setCorrectionFactors(
                                      max(((correctionStart ?? 0.15) * 100).toInt(), 0),
                                      max(correctionUpDownPercent ?? 0, 0),
                                      max(((correctionReactionTime ?? 0) * 100).toInt(), 0)
                                    );
                                  },
                                  leading: const Icon(Icons.save_rounded),
                                  child: Text("speichern".i18n),
                                ),
                              ],
                            ),
                            
                          ],
                        )
                      ),
                  
                      const UICSpacer(),
                  
                      UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderColor: Colors.transparent,
                        bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Zwischenpositionen".i18n),
                        ),
                        body: Column(
                          children: [
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
                                        shrink: false,
                                        onPressed: () {
                                          timecontrol.movePreset1(TCClockChannel.wired);
                                        },
                                        leading: const RotatedBox(
                                          quarterTurns: 2,
                                          child: Icon(Icons.download),
                                        ),
                                        child: Text("Lüftungsposition (ZP1) anfahren".i18n)
                                      ),
                                  
                                      const UICSpacer(),
                                      
                                      UICElevatedButton(
                                        shrink: false,
                                        onPressed: () {
                                          timecontrol.movePreset2(TCClockChannel.wired);
                                        },
                                        leading: const Icon(Icons.download),
                                        child: Text("Beschattungsposition (ZP2) anfahren".i18n)
                                      ),
                                  
                                      const UICSpacer(3),
                                      
                                      UICElevatedButton(
                                        shrink: false,
                                        onPressed: () {
                                          timecontrol.configurePreset(TCClockChannel.wired, 1);
                                        },
                                        leading: const Icon(Icons.settings_applications),
                                        child: Text("Lüftungsposition (ZP1) setzen".i18n)
                                      ),
                                  
                                      const UICSpacer(),
                                      
                                      UICElevatedButton(
                                        shrink: false,
                                        onPressed: () {
                                          timecontrol.configurePreset(TCClockChannel.wired, 2);
                                        },
                                        leading: const Icon(Icons.settings_applications),
                                        child: Text("Beschattungsposition (ZP2) setzen".i18n)
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const UICSpacer(3),
                  
                            Center(
                              child: UICElevatedButton(
                                shrink: true,
                                style: UICColorScheme.error,
                                onPressed: () async {
                                  final messenger = UICMessenger.of(context);
                                  final answer = await messenger.alert(
                                    UICSimpleQuestionAlert(
                                      title: "Zwischenpositionen löschen".i18n,
                                      child: Text("Möchten Sie wirklich alle Zwischenpositionen löschen?".i18n),
                                    )
                                  );
                  
                                  if(answer == true) {
                                    await timecontrol.configurePreset(TCClockChannel.wired, 1, 2);
                                    await timecontrol.configurePreset(TCClockChannel.wired, 2, 2);
                                  }
                                },
                                leading: const Icon(Icons.remove_circle_outline_rounded),
                                child: Text("Zwischenpositionen löschen".i18n)
                              ),
                            ),
                          ]
                        )
                      ),

                      if((version?.compareTo(Version.parse("2.0.0")) ?? 0) >= 0) const UICSpacer(),

                      if((version?.compareTo(Version.parse("2.0.0")) ?? 0) >= 0) UICGridTile(
                        collapsed: true,
                        collapsible: true,
                        borderColor: Colors.transparent,
                        bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                        title: UICGridTileTitle(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          title: Text("Drehrichtungswechsel".i18n),
                        ),
                        body: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                              ],
                            ),
                            
                            const UICSpacer(3),
                  
                            Center(
                              child: UICElevatedButton(
                                shrink: true,
                                style: UICColorScheme.warn,
                                onPressed: () async {
                                  final messenger = UICMessenger.of(context);
                                  await messenger.alert(
                                    UICSimpleQuestionAlert(
                                      title: "Drehrichtungswechsel".i18n,
                                      child: Text("Möchten Sie die Drehrichtung ändern?".i18n),
                                    )
                                  );
                  
                                  timecontrol.operationMode.direction = !(timecontrol.operationMode.direction);
                                  saveOperationMode();
                                },
                                leading: const Icon(Icons.rotate_90_degrees_ccw_rounded),
                                child: Text("Drehrichtung ändern".i18n)
                              ),
                            ),
                          ]
                        )
                      ),
                  
                      if(!loading) const UICSpacer(),
                  
                      if(!loading) TimecontrolLocationEnsurer(enableSummerTime: summerTime),
                  
                      const UICSpacer(4),
                  
                      Center(
                        child: UICElevatedButton(
                          shrink: true,
                          style: UICColorScheme.error,
                          onPressed: () async {
                            final answer = await messenger.alert(UICSimpleQuestionAlert(
                              title: "Reset".i18n,
                              child: Text("Soll wirklich ein Reset durchgeführt werden?".i18n),
                            ));
                                    
                            if(answer != true) return;
                                    
                            await timecontrol.reset();
                          },
                          leading: const Icon(Icons.reset_tv_rounded),
                          child: Text("Werkseinstellungen".i18n)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}