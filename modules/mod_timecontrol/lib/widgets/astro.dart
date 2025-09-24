part of '../module.dart';

class AstroView extends StatefulWidget {
  final List<AstroTableEntry> astroTable;
  final TCAstroOffsetParam astroOffset;
  final TCOperationModeParam operationMode;
  
  const AstroView({
    super.key, 
    required this.astroTable,
    required this.astroOffset,
    required this.operationMode
  });

  @override
  State<AstroView> createState() => _AstroViewState();
}

class _AstroViewState extends State<AstroView> {
  late final timecontrol               = Provider.of<Timecontrol>(context, listen: false);
  final DateTime now                   = DateTime.now();
  
  late final DateTime yearFirstDayUTC  = DateTime.utc(now.year, 1, 1, 0, 0);
  late final firstOfNextYearUTC        = DateTime.utc(now.year + 1, 1, 1, 0, 0);
  late final yearDuration              = firstOfNextYearUTC.difference(yearFirstDayUTC);
  late final DateTime yearFirstDay     = DateTime(DateTime.now().year, 1, 1, 0, 0);
  late final timezoneOffset            = Duration(hours: yearFirstDay.timeZoneOffset.inHours);

  Offset mouseOffset                   = const Offset(0, 0);
  bool mouseDown                       = true;
  TCOperationModeParam operationMode   = TCOperationModeParam();

  

  AstroTableEntry? mouseResult;

  @override
  void initState() {
    initializeDateFormatting();
    asyncInit();
    super.initState();
  }

