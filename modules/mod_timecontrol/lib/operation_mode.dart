part of 'module.dart';

class TimecontrolOperationModeView extends StatefulWidget {
  static const path = '${TCHome.path}/operation_mode';

  static final route = GoRoute(
    path: path,
    pageBuilder:(context, state) => const NoTransitionPage(
      child: TimecontrolOperationModeView(),
    ),
  );

  static go (BuildContext context) {
    context.push(path);
  }

  const TimecontrolOperationModeView({super.key});

  @override
  State<TimecontrolOperationModeView> createState() => _TimecontrolOperationModeViewState();
}

class _TimecontrolOperationModeViewState extends State<TimecontrolOperationModeView> {
  late final Timecontrol timecontrol = Provider.of<Timecontrol>(context, listen: false);
  late final messenger = UICMessenger.of(context);

  final TextEditingController runtimeController = TextEditingController();
  final TextEditingController tensionController = TextEditingController();
  final TextEditingController turnaroundController = TextEditingController();
  final TextEditingController correctionController = TextEditingController();

  TCOperationModeType type = TCOperationModeType.Shutter;
  bool needsUpdate = false;
  int enableAdditionalSensors = 0;
  bool fastMode = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  bool isDouble (String s) {
    return double.tryParse(s) != null;
  }

  (bool, num) checkValid (num? input, double minValue, double maxValue) {
    if(input == null) return (false, minValue);
    return (input >= minValue && input <= maxValue, min(max(input, minValue), maxValue));
  }

  bool setUpdate () {
    needsUpdate = true;
    final runtimeValue = checkValid(NumberFormat().tryParse(runtimeController.text)?.toInt(), 0, 360);
    final tensionValue = checkValid(NumberFormat.currency(locale: Platform.localeName).tryParse(tensionController.text)?.toDouble(), 0, 25.5);
    final turnaroundValue = checkValid(NumberFormat.currency(locale: Platform.localeName).tryParse(turnaroundController.text)?.toDouble(), 0, 25.5);

    if(runtimeValue.$1 == false || tensionValue.$1 == false || turnaroundValue.$1 == false) {
      UICMessenger.of(context).alert(UICSimpleAlert(
        title: "Ungültige Eingabe".i18n,
        child: Column(
          children: [
            Text("Bitte geben Sie gültige Werte ein:".i18n),
            Text("Laufzeit: 0 - 360 Sekunden".i18n),
            Text("Wendezeit: 0 - 25,5 Sekunden".i18n),
          ],
        ),
      ));
      return false;
    }
    return true;

    // runtimeController.text = runtimeValue.$2.toString();
    // tensionController.text = tensionValue.$2.toString();
    // turnaroundController.text = turnaroundValue.$2.toString();
  }

  Future<void> asyncInit() async {
    type = await timecontrol.getType() ?? TCOperationModeType.Shutter;

    final runtime = await timecontrol.getRuntime();
    if(runtime != null) {
      runtimeController.text = runtime.toString();
    }

    final turnaround = await timecontrol.getTurnaround();
    turnaroundController.text = turnaround.toString();

    enableAdditionalSensors = await timecontrol.getEnableAdditionalSensors() ?? 0;

    await timecontrol.getOperationMode() ?? TCOperationModeParam();

    final deviceSpeed = await timecontrol.readLearn(TCClockChannel.all);
    correctionController.text = deviceSpeed.toString();

    setState(() {});
  }

  Future<void> toggleFastMode () async {
    fastMode = !fastMode;
    await timecontrol.learn(TCClockChannel.all, TCLearn.none, );
    setState(() {});
  }

