part of '../module.dart';

class TCSetupData extends UICSetupRunnerData {
  TCOperationModeType operationMode = TCOperationModeType.Shutter;
  List<TCClockParam> clocks = [];
  bool complete = false;

  bool pos1up = false;
  bool pos1dn = false;
  bool pos2up = false;
  bool pos2dn = false;
  Version version;

  TCSetupData({
    required super.step,
    required super.title,
    required this.version,
    super.providers = const []
  });

  resetPos () {
    pos1up = false;
    pos1dn = false;
    pos2up = false;
    pos2dn = false;
  }
}


class TCSetupContentWrap extends StatelessWidget {
  final Widget child;
  const TCSetupContentWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 400,
      child: child
    );
  }
}

class TCSetupStep1 extends StatelessWidget {
  static const String path = "step-1";

  final TCSetupData data;

  const TCSetupStep1({
    super.key,
    required this.data
  });

  @override
  Widget build(BuildContext context) {
    return TCSetupContentWrap(
      child: Column(
        children: [
          Expanded(child: Container()),

          Text("Herzlich Willkommen zur Ersteinrichtung ihres Becker-Antriebe-Produktes!".i18n, textAlign: TextAlign.center),

          const UICSpacer(2),

          Image.asset('assets/timecontrol/timecontrol.png',
            filterQuality: FilterQuality.medium,
            fit: BoxFit.contain,
            width: 100,
            height: 100
          ),

          const UICSpacer(2),

          Text("In den nächsten Schritten werden wir Sie durch die Einrichtung Ihrer neuen Steuerung führen.".i18n, textAlign: TextAlign.center),

          Expanded(child: Container()),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  navigator.pushNamed(TCSetupStep2.path);
                },
                child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TCSetupStep2 extends StatelessWidget {
  static const String path = "step-2";
  final TCSetupData data;
  const TCSetupStep2({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final timecontrol = Provider.of<Timecontrol>(context, listen: false);
    return TCSetupContentWrap(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const UICSpacer(),

          Center(
            child: Text("Betriebsart".i18n, style: Theme.of(context).textTheme.titleLarge)
          ),

          const UICSpacer(),

          Text("Welches Produkt ist an Ihre Steuerung angeschlossen?".i18n, textAlign: TextAlign.center,),

          Expanded(child: Container()),

          TextButton(
            onPressed: () {
              data.operationMode = TCOperationModeType.Shutter;
              if(data.version.compareTo(Version.parse("2.0.0")) >= 0) {
                navigator.pushNamed(TCSetupStep2One.path);
              } else {
                navigator.pushNamed(TCSetupStep3.path);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/timecontrol/typ_rollladen_installationsassistent.png'),
                    fit: BoxFit.cover,
                    opacity: .4
                  )
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Rollladen".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                  ],
                ),
              ),
            )
          ),

          const UICSpacer(),

          TextButton(
            onPressed: () async {
              
              data.operationMode = TCOperationModeType.Venetian;
              await timecontrol.setCorrectionFactors(10, 0, 20);

              if(data.version.compareTo(Version.parse("2.0.0")) >= 0) {
                navigator.pushNamed(TCSetupStep2One.path);
              } else {
                navigator.pushNamed(TCSetupStep3One.path);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/timecontrol/typ_jalousie_installationsassistent.png'),
                    fit: BoxFit.cover,
                    opacity: .4
                  )
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Jalousie".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            )
          ),

          const UICSpacer(),

          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              data.operationMode = TCOperationModeType.Awning;
              await timecontrol.setCorrectionFactors(10, 5, 20);
              
              if(data.version.compareTo(Version.parse("2.0.0")) >= 0) {
                navigator.pushNamed(TCSetupStep2One.path);
              } else {
                navigator.pushNamed(TCSetupStep3One.path);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/timecontrol/typ_markise_screen_installationsassistent.png'),
                    fit: BoxFit.cover,
                    opacity: .4
                  )
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Markise / Screen".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            )
          ),

          Expanded(child: Container()),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Zurück".i18n),
              ),
            ],
          ),

          const UICSpacer(),
        ],
      ),
    );
  }
}

