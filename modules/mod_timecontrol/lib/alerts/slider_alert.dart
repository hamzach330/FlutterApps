part of '../module.dart';

class TimecontrolSliderAlert extends UICAlert<(double?, double?)> {
  final double? position;
  final double? slat;
  
  TimecontrolSliderAlert({
    super.key,
    this.position,
    this.slat,
  });
  
  @override
  get title => "Position".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 460;

  @override
  get backdrop => true;

  @override
  get dismissable => true;
  
  @override
  Widget build(BuildContext context) {
    return _TimecontrolSliderAlert(
      position: position,
      slat: slat
    );
  }
}

class _TimecontrolSliderAlert extends StatefulWidget {
  final double? position;
  final double? slat;
  
  const _TimecontrolSliderAlert({
    this.position,
    this.slat
  });
  
  @override
  _TimecontrolSliderAlertState createState() => _TimecontrolSliderAlertState();
}

class _TimecontrolSliderAlertState extends State<_TimecontrolSliderAlert> {
  double position = 0;
  double slat = 0;

  bool _enablePosition = false;
  bool _enableSlat = false;
  
  @override
  void initState() {
    super.initState();
    if(widget.slat != null) {
      _enableSlat = true;
    }

    if(widget.position != null) {
      _enablePosition = true;
    }

    position = widget.position ?? 0.0;
    slat = widget.slat ?? 0.0;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: theme.defaultWhiteSpace,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(_enablePosition) Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Position (Prozent)".i18n),
            Text("${position.toInt()}%"),
          ],
        ),
        if(_enablePosition) Row(
          children: [
            const Text("0%"),
            Flexible(
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: EdgeToEdgeTrackShape(),
                ),
                child: Slider(
                  min: 0,
                  max: 100,
                  value: position,
                  onChanged: (v) {
                    position = v;
                    setState(() {});
                  }
                ),
              ),
            ),
            const Text("100%"),
          ],
        ),

        if(_enableSlat) Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Wendung (Prozent)".i18n),
            Text("${slat.toInt()}%"),
          ],
        ),
        if(_enableSlat) Row(
          children: [
            const Text("0%"),
            Flexible(
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: EdgeToEdgeTrackShape(),
                ),
                child: Slider(
                  min: 0,
                  max: 100,
                  value: slat,
                  onChanged: (v) {
                    slat = v;
                    setState(() {});
                  }
                ),
              ),
            ),
            const Text("100%"),
          ],
        ),

        const UICSpacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UICElevatedButton(
              style: UICColorScheme.error,
              child: Text("Abbrechen".i18n),
              onPressed: () {
                Navigator.of(context).pop();
              }
            ),

            UICElevatedButton(
              style: UICColorScheme.success,
              child: Text("Übernehmen".i18n),
              onPressed: () {
                Navigator.of(context).pop((position, slat));
              }
            ),
          ],
        ),
        
      ],
    );
  }
}