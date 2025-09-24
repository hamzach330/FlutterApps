part of '../module.dart';

class TimecontrolLocationEnsurer extends StatefulWidget {
  final bool enableSummerTime;
  
  const TimecontrolLocationEnsurer({
    super.key,
    required this.enableSummerTime
  });

  @override
  createState() => TimecontrolLocationEnsurerState();
}

class TimecontrolLocationEnsurerState extends State<TimecontrolLocationEnsurer> {
  late final timecontrol = Provider.of<Timecontrol>(context, listen: false);
  final TCAstroCalculator astroCalculator = TCAstroCalculator();
  TCAstroOffsetParam astroOffset          = TCAstroOffsetParam();
  List<AstroTableEntry> astroTable        = [];
  bool loading                            = true;
  bool gettingPosition                    = false;
  bool getPositionError                   = false;

  Position? geoLocation;

  List<int> astroSunrise = [];
  List<int> astroSunset = [];

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  @override
  void didUpdateWidget (oldWidget) {
    updateView();
    super.didUpdateWidget(oldWidget);
  }

  Future<void> asyncInit() async {
    setState(() {loading = false;});
    await getPosition();
    if(geoLocation == null) return;

    setState(() {loading = true;});

    astroOffset   = await timecontrol.getAstroOffset() ?? TCAstroOffsetParam();

    astroSunrise  = await timecontrol.getAstroTableSunrise();
    astroSunset   = await timecontrol.getAstroTableSunset();
    loading = false;
    await updateView();
    return;
  }

  updateView () async {
    if(astroSunrise.isNotEmpty && astroSunset.isNotEmpty) {
      astroTable = astroCalculator.getAstroTableFromOffsets(
        sunrise: astroSunrise,
        sunset: astroSunset,
        sunriseBaseHours: astroOffset.startTimeUp.hour,
        sunriseBaseMinutes: astroOffset.startTimeUp.minute,
        sunsetBaseHours: astroOffset.startTimeDown.hour,
        sunsetBaseMinutes: astroOffset.startTimeDown.minute,
        enableSummerTime: widget.enableSummerTime
      );
    } else if(geoLocation != null) {
      astroTable = await astroCalculator.getAstroTableFromPosition(geoLocation!, widget.enableSummerTime);
      // await astroCalculator.updateTable(geoLocation!, widget.enableSummerTime);
    }

    setState(() {});
  }

  update () async {
    setState(() {
      loading = true;
    });
    await getPosition();
    if(geoLocation != null) {
      // astroTable = await astroCalculator.getAstroTableFromPosition(geoLocation!, widget.enableSummerTime);
      final astro = await astroCalculator.updateTable(geoLocation!, widget.enableSummerTime);

      await timecontrol.setAstroTableSunrise(astro.$1);
      await timecontrol.setAstroTableSunset(astro.$2);
      await timecontrol.setAstroOffset(astro.$3);
      
      astroSunrise = astro.$1;
      astroSunset = astro.$2;
      astroOffset = astro.$3;
      loading = false;
      updateView();
    }
  }

  Future<void> getPosition() async {
    gettingPosition = true;
    getPositionError = false;

    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      gettingPosition = false;
      getPositionError = true;
      setState(() {});
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        gettingPosition = false;
        getPositionError = true;
        setState(() {});
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      gettingPosition = false;
      getPositionError = true;
      setState(() {});
    }
    try {
      await Geolocator.checkPermission();
      geoLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // geoLocation = Position(
      //   latitude:	-27.494073,
      //   longitude: 153.034518,
      //   timestamp: DateTime.now(),
      //   accuracy: 0,
      //   heading: 0,
      //   speed: 0,
      //   speedAccuracy: 0,
      //   altitude: 0,
      //   floor: null,
      //   headingAccuracy: 0,
      //   isMocked: false,
      //   altitudeAccuracy: 0,
      // );

      gettingPosition = false;
      getPositionError = false;
      setState(() {});
    } catch(e) {
      gettingPosition = false;
      getPositionError = true;
      setState(() {});
    }
  }

  Future<void> saveOperationMode () async {
    await timecontrol.setOperationMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICGridTile(
      collapsed: true,
      collapsible: true,
      bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace),
      borderColor: Colors.transparent,
      title: UICGridTileTitle(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text("Astro & Standort".i18n),
      ),
      body: Column(
        children: [
          if(getPositionError) Center(child: Text("Ihr Standort konnte nicht ermittelt werden!".i18n, style: Theme.of(context).titleSmallError)),
      
          if(getPositionError) Center(child: Text("Stellen Sie sicher, dass die Ermittlung der Standortdaten aktiviert ist.".i18n, textAlign: TextAlign.center)),
      
          if(gettingPosition && getPositionError == false) Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const UICProgressIndicator(),
                const UICSpacer(),
                Center(child: Text("Ihr Standort wird ermittelt".i18n))
              ],
            ),
          ),
          
      
          if(loading) Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const UICProgressIndicator(),
              const UICSpacer(),
              Center(child: Text("Der Sonnenverlauf für Ihren Standort wird berechnet".i18n, textAlign: TextAlign.center))
            ],
          ),
      
          if(!loading && !gettingPosition && !getPositionError) Column(
            children: [
              AstroView(
                astroOffset: astroOffset,
                astroTable: astroTable,
                operationMode: timecontrol.operationMode,
              ),
      
              const SizedBox(height: 20),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FilledButtonTheme(
                    data: const FilledButtonThemeData(
                      style: ButtonStyle(
                        // backgroundColor: WidgetStatePropertyAll(Colors.green),
                        // foregroundColor: WidgetStatePropertyAll(Colors.white),
                        iconSize: WidgetStatePropertyAll(32),
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16))
                      )
                    ),
                    child: FilledButton(
                      onPressed: update,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded),
                          const SizedBox(width: 10),
                          Text("Standort ermitteln".i18n)
                        ],
                      )
                    ),
                  ),
                ],
              ),
      
              const SizedBox(height: 20),
            ],
          )
        ],
      ),
    );
  }
}