class TCSetupStep2One extends StatelessWidget {
  static const String path = "step-2.1";
  final TCSetupData data;
  const TCSetupStep2One({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final timecontrol = Provider.of<Timecontrol>(context, listen: false);
    return TCSetupContentWrap(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const UICSpacer(),
      
          Center(
            child: Text("Drehrichtung".i18n, style: Theme.of(context).textTheme.titleLarge)
          ),
      
          const UICSpacer(3),

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
                final answer = await messenger.alert(
                  UICSimpleQuestionAlert(
                    title: "Drehrichtungswechsel".i18n,
                    child: Text("Möchten Sie die Drehrichtung ändern?".i18n),
                  )
                );
                if(answer == true) {
                  timecontrol.operationMode.direction = !(timecontrol.operationMode.direction);
                  timecontrol.setOperationMode();
                }
              },
              leading: const Icon(Icons.rotate_90_degrees_ccw_rounded),
              child: Text("Drehrichtung ändern".i18n)
            ),
          ),
      
          Expanded(child: Container()),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Zurück".i18n),
              ),


              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  if(data.operationMode == TCOperationModeType.Shutter) {
                    Navigator.of(context).pushNamed(TCSetupStep3.path);
                  } else {
                    Navigator.of(context).pushNamed(TCSetupStep3One.path);
                  }
                },
                child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ],
          ),
      
          const UICSpacer(),
        ],
      ),
    );
  }
}

class TCSetupStep3 extends StatefulWidget {
  static const String path = "step-3";
  final TCSetupData data;
  final bool standalone;

  const TCSetupStep3({super.key, required this.data, this.standalone = false});

  @override
  State<TCSetupStep3> createState() => _TCSetupStep3State();
}

class _TCSetupStep3State extends State<TCSetupStep3> {
  late final messenger = UICMessenger.of(context);

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Das Rollladen-Gewicht hat Einfluß auf die Genauigkeit der Positionsanfahrt und der Zwischenpositionen. Bitte wählen Sie das verbaute Material:".i18n, textAlign: TextAlign.start),
                ]
              ),

              Expanded(child: Container()),

              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await timecontrol.setCorrectionFactors(10, 5, 20);
                  navigator.pushNamed(TCSetupStep3One.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/timecontrol/tex_aluminium.png'),
                        fit: BoxFit.cover,
                        opacity: .6
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Aluminium".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                      ],
                    ),
                  ),
                )
              ),

              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await timecontrol.setCorrectionFactors(10, 0, 20);
                  navigator.pushNamed(TCSetupStep3One.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/timecontrol/tex_plastic.png'),
                        fit: BoxFit.cover,
                        opacity: .6
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Kunststoff".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                )
              ),

              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await timecontrol.setCorrectionFactors(10, 10, 20);
                  navigator.pushNamed(TCSetupStep3One.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/timecontrol/tex_wood.png'),
                        fit: BoxFit.cover,
                        opacity: .6
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Holz / Stahl".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                )
              ),

              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await timecontrol.setCorrectionFactors(10, 0, 20);
                  navigator.pushNamed(TCSetupStep3One.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/timecontrol/tex_screen.png'),
                        fit: BoxFit.cover,
                        opacity: .6
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Screen".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                )
              ),

              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await timecontrol.setCorrectionFactors(10, 5, 20);
                  navigator.pushNamed(TCSetupStep3One.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/timecontrol/tex_screen_heavy.png'),
                        fit: BoxFit.cover,
                        opacity: .6
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Screen mit Endleiste".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                )
              ),

              Expanded(child: Container()),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.abort);
                      Navigator.of(context).pop();
                    },
                    child: Text("Zurück".i18n),
                  ),

                  const UICSpacer(),

                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
class TCSetupStep3One extends StatefulWidget {
  static const String path = "step-3.1";
  final TCSetupData data;
  final bool standalone;

  const TCSetupStep3One({super.key, required this.data, this.standalone = false});

  @override
  State<TCSetupStep3One> createState() => _TCSetupStep3OneState();
}