  Future<void> saveRuntime ([bool silent = false]) async {
    final v = NumberFormat().parse(runtimeController.text).toDouble();
    await timecontrol.setRuntime(v);

    if(mounted && silent == false) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    }
  }

  Future<void> saveTurnaround([bool silent = false]) async {
    // FIXME: workaround for comma as decimal separator
    // FIXME: Bogus validation
    turnaroundController.text = turnaroundController.text.replaceAll(",", ".");
    final v = double.tryParse(turnaroundController.text) ?? 0;

    if(!isDouble(turnaroundController.text)) {
      turnaroundController.text = "0.0";
      await timecontrol.setTurnaround(0.0);
    } else {
      final value = max(0.0, min(25.5, v));
      turnaroundController.text = value.toString(); 
      await timecontrol.setTurnaround(value);
    }

    if(mounted && silent == false) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    }
  }

  Future<void> setCorrection() async {
    final v = NumberFormat().parse(correctionController.text).toInt();
    await timecontrol.learn(TCClockChannel.all, TCLearn.none, v);
    setState(() {});
  }

  saveOperationMode() async {
    await timecontrol.setOperationMode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldText = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return GestureDetector(
      onTapDown: (_) async {
        if(needsUpdate) {
          await saveTurnaround();
          await saveRuntime();
        }
        needsUpdate = false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return UICPage(
            //title: "Betriebsart / Laufzeit".i18n,
            //elevation: 0,
            //menu: true,
            slivers: [

              //Todo FIXME : Empty Header
              UICPinnedHeader(
                leading: UICTitle("Betriebsart".i18n),
              ),
              UICConstrainedSliverList(
                maxWidth: 640,
                children: [
                  UICGridTile(
                    borderColor: Colors.transparent,
                    bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                    title: UICGridTileTitle(
                      title: Text("Betriebsart".i18n),
                    ),
      
                    body: Column(
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

                        UICElevatedButton(
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
                          child: Text("Ändern".i18n)
                        ),

                      ],
                    ),
                  ),

                  const UICSpacer(),
      
                  UICGridTile(
                    borderColor: Colors.transparent,
                    bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                    title: UICGridTileTitle(
                      title: Text("Sensoren".i18n),
                    ),
                    body: Column(
                      spacing: theme.defaultWhiteSpace,
                      children: [
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

                        const Divider(),

                        UICElevatedButton(
                          style: UICColorScheme.warn,
                          onPressed: () async {
                            timecontrol.operationMode.windSensor = false;
                            timecontrol.operationMode.lightSensorExternal = false;
                            timecontrol.operationMode.lightSensorInternal = false;
                            await saveOperationMode();
                          },
                          child: Text("Sensoren zurücksetzen".i18n),
                        ),
                      ]
                    )
                  ),

                  const UICSpacer(),

                  UICGridTile(
                    borderColor: Colors.transparent,
                    bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                    title: UICGridTileTitle(
                      title: Text("Eingänge".i18n),
                    ),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: theme.defaultWhiteSpace,
                      children: [
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
                                  children: [
                                    TextSpan(text: "Kurzer Tastendruck: \n".i18n, style: boldText),
                                    TextSpan(text: "Stoppt die Bewegung oder führt eine Wendung aus.".i18n),
                                  ],
                                )
                              ),
                          
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "Langer Tastendruck: \n".i18n, style: boldText),
                                    TextSpan(text: "Statet einen Fahrbefehl".i18n),
                                  ],
                                )
                              ),
                              
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "Doppeltipp: \n".i18n, style: boldText),
                                    TextSpan(text: "Fährt zur entsprechenden Zwischenposition".i18n),
                                  ],
                                )
                              ),
                          
                              RichText(
                                text: TextSpan(
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
                                  children: [
                                    TextSpan(text: "Regensensor-Eingang: \n".i18n, style: boldText),
                                    TextSpan(text: "Startet eine Fahrt und sperrt die Bedienung (Automatiken bleiben aktiv)".i18n),
                                  ],
                                )
                              ),
                          
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "Innentemperatur-Sensor: \n".i18n, style: boldText),
                                    TextSpan(text: "Die Sonnenautomatik wird erst ausgelöst, wenn die am Sensor eingestellte Temperatur erreicht ist.".i18n),
                                  ],
                                )
                              ),
                              
                            ]
                          ),
                        ),
                      ],
                    )
                  ),

                  const UICSpacer(),

                  UICGridTile(
                    borderColor: Colors.transparent,
                    bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                    title: UICGridTileTitle(
                      title: Text("Laufzeiten".i18n),
                    ),
                    body: Column(
                      spacing: theme.defaultWhiteSpace,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Laufzeit".i18n),
                            SizedBox(
                              width: 100,
                              child: UICTextInput(
                                keyboardType: TextInputType.number,
                                controller: runtimeController,
                                onEditingComplete: saveRuntime,
                              ),
                            )
                          ],
                        ),
            
                        if(type == TCOperationModeType.Venetian) Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Wendezeit".i18n),
                            SizedBox(
                              width: 100,
                              child: UICTextInput(
                                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                controller: turnaroundController,
                                onEditingComplete: saveTurnaround,
                              ),
                            )
                          ],
                        ),
                        
                        Center(
                          child: UICElevatedButton(
                            style: UICColorScheme.success,
                            onPressed: () async {
                              await saveTurnaround();
                              // await saveTenstion();
                              await saveRuntime();
                            },
                            leading: const Icon(Icons.save),
                            child: Text("Speichern".i18n),
                          ),
                        ),
                      ],
                    )
                  ),

                  if(type == TCOperationModeType.Awning) const UICSpacer(),
      
                  if(type == TCOperationModeType.Awning) UICGridTile(
                    borderColor: Colors.transparent,
                    bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
                    title: UICGridTileTitle(
                      title: Text("Zusatzfunktionen".i18n),
                    ),
                    body: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ 
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Wintermodus".i18n),
                        ),
                        UICSwitch(
                          value: timecontrol.operationMode.winter,
                          onChanged: () async {
                            timecontrol.operationMode.winter = !(timecontrol.operationMode.winter);
                            saveOperationMode();
                            setState(() {});
                          }
                        ),
                      ],
                    ),
                  ),
      
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}
