part of ui_common;

class UICColorSlider extends StatelessWidget {
  final double sliderHeight;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final bool fullWidth;
  final List<Color> backgroundGradient;
  final void Function(double) onChange;
  final void Function(double) onChangeEnd;
  final Color altLeftColor;
  final Color altRightColor;
  final String? Function(dynamic v)? valueFormatter;
  // final CCItemPresentationSettingsDeviceSolarProtectionState config;

  UICColorSlider({
    this.sliderHeight = 48,
    this.max = 10,
    this.min = 0,
    this.value = 0,
    this.fullWidth = true,
    this.divisions = 10,
    this.backgroundGradient = const [
      Color(0xFF00c6ff),
      Color(0xFF0072ff),
    ],
    required this.onChange,
    required this.onChangeEnd,
    this.altLeftColor = Colors.white,
    this.altRightColor = Colors.white,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        width: fullWidth
            ? double.infinity
            : (sliderHeight) * 5.5,
        height: (sliderHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular((sliderHeight * .3)),
          ),
          gradient: LinearGradient(
              colors: backgroundGradient,
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.00),
              stops: const [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                valueFormatter?.call(min) ?? '${min.toInt()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sliderHeight * .3,
                  fontWeight: FontWeight.w700,
                  color: altLeftColor,
                ),
              ),
              SizedBox(
                width: sliderHeight * .1,
              ),
              Expanded(
                child: Center(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.white.withAlpha(0),
                      trackHeight: 4.0,
                      thumbShape: CustomSliderThumbCircle(
                        thumbRadius: sliderHeight * .4,
                        min: min.toInt(),
                        max: max.toInt(),
                        valueFormatter: valueFormatter,
                      ),
                      overlayColor: Colors.white.withAlpha((255 * .4).toInt()),
                      valueIndicatorColor: Colors.white,
                      activeTickMarkColor: Colors.white,
                      inactiveTickMarkColor: Colors.white.withAlpha((255 * .4).toInt()),
                    ),
                    child: Slider(
                      value: value,
                      min: min,
                      max: max,
                      divisions: divisions,
                      onChanged: (v) {
                        onChange(v);
                      },
                      onChangeEnd: (v) {
                        onChangeEnd(v);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: sliderHeight * .1,
              ),
              Text(
                valueFormatter?.call(max) ?? '${max.toInt()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sliderHeight * .3,
                  fontWeight: FontWeight.w700,
                  color: altRightColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;
  final String? Function(dynamic v)? valueFormatter;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
    this.valueFormatter,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: Colors.black
        // color: sliderTheme.activeTrackColor,
      ),
      text: getValue(value),
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    );
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter?.call(value) ?? "";
    }
    return (min + ((max - min) * value).round()).toString();
  }
}