class _TCSetupStep3OneState extends State<TCSetupStep3One> {

  @override
  initState() {
    super.initState();
    final timecontrol = Provider.of<Timecontrol>(context, listen: false);
    Future(() async {
      if(!widget.standalone) {
        await timecontrol.setType(widget.data.operationMode);
      }
      
      await timecontrol.learn(TCClockChannel.wired, TCLearn.start);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            children: [
              const UICSpacer(),

              Center(
                child: Text("Untere Endlage".i18n, style: Theme.of(context).textTheme.titleLarge)
              ),

              const UICSpacer(),

              if(widget.data.operationMode == TCOperationModeType.Shutter) Text("Fahren Sie Ihren Rollladen oder Screen in die untere Endlage und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Venetian) Text("Fahren Sie Ihre Jalousie untere Endlage und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Awning) Text("Fahren Sie Ihre Markise in die komplett geöffnete Position (ausgefahren) und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              UICBigMove(
                onStop: () {},
                onUp: () {
                  timecontrol.moveUp(TCClockChannel.wired);
                },
                onDown: () async {
                  widget.data.pos2dn = true;
                  timecontrol.moveDown(TCClockChannel.wired);
                },
                onRelease: () {
                  timecontrol.moveStop(TCClockChannel.wired);
                  setState(() {});
                },
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!widget.standalone) TextButton(
                    onPressed: () {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.abort);
                      Navigator.of(context).pop();
                    },
                    child: Text("Zurück".i18n),
                  ),

                  // Expanded(child: Container()),

                  // if(!widget.standalone) TextButton(
                  //   onPressed: () => Navigator.of(context).pushNamed(TCSetupStep7.path),
                  //   child: Text("Später".i18n),
                  // ),

                  const UICSpacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: !widget.data.pos2dn ? null : () async {
                      // await timecontrol.setRuntime(0, 0);
                      // print("test");
                      timecontrol.learn(TCClockChannel.wired, TCLearn.confirmLower);
                      if(widget.data.operationMode == TCOperationModeType.Venetian) {
                        Navigator.of(context).pushNamed(TCSetupStep3Two.path);
                      } else {
                        Navigator.of(context).pushNamed(TCSetupStep4.path);
                      }

                    },
                    child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class TCSetupStep3Two extends StatefulWidget {
  static const String path = "step-3.2";
  final TCSetupData data;
  final bool standalone;

  const TCSetupStep3Two({
    super.key,
    required this.data,
    this.standalone = false
  });

  @override
  State<TCSetupStep3Two> createState() => _TCSetupStep3TwoState();
}

class _TCSetupStep3TwoState extends State<TCSetupStep3Two> {

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            children: [
              const UICSpacer(),

              if(!widget.standalone) Center(
                child: Text("Wendungsposition".i18n, style: Theme.of(context).textTheme.titleLarge)
              ),

              const UICSpacer(),

              if(widget.data.operationMode == TCOperationModeType.Venetian) Text("Fahren Sie die Jalousie in AUF-Richtung, bis die maximale Wendung erreicht ist und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              UICBigMove(
                onStop: () {},
                onUp: () {
                  widget.data.pos1up = true;
                  timecontrol.moveToPosition(0, TCClockChannel.wired);
                },
                onDown: () {timecontrol.moveToPosition(1, TCClockChannel.wired);},
                onRelease: () {
                  timecontrol.moveStop(TCClockChannel.wired);
                  setState(() {});
                },
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!widget.standalone) TextButton(
                    onPressed: () {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.abort);
                      Navigator.of(context).pop();
                    },
                    child: Text("Zurück".i18n),
                  ),

                  Expanded(child: Container()),

                  // if(!widget.standalone) TextButton(
                  //   onPressed: () => Navigator.of(context).pushNamed(TCSetupStep7.path),
                  //   child: Text("Später".i18n),
                  // ),

                  // const UICSpacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: !widget.data.pos1up ? null : () async {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.confirmRotary);
                      // timecontrol.configurePreset1(18, TCPresetOption.startTeachin);
                      Navigator.of(context).pushNamed(TCSetupStep4.path);
                    },
                    child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
class TCSetupStep4 extends StatefulWidget {
  static const String path = "step-4";
  final TCSetupData data;
  final bool standalone;

  const TCSetupStep4({
    super.key,
    required this.data,
    this.standalone = false
  });

  @override
  State<TCSetupStep4> createState() => _TCSetupStep4State();
}

class _TCSetupStep4State extends State<TCSetupStep4> {

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            children: [
              const UICSpacer(),

              if(!widget.standalone) Center(
                child: Text("Obere Endlage".i18n, style: Theme.of(context).textTheme.titleLarge)
              ),

              const UICSpacer(),

              if(widget.data.operationMode == TCOperationModeType.Shutter) Text("Fahren Sie Ihren Rollladen oder Screen in die obere Endlage und drücken Sie anschließend auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Venetian) Text("Fahren Sie Ihre Jalousie in die obere Endlage und drücken Sie anschließend auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Awning) Text("Fahren Sie Ihre Markise in komplett geschlossene Position (eingefahren) und drücken Sie anschließend auf \"Weiter\".".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              UICBigMove(
                onStop: () {},
                onUp: () {
                  widget.data.pos1up = true;
                  timecontrol.moveToPosition(0, TCClockChannel.wired);
                },
                onDown: () {timecontrol.moveToPosition(1, TCClockChannel.wired);},
                onRelease: () {
                  timecontrol.moveStop(TCClockChannel.wired);
                  setState(() {});
                },
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!widget.standalone) TextButton(
                    onPressed: () {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.abort);
                      Navigator.of(context).pop();
                    },
                    child: Text("Zurück".i18n),
                  ),

                  Expanded(child: Container()),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: !widget.data.pos1up ? null : () async {
                      timecontrol.learn(TCClockChannel.wired, TCLearn.confirmUpper);
                      // timecontrol.configurePreset1(18, TCPresetOption.startTeachin);
                      Navigator.of(context).pushNamed(TCSetupStep5.path);
                    },
                    child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class TCSetupStep5 extends StatefulWidget {
  static const String path = "step-5";
  final TCSetupData data;
  final bool standalone;
  final String link;

  const TCSetupStep5({super.key, required this.data, this.standalone = false, this.link = TCSetupStep6.path});

  @override
  State<TCSetupStep5> createState() => _TCSetupStep5State();
}
class _TCSetupStep5State extends State<TCSetupStep5> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            children: [
              const UICSpacer(),

              if(!widget.standalone) Center(
                child: Text("Zwischenpositionen".i18n, style: Theme.of(context).textTheme.titleLarge)
              ),

              const UICSpacer(),

              if(widget.data.operationMode == TCOperationModeType.Shutter) Text("Fahren Sie Ihren Rollladen oder Screen in die gewünschte Beschattungsposition / Zwischenposition 2 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Venetian) Text("Fahren Sie Ihre Jalousie in die gewünschte Beschattungsposition / Zwischenposition 2 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Awning) Text("Fahren Sie Ihre Markise in die gewünschte Beschattungsposition / Zwischenposition 2 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              UICBigMove(
                onStop: () {},
                onUp: () {
                  widget.data.pos1dn = true;
                  timecontrol.moveUp(TCClockChannel.wired);
                },
                onDown: () {
                  widget.data.pos1dn = true;
                  timecontrol.moveDown(TCClockChannel.wired);
                },
                onRelease: () {
                  timecontrol.moveStop(TCClockChannel.wired);
                  setState(() {});
                },
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Zurück".i18n),
                  ),

                  Expanded(child: Container()),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TCSetupStep7.path);
                    },
                    child: Text("Später".i18n),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: !widget.data.pos1dn ? null : () {
                      if(widget.data.operationMode == TCOperationModeType.Venetian) {
                        timecontrol.configurePreset(TCClockChannel.wired, 2, 1);
                      } else {
                        timecontrol.configurePreset(TCClockChannel.wired, 2, 1);
                      }
                      Navigator.of(context).pushNamed(widget.link);
                    },
                    child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class TCSetupStep6 extends StatefulWidget {
  static const String path = "step-6";
  final TCSetupData data;
  final bool standalone;
  final String link;

  const TCSetupStep6({super.key, required this.data, this.standalone = false, this.link = TCSetupStep7.path});

  @override
  State<TCSetupStep6> createState() => _TCSetupStep6State();
}

class _TCSetupStep6State extends State<TCSetupStep6> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return TCSetupContentWrap(
          child: Column(
            children: [
              const UICSpacer(),

              if(!widget.standalone) 
                  Center(
                    child: Text("Zwischenpositionen".i18n, style: Theme.of(context).textTheme.titleLarge)
                    ),

              const UICSpacer(),

              if(widget.data.operationMode == TCOperationModeType.Shutter) Text("Fahren Sie Ihren Rollladen oder Screen jetzt in die gewünschte Lüftungsposition / Zwischenposition 1 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Venetian) Text("Fahren Sie Ihre Jalousie jetzt in die gewünschte Lüftungsposition / Zwischenposition 1 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center)
              else if(widget.data.operationMode == TCOperationModeType.Awning) Text("Fahren Sie Ihre Markise jetzt in die gewünschte Lüftungsposition / Zwischenposition 1 und drücken Sie auf \"Weiter\".".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              UICBigMove(
                onStop: () {},
                onUp: () {
                  widget.data.pos2up = true;
                  timecontrol.moveUp(TCClockChannel.wired);
                },
                onDown: () {
                  widget.data.pos2up = true;
                  timecontrol.moveDown(TCClockChannel.wired);
                },
                onRelease: () {
                  setState(() {});
                  timecontrol.moveStop(TCClockChannel.wired);
                },
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Zurück".i18n),
                  ),

                  Expanded(child: Container()),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TCSetupStep7.path);
                    },
                    child: Text("Später".i18n),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: !widget.data.pos2up ? null : () {
                      timecontrol.configurePreset(TCClockChannel.wired, 1, 1);
                      Navigator.of(context).pushNamed(widget.link);
                    },
                    child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class TCSetupStep7 extends StatefulWidget {
  static const String path = "step-7";
  final TCSetupData data;
  const TCSetupStep7({super.key, required this.data});

  @override
  State<TCSetupStep7> createState() => _TCSetupStep7State();
}

class _TCSetupStep7State extends State<TCSetupStep7> {
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  bool loading = false;
  bool locationRequest = false;
  bool locationDenied = false;

  Future<void> finish ({
    required TCOperationModeType mode,
    TCPresets? preset
  }) async {
    setState(() => loading = true);

    if(preset != null) {
      widget.data.clocks = await timecontrol.preset(mode: mode, preset: preset);
    } else {
      widget.data.clocks.clear();
    }

    await timecontrol.setTimeProg(widget.data.clocks);

    setState(() => loading = false);

    if(mounted) {
      Navigator.of(context).pushNamed(TCSetupStep8.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {

        if(loading == true) {
          return TCSetupContentWrap(
            child: Column(
              children: [
                const UICSpacer(),

                Center(
                  child: Text("Voreinstellung".i18n, style: Theme.of(context).textTheme.titleLarge)
                ),

                Expanded(child: Container()),

                const Center(child: UICProgressIndicator()),

                const UICSpacer(),

                Text("Einstellungen werden übertragen.".i18n),

                Expanded(child: Container())
              ],
            ),
          );
        }

        return TCSetupContentWrap(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const UICSpacer(),

              Center(
                child: Text("Voreinstellung".i18n, style: Theme.of(context).textTheme.titleLarge)
              ),

              const UICSpacer(),

              Text("Verwenden Sie eine der angebotenen Automatisierungsvorlagen oder konfigurieren Sie diese später individuell.".i18n, textAlign: TextAlign.center),

              Expanded(child: Container()),

              if(widget.data.operationMode == TCOperationModeType.Awning) Column(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () => finish(mode: widget.data.operationMode, preset: TCPresets.awningShade),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(BeckerIcons.weather_sun, size: 32),
                            const UICSpacer(),
                            Text("Beschattungsautomatik".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                          ],
                        ),
                      )
                    ),
                  ),

                  const UICSpacer(),

                  Center(
                    child: TextButton(
                      onPressed: () => finish(mode: widget.data.operationMode, preset: TCPresets.awningPermanent),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(BeckerIcons.weather_dark_cloud, size: 32),
                            const UICSpacer(),
                            Text("Dauerbeschattung".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                          ],
                        ),
                      )
                    ),
                  ),
                ],
              ),

              if(widget.data.operationMode == TCOperationModeType.Shutter || widget.data.operationMode == TCOperationModeType.Venetian) Column(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () => finish(mode: widget.data.operationMode, preset: TCPresets.shutterLiving),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.living_rounded, size: 32),
                            const UICSpacer(),
                            Text("Wohnraum".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                          ],
                        ),
                      )
                    ),
                  ),

                  const UICSpacer(),

                  Center(
                    child: TextButton(
                      onPressed: () => finish(mode: widget.data.operationMode, preset: TCPresets.shutterSleeping),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bed, size: 32),
                            const UICSpacer(),
                            Text("Schlafraum".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                          ],
                        ),
                      )
                    ),
                  ),

                  const UICSpacer(),

                  Center(
                    child: TextButton(
                      onPressed: () => finish(mode: widget.data.operationMode, preset: TCPresets.shutterAstro),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sunny, size: 32),
                            const UICSpacer(),
                            Text("Astrofunktion".i18n, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary))
                          ],
                        ),
                      )
                    ),
                  ),
                ],
              ),

              Expanded(child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Zurück".i18n),
                  ),
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await timecontrol.clearTimeProg();
                      navigator.pushNamed(TCSetupStep8.path);
                    },
                    // onPressed: () => finish(mode: widget.data.operationMode),
                    child: Text("Später".i18n),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class TCSetupStep8 extends StatefulWidget {
  static const String path = "step-8";
  final TCSetupData data;

  const TCSetupStep8({super.key, required this.data});

  @override
  State<TCSetupStep8> createState() => _TCSetupStep8State();
}

