part of 'module.dart';

class TimecontrolSunProtectionView extends StatefulWidget {
  static const path = '${TCHome.path}/sun_protection';

  static final route = GoRoute(
    path: path,
    pageBuilder:
        (context, state) => CustomTransitionPage(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          child: TimecontrolSunProtectionView(),
        ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const TimecontrolSunProtectionView({super.key});

  @override
  State<TimecontrolSunProtectionView> createState() =>
      _TimecontrolSunProtectionViewState();
}

class _TimecontrolSunProtectionViewState
    extends State<TimecontrolSunProtectionView> {
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  TCOperationModeParam operationMode = TCOperationModeParam();
  TCSunThresholdParam thresSunInternal = TCSunThresholdParam();
  TCSunThresholdParam thresSun = TCSunThresholdParam();

  int thresDawnInternal = 0;
  int thresDawn = 0;
  int thresWind = 0;
  int delayFrost = 0;
  int delayRain = 0;
  bool loading = true;

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    setState(() {
      loading = true;
    });
    operationMode =
        await timecontrol.getOperationMode() ?? TCOperationModeParam();
    thresSunInternal = await timecontrol.getThresholdSensorSun();
    thresDawnInternal = await timecontrol.getThresholdSensorDawn();
    thresWind = await timecontrol.getThresholdWindSensor();
    delayFrost = await timecontrol.getDelayFrostSensor();
    delayRain = await timecontrol.getDelayRainSensor();

    thresSun = thresSunInternal;
    thresDawn = thresDawnInternal;

    loading = false;

    if (mounted) {
      setState(() {});
    }
  }

  saveThresSun() async {
    await timecontrol.setInternalSensorSun(thresSun);
  }

  saveThresDawn() async {
    await timecontrol.setInternalSensorDawn(thresDawn);
  }

  saveThresWind() async {
    await timecontrol.setWindSensorThreshold(thresWind);
  }

  saveDelayFrost() async {
    await timecontrol.setFrostSensorDelay(delayFrost);
  }

  saveDelayRain() async {
    await timecontrol.setRainSensorDelay(delayRain);
  }

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (Theme.of(context).brightness == Brightness.light) {
      textColor = Colors.black;
    } else {
      textColor = Colors.white;
    }

    bool enableLightSensor =
        operationMode.lightSensorInternal || operationMode.lightSensorExternal;
    return UICPage(
      //title: "Sonnenschutz".i18n,
      //loading: loading,
      //elevation: 0,
      //menu: true,
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(
          leading: UICTitle("Sonnenschutz".i18n),
        ),
        UICConstrainedSliverList(
          maxWidth: 640,
          children: [
            if (!enableLightSensor && !operationMode.windSensor)
              const UICSpacer(),
            if (!enableLightSensor && !operationMode.windSensor)
              Center(
                child: Text(
                  "Sensoren sind für dieses Gerät nicht konfiguriert.".i18n,
                ),
              ),
            if (!enableLightSensor && !operationMode.windSensor)
              const UICSpacer(),

            if (!enableLightSensor && !operationMode.windSensor)
              Center(
                child: UICElevatedButton(
                  child: Text("Einstellungen".i18n),
                  onPressed: () async {
                    TimecontrolSystemView.go(context);
                  },
                ),
              ),

            const UICSpacer(2),

            if (enableLightSensor || operationMode.windSensor)
              Consumer<Timecontrol>(
                builder: (context, timecontrol, _) {
                  final theme = Theme.of(context);
                  return Center(
                    child: SizedBox(
                      width: 400,
                      child: GridView(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 4 / 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        children: [
                          if (timecontrol.sunValue != null &&
                              timecontrol.operationMode.lightSensorExternal)
                            UICSmallTile(
                              opacity: .5,
                              image: "assets/images/sensor/sun.jpg",
                              name: "Sonne (Fassade)".i18n,
                              value: "${timecontrol.sunValue} / 15",
                              borderColor:
                                  (timecontrol.sunValue ?? 0) <
                                          (timecontrol.thresSunInternal ?? 0)
                                      ? null
                                      : theme
                                          .colorScheme
                                          .warnVariant
                                          .primaryContainer,
                              borderWidth:
                                  (timecontrol.sunValue ?? 0) <
                                          (timecontrol.thresSunInternal ?? 0)
                                      ? null
                                      : 5,
                            ),

                          if (timecontrol.dawnValue != null &&
                              (timecontrol.operationMode.lightSensorExternal ||
                                  timecontrol
                                      .operationMode
                                      .lightSensorInternal))
                            UICSmallTile(
                              opacity: .5,
                              image: "assets/images/sensor/dawn.jpg",
                              name: "Dämmerung".i18n,
                              value: "${timecontrol.dawnValue} / 15",
                              borderColor:
                                  (timecontrol.dawnValue ?? 0) <
                                          (timecontrol.thresDawnInternal ?? 0)
                                      ? null
                                      : theme
                                          .colorScheme
                                          .warnVariant
                                          .primaryContainer,
                              borderWidth:
                                  (timecontrol.dawnValue ?? 0) <
                                          (timecontrol.thresDawnInternal ?? 0)
                                      ? null
                                      : 5,
                            ),

                          if (timecontrol.sunValue != null &&
                              timecontrol.operationMode.lightSensorInternal)
                            UICSmallTile(
                              opacity: .5,
                              image: "assets/images/sensor/sun.jpg",
                              name: "Sonne (Fenster)".i18n,
                              value: "${timecontrol.sunValue} / 15",
                              borderColor:
                                  (timecontrol.sunValue ?? 0) <
                                          (timecontrol.thresSunInternal ?? 0)
                                      ? null
                                      : theme
                                          .colorScheme
                                          .warnVariant
                                          .primaryContainer,
                              borderWidth:
                                  (timecontrol.sunValue ?? 0) <
                                          (timecontrol.thresSunInternal ?? 0)
                                      ? null
                                      : 5,
                            ),

                          if (timecontrol.operationMode.windSensor)
                            UICSmallTile(
                              opacity: .5,
                              image: "assets/images/sensor/wind.jpg",
                              name: "Wind".i18n,
                              value: "${timecontrol.windValue} / 11",
                              borderColor:
                                  (timecontrol.windValue ?? 0) <
                                          (timecontrol.thresWind ?? 0)
                                      ? null
                                      : theme
                                          .colorScheme
                                          .errorVariant
                                          .primaryContainer,
                              borderWidth:
                                  (timecontrol.windValue ?? 0) <
                                          (timecontrol.thresWind ?? 0)
                                      ? null
                                      : 5,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const UICSpacer(3),

            if (enableLightSensor)
              UICGridTile(
                bodyPadding: EdgeInsets.all(
                  Theme.of(context).defaultWhiteSpace,
                ),
                borderColor: Colors.transparent,
                title: UICGridTileTitle(title: Text("Sonnensensor".i18n)),
                body: Column(
                  children: [
                    if (enableLightSensor)
                      UICNamedDivider(
                        child: Text("Schwellwert Sonne ausfahren".i18n),
                      ),
                    if (enableLightSensor)
                      UICColorSlider(
                        min: 1,
                        max: 15,
                        divisions: 14,
                        value: min(max(2, thresSun.thresOut.toDouble()), 15),
                        backgroundGradient: const [
                          Color(0xFFffcd00),
                          Color(0xBFffcd00),
                        ],
                        altRightColor: textColor,
                        altLeftColor: textColor,
                        onChange: (v) {
                          if (v.toInt() <= thresSun.thresIn.toInt()) {
                            thresSun.thresOut = v.toInt();
                            thresSun.thresIn = thresSun.thresOut - 1;
                          } else {
                            thresSun.thresOut = v.toInt();
                          }
                          setState(() {});
                        },
                        onChangeEnd: (_) => saveThresSun(),
                      ),

                    if (enableLightSensor)
                      UICNamedDivider(
                        child: Text("Schwellwert Sonne einfahren".i18n),
                      ),
                    if (enableLightSensor)
                      UICColorSlider(
                        min: 1,
                        max: 15,
                        divisions: 14,
                        value: min(max(1, thresSun.thresIn.toDouble()), 14),
                        backgroundGradient: const [
                          Color(0xFF00c6ff),
                          Color(0xFF0072ff),
                        ],
                        onChange: (v) {
                          if (v.toInt() >= thresSun.thresOut.toInt()) {
                            thresSun.thresIn = v.toInt();
                            thresSun.thresOut = thresSun.thresIn + 1;
                          } else {
                            thresSun.thresIn = v.toInt();
                          }
                          setState(() {});
                        },
                        onChangeEnd: (_) => saveThresSun(),
                      ),

                    if (enableLightSensor)
                      UICNamedDivider(
                        child: Text("Ausfahrverzögerung Sonne (Min)".i18n),
                      ),
                    if (enableLightSensor)
                      UICColorSlider(
                        min: 3,
                        max: 15,
                        divisions: 12,
                        backgroundGradient: const [
                          Color(0xFFffcd00),
                          Color(0xBFffcd00),
                        ],
                        value: max(
                          min(thresSun.delayOut.toDouble() / 60, 15),
                          3,
                        ),
                        onChange:
                            (v) => setState(
                              () => thresSun.delayOut = (v * 60).toInt(),
                            ),
                        onChangeEnd: (_) => saveThresSun(),
                      ),

                    if (enableLightSensor)
                      UICNamedDivider(
                        child: Text("Einfahrverzögerung Sonne (Min)".i18n),
                      ),
                    if (enableLightSensor)
                      UICColorSlider(
                        min: 6,
                        max: 30,
                        divisions: 24,
                        value: min(
                          max(thresSun.delayIn.toDouble() / 60, 6),
                          30,
                        ),
                        onChange:
                            (v) => setState(
                              () => thresSun.delayIn = (v * 60).toInt(),
                            ),
                        altRightColor: textColor,
                        altLeftColor: textColor,
                        onChangeEnd: (_) => saveThresSun(),
                      ),

                    if (enableLightSensor && timecontrol.operationMode.dawnMode)
                      UICNamedDivider(
                        child: Text("Schwellwert Dämmerung".i18n),
                      ),

                    if (enableLightSensor && timecontrol.operationMode.dawnMode)
                      UICColorSlider(
                        min: 1,
                        max: 15,
                        divisions: 15,
                        value: min(max(1, thresDawn.toDouble()), 15),
                        backgroundGradient: const [
                          Color(0xFF0072ff),
                          Color(0xFFffcd00),
                        ],
                        altRightColor: textColor,
                        altLeftColor: textColor,
                        onChange: (v) => setState(() => thresDawn = v.toInt()),
                        onChangeEnd: (_) => saveThresDawn(),
                      ),
                  ],
                ),
              ),

            if (operationMode.windSensor) const UICSpacer(),
            if (operationMode.windSensor)
              UICGridTile(
                bodyPadding: EdgeInsets.all(
                  Theme.of(context).defaultWhiteSpace,
                ),
                borderColor: Colors.transparent,
                title: UICGridTileTitle(title: Text("Windsensor".i18n)),
                body: Column(
                  children: [
                    if (operationMode.windSensor)
                      UICNamedDivider(child: Text("Schwellwert Wind".i18n)),
                    if (operationMode.windSensor)
                      UICColorSlider(
                        min: 1,
                        max: 11,
                        divisions: 11,
                        value: max(1, min(11, thresWind.toDouble())),
                        onChange: (v) => setState(() => thresWind = v.toInt()),
                        onChangeEnd: (_) => saveThresWind(),
                        backgroundGradient: const [Colors.white, Colors.red],
                        altRightColor: Colors.white,
                        altLeftColor: Colors.red,
                      ),

                    // if(operationMode.temperatureActive) UICNamedDivider(child: Text("Verzögerung Frost (Min)".i18n)),
                    // if(operationMode.temperatureActive) UICColorSlider(
                    //   min: 0,
                    //   max: 60,
                    //   divisions: 60,
                    //   backgroundGradient: const [
                    //     Colors.blue,
                    //     Colors.lightBlue,
                    //   ],
                    //   altRightColor: textColor,
                    //   altLeftColor: textColor,
                    //   value: max(min(delayFrost.toDouble() / 60, 60), 0),
                    //   onChange: (v) => setState(() => delayFrost = (v * 60).toInt()),
                    //   onChangeEnd: (_) => saveDelayFrost(),
                    // ),

                    // UICNamedDivider(child: Text("Verzögerung Regen (Min)".i18n)),
                    // UICColorSlider(
                    //   min: 0,
                    //   max: 60,
                    //   divisions: 60,
                    //   value: max(min(delayRain.toDouble() / 60, 60), 0),
                    //   onChange: (v) => setState(() => delayRain = (v * 60).toInt()),
                    //   onChangeEnd: (_) => saveDelayRain(),
                    //   backgroundGradient: [
                    //     color,
                    //     color,
                    //   ],
                    //   altRightColor: textColor,
                    //   altLeftColor: textColor,
                    // ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