  Future<void> asyncInit () async {
    operationMode = await timecontrol.getOperationMode() ?? TCOperationModeParam();
    setState(() {});
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  didUpdateWidget (AstroView oldWidget) {
    super.didUpdateWidget(oldWidget);
    asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    if(mouseResult == null && widget.astroTable.isNotEmpty){
      mouseResult = widget.astroTable[0];
      mouseOffset = const Offset(0,0);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageIcon(
                    const AssetImage("assets/icons/sunrise.png"),
                    size: 32,
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  ),
                  const Icon(Icons.arrow_downward_rounded),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.cyan.withAlpha((255 * 0.5).toInt()),
                              borderRadius: BorderRadius.circular(3)
                            ),
                          ),
                          const SizedBox(width: 5),

                          if(operationMode.amTimeDisplay == true)
                            Text("Sonnenuntergang (%s)".i18n.fill([DateFormat("hh:mm a").format(mouseResult?.sunset.subtract(timezoneOffset).toLocal() ?? DateTime.now())]))
                          else
                            Text("Sonnenuntergang (%s Uhr)".i18n.fill([DateFormat('HH:mm').format(mouseResult?.sunset.subtract(timezoneOffset).toLocal() ?? DateTime.now())])),
                        ],
                      ),
                    ],
                  )
                ],
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: 260,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onHorizontalDragEnd: (_) {
                              mouseDown = true;
                            },
                            onHorizontalDragCancel: () {
                              mouseDown = true;
                            },
                            onHorizontalDragStart: (data) {},
                            onHorizontalDragUpdate: (data) {
                              mouseDown = true;
                              mouseOffset = Offset(data.localPosition.dx / constraints.maxWidth, data.localPosition.dy / 260);
                              final selectedDate = yearFirstDayUTC.add(Duration(minutes: (yearDuration.inMinutes * (mouseOffset.dx)).toInt()));
                              final day = min(max(selectedDate.difference(yearFirstDayUTC).inDays, 0), 365);
                              mouseResult = widget.astroTable[day];
                              setState(() { });
                            },
                            child: CustomPaint(
                              painter: _AstroCurvePainter(
                                astroTable: widget.astroTable.sublist(0, 365),
                                mouseDate: mouseResult,
                                mouseDown: mouseDown,
                                mousePosition: mouseOffset,
                                enableSunrise: true, // widget.operationMode.astroMorning,
                                enableSunset: true, // widget.operationMode.astroEvening,
                                colorSunrise: Colors.orange,
                                colorSunset: Colors.cyan,
                              ),
                            ),
                          ),
                        ),


                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Jan.".i18n),
                              Text("Sommerzeit".i18n),
                              Text("Dez.".i18n)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageIcon(
                    const AssetImage("assets/icons/sunrise.png"),
                    size: 32,
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  ),
                  const Icon(Icons.arrow_upward_rounded),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha((255 * 0.5).toInt()),
                              borderRadius: BorderRadius.circular(3)
                            ),
                          ),
                          const SizedBox(width: 5),

                          if(operationMode.amTimeDisplay == true)
                            Text("Sonnenaufgang (%s)".i18n.fill([DateFormat("hh:mm a").format(mouseResult?.sunrise.subtract(timezoneOffset).toLocal() ?? DateTime.now())]))
                          else
                            Text("Sonnenaufgang (%s Uhr)".i18n.fill([DateFormat('HH:mm').format(mouseResult?.sunrise.subtract(timezoneOffset).toLocal() ?? DateTime.now())])),

                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _AstroCurvePainter extends CustomPainter {
  final bool enableSunrise;
  final bool enableSunset;

  late Size _size;
  List<AstroTableEntry> astroTable;
  final dayHours = 24 * 60;
  final double height60Minutes = 60 / (24 * 60);
  final Color colorSunset;
  final Color colorSunrise;

  final Offset mousePosition;
  final bool mouseDown;
  final AstroTableEntry? mouseDate;

  Paint gridPaint = Paint()
    ..color = Colors.grey.withAlpha((255 * 0.2).toInt())
    ..style = PaintingStyle.stroke;

  Paint summertimePaint = Paint()
    ..color = Colors.yellow.withAlpha((255 * 1).toInt())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;


  Canvas? canvas;

  _AstroCurvePainter({
    required this.astroTable,
    required this.colorSunrise,
    required this.colorSunset,
    required this.enableSunset,
    required this.enableSunrise,
    required this.mousePosition,
    required this.mouseDown,
    required this.mouseDate
  });

  @override
  void paint(Canvas paintCanvas, Size s) {
    canvas = paintCanvas;
    _size = s;
  
    Path dayTime = Path();

    var dayTimePaint = Paint()
      ..color = Colors.yellow.withAlpha((255 * 0.1).toInt())
      ..style = PaintingStyle.fill;

    canvas?.drawRect(Offset(
      0, _size.height - 1,
    ) & Size(_size.width, 1), gridPaint);


    for(int i = 0; i < 24; i++) {
      final line = Path();
      line.moveTo(0, i / 24 * _size.height);
      line.lineTo(_size.width, i / 24 * _size.height);
      canvas?.drawPath(line, gridPaint);
    }

    List<Offset> sunrise = drawSunriseSunset(0, 0);


    dayTime.moveTo(sunrise.first.dx, sunrise.first.dy);
    for(final point in sunrise) {
      dayTime.lineTo(point.dx, point.dy);
    }
    dayTime.close();
    canvas?.drawPath(dayTime, dayTimePaint);

    drawMouseIndicator();
  }

  drawMouseIndicator() {
    if(mouseDown) {
      Path mouseIndicator = Path();
      Paint paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      Paint fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      mouseIndicator.moveTo(max(min(mousePosition.dx * _size.width, _size.width), 0), 0);
      mouseIndicator.lineTo(max(min(mousePosition.dx * _size.width, _size.width), 0), _size.height);
      
      if(mouseDate != null) {
        double padding = 10;

        const textStyle = TextStyle(
          color: Colors.black,
          fontSize: 14,
        );

        final textSpan = TextSpan(
          text: DateFormat("dd.MMM", Localization.locale).format(mouseDate!.sunrise),
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(
          minWidth: 0,
        );

        if(mousePosition.dx > 0.5) {
          /// Text fits to left side of indicator bar
          final offset = Offset(max(min(mousePosition.dx * _size.width - textPainter.width - padding, _size.width - textPainter.width - padding), 0), padding);
          canvas?.drawRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: offset + Offset(textPainter.width / 2, padding), width: textPainter.width + padding * 2, height: textPainter.height + padding * 2),
            const Radius.circular(10)
          ), fillPaint);
          textPainter.paint(canvas!, offset);
        } else {
          /// Text fits to right side of indicator bar
          final offset = Offset(max(min(mousePosition.dx * _size.width + padding, _size.width), .0 + padding), padding);
          canvas?.drawRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: offset + Offset(textPainter.width / 2, padding), width: textPainter.width + padding * 2, height: textPainter.height + padding * 2),
            const Radius.circular(10)
          ), fillPaint);
          textPainter.paint(canvas!, offset);
        }
      }

      canvas?.drawPath(mouseIndicator, paint);
    }
  }

  List<Offset> drawSunriseSunset (double offsetSunrise, double offsetSunset) {
    final summertimeStartLine = Path();

    Path sunrisePath = Path();
    Path sunsetPath = Path();

    Paint sunrisePaint = Paint()
      ..color = colorSunrise.withAlpha((255 * offsetSunrise.abs() > 0 ? 1 : .5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    Paint sunsetPaint = Paint()
      ..color = colorSunset.withAlpha((255 * offsetSunset.abs() > 0 ? 1 : .5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    List<Offset> sunset = [];
    List<Offset> sunrise = [];
    int lastMonth = 0;

    sunrisePath.moveTo(0, _size.height * astroTable.first.curveSunrise.dy + (offsetSunrise * _size.height));
    sunsetPath.moveTo(0, _size.height * astroTable.first.curveSunset.dy + (offsetSunset * _size.height));

    for(int i = 0; i < astroTable.length; i++) {
      final day = astroTable[i];

      if(lastMonth != day.sunrise.month) {
        final line = Path();
        line.moveTo(day.curveSunrise.dx * _size.width, 0);
        line.lineTo(day.curveSunrise.dx * _size.width, _size.height);
        canvas?.drawPath(line, gridPaint);
      }

      sunrise.add(Offset(
        day.curveSunrise.dx * _size.width,
        day.daylightSaving
          ? (_size.height * (day.curveSunrise.dy - height60Minutes)) + (offsetSunrise * _size.height)
          : _size.height * day.curveSunrise.dy  + (offsetSunrise * _size.height),
      ));

      sunset.add(Offset(
        day.curveSunset.dx * _size.width,
        day.daylightSaving
          ? _size.height * (day.curveSunset.dy - height60Minutes) + (offsetSunset * _size.height)
          : _size.height * day.curveSunset.dy + (offsetSunset * _size.height),
      ));

      sunrisePath.lineTo(
        sunrise.last.dx,
        sunrise.last.dy
      );

      sunsetPath.lineTo(
        sunset.last.dx,
        sunset.last.dy
      );

      if(i < astroTable.length - 1) {
        if(day.daylightSaving != astroTable[i + 1].daylightSaving) {
          summertimeStartLine.moveTo(day.curveSunrise.dx * _size.width, 0);
          summertimeStartLine.lineTo(day.curveSunrise.dx * _size.width, _size.height);

          sunrise.add(Offset(
            _size.width * day.curveSunrise.dx,
            astroTable[i + 1].daylightSaving
              ? _size.height * (day.curveSunrise.dy - height60Minutes) + (offsetSunrise * _size.height)
              : _size.height * day.curveSunrise.dy + (offsetSunrise * _size.height),
          ));

          sunset.add(Offset(
            _size.width * day.curveSunset.dx,
            astroTable[i + 1].daylightSaving
              ? _size.height * (day.curveSunset.dy - height60Minutes) + (offsetSunset * _size.height)
              : _size.height * day.curveSunset.dy + (offsetSunset * _size.height),
          ));

          sunrisePath.lineTo(
            sunrise.last.dx,
            sunrise.last.dy
          );

          sunsetPath.lineTo(
            sunset.last.dx,
            sunset.last.dy
          );
        }
      }

      lastMonth = day.sunrise.month;
    }
    
    canvas?.drawPath(sunrisePath, sunrisePaint);
    canvas?.drawPath(sunsetPath, sunsetPaint);
    canvas?.drawPath(summertimeStartLine, summertimePaint);

    sunrise.addAll(sunset.reversed);
    return sunrise;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