class _TCSetupStep8State extends State<TCSetupStep8> {
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  final TCAstroCalculator astroCalculator = TCAstroCalculator();

  bool loading = false;
  bool requestingAppSettings = false;
  bool locationRequestFailed = false;

  // @override
  // initState() {
  //   LifecycleService().addListener(onLifecycleStateChange);
  //   super.initState();
  // }

  // Future<void> onLifecycleStateChange () async {
  //   if(!mounted) return;
  //   if(LifecycleService().state == AppLifecycleState.resumed && requestingAppSettings == true) {
  //     requestingAppSettings = false;
  //     updateAstroTable();
  //   }
  // }

  Future<void> requestAppSettings () async {
    setState(() {
      requestingAppSettings = true;
      loading = false;
    });
  }

  Future<void> openAppSettings () async {
    await Geolocator.openLocationSettings();
  }

  Future<void> updateAstroTable([double? lat, double? lon]) async {
    if(lat == null || lon == null) {
      setState(() {
        loading = true;
        locationRequestFailed = false;
      });

      if (await Geolocator.isLocationServiceEnabled() == false) {
        setState(() {
          requestingAppSettings = true;
          loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if(permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else if(permission == LocationPermission.deniedForever) {
        setState(() {
          requestingAppSettings = true;
          loading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();

      if(permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        updateAstroTable();
        return;
      }
    }

    Position? geoLocation;
    try {
      geoLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10)
        ),
      );
    } catch(e) {
      if(lat == null || lon == null) {
        setState(() {
          loading = false;
          locationRequestFailed = true;
        });
      }
      return;
    }
    try {
      if(lat != null && lon != null) {
        geoLocation = Position(
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          speedAccuracy: 0,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          timestamp: DateTime.now(),
          latitude: lat,
          longitude: lon
        );
      }
      final enableSummerTime = await timecontrol.getSummerTime();
      final astro = await astroCalculator.updateTable(geoLocation, enableSummerTime);
      await timecontrol.setAstroTableSunrise(astro.$1);
      await timecontrol.setAstroTableSunset(astro.$2);
      await timecontrol.setAstroOffset(astro.$3);

    } catch(e) {
      dev.log("Astro update failed: $e");
    }

    if(lat == null || lon == null) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(loading == true) {
      return TCSetupContentWrap(
        child: Column(
          children: [
            const UICSpacer(),

            Center(
              child: Text("Astro & Standort".i18n, style: Theme.of(context).textTheme.titleLarge)
            ),

            Expanded(child: Container()),

            const Center(child: UICProgressIndicator()),

            const UICSpacer(),

            Text("Einstellungen werden übertragen.".i18n),

            Expanded(child: Container())
          ],
        ),
      );
    }


    return TCSetupContentWrap(
      child: Column(
        children: [
          const UICSpacer(),

          Center(
            child: Text("Astro & Standort".i18n, style: Theme.of(context).textTheme.titleLarge)
          ),

          Expanded(child:
            Icon(Icons.wb_twilight_rounded, size: 128, color: Theme.of(context).brightness == Brightness.light ? Colors.orange : Colors.yellow,),
          ),

          const UICSpacer(),

          if(locationRequestFailed) Text("Ihr Standort konnte nicht ermittelt werden. Stellen Sie sicher, dass Ihr Telefon über aktives GPS oder WLAN verfügt.".i18n, textAlign: TextAlign.center)
          else Text("Zur Berechnung der Astro-Funktion benötigt die App einmalig Zugriff auf Ihren Standort.".i18n, textAlign: TextAlign.center),

          const UICSpacer(),

          if(requestingAppSettings) ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: openAppSettings,
            child: Text("Einstellungen öffnen".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary))
          ),

          if(locationRequestFailed) ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: updateAstroTable,
            child: Text("Wiederholen".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary))
          ),

          Expanded(child: Container()),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Zurück".i18n),
              ),

              Expanded(child: Container()),

              TextButton(
                onPressed: () {
                  // Kassel
                  // Latitude	51.312801
                  // Longitude	9.481544
                  updateAstroTable(51.312801, 9.481544); // lat / lon für Sinn
                  Navigator.of(context).pushNamed(TCSetupStep9.path);
                },
                child: Text("Später".i18n),
              ),

              const UICSpacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: requestingAppSettings == true ? null : () async {
                  await updateAstroTable();
                  if(context.mounted) {
                    Navigator.of(context).pushNamed(TCSetupStep9.path);
                  }
                },
                child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TCSetupStep9 extends StatelessWidget {
  static const String path = "step-9";
  final TCSetupData data;
  final bool standalone; /// Wether this step is standalone (single page) or part of a larger setup process

  const TCSetupStep9({
    super.key,
    required this.data,
    this.standalone = false
  });

  @override
  Widget build(BuildContext context) {
    return TCSetupContentWrap(
      child: Column(
        children: [
          const UICSpacer(),

          Row(
            children: [
              Expanded(child: Container()),
              Text("Einrichtung abgeschlossen".i18n, style: Theme.of(context).textTheme.titleLarge),
              Expanded(child: Container()),
            ],
          ),

          if(standalone) const UICSpacer(2),

          if(!standalone) Expanded(child: Container()),

          const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 128),

          const UICSpacer(),

          if(!standalone)
          Text("Die Inbetriebnahme ist abgeschlossen und Ihre Steuerung ist eingerichtet. Anpassungen können Sie später jederzeit im entsprechenden Menüpunkt vornehmen.".i18n, textAlign: TextAlign.center),
          if(standalone)
          Text("Die Zwischenpositionen sind eingerichtet. Anpassungen können Sie später jederzeit im entsprechenden Menüpunkt vornehmen.".i18n, textAlign: TextAlign.center),

          Expanded(child: Container()),

          if(!standalone) Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  final messenger = UICMessenger.of(context);
                  final timecontrol = Provider.of<Timecontrol>(context, listen: false);
                  timecontrol.operationMode.setupComplete = true;
                  await timecontrol.setOperationMode();

                  data.complete = true;
                  messenger.pop(data);
                },
                child: Text("Fertig".i18n, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
