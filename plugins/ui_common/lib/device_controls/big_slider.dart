part of ui_common;

class UICBigSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChangeEnd;
  final ValueChanged<double>? onChanged;
  final UICTextInputLabelSide labelSide;
  final bool readOnly;
  final double width;

  const UICBigSlider({
    super.key,
    required this.value,
    required this.onChangeEnd,
    required this.onChanged,
    this.width = 110,
    this.readOnly = false,
    this.labelSide = UICTextInputLabelSide.top
  });

  @override
  State<UICBigSlider> createState() => _UICBigSliderState();
}

class _UICBigSliderState extends State<UICBigSlider> {
  late double _initialValue = widget.value;
  late double _value = widget.value;

  @override
  Widget build(BuildContext context) {
    if(widget.value != _initialValue) {
      _initialValue = widget.value;
      _value = widget.value;
    }
    
    final theme = Theme.of(context);
    const double height = 244;
    return IgnorePointer(
      ignoring: widget.readOnly,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if(widget.labelSide == UICTextInputLabelSide.top) Padding(
            padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${_value.toInt()} %")
              ],
            )
          ),
          SizedBox(
            height: height,
            width: widget.width,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.onSecondaryContainer, width: 2),
                borderRadius: BorderRadius.circular(12)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: _SliderThumb(
                        color: theme.colorScheme.onSecondaryContainer,
                        thumbRadius: 0
                      ),
                      activeTrackColor: theme.colorScheme.secondary,
                      inactiveTrackColor: theme.colorScheme.onSecondary,
                      trackHeight: widget.width,
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8.0),
                      trackShape: _SliderTrackShape(),
                    ),
                    child: Slider(
                      min: 0,
                      max: 100,
                      value: _value,
                      onChangeEnd: widget.onChangeEnd,
                      onChanged: (v) => setState(() {
                        _value = v;
                      }),
                    )
                  ),
                ),
              ),
            ),
          ),
      
          if(widget.labelSide == UICTextInputLabelSide.bottom) Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${_value.toInt()} %")
              ],
            )
          ),
        ],
      ),
    );
  }
}

class _SliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final Color color;

  const _SliderThumb({
    required this.thumbRadius,
    required this.color
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(50, 50);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center,
    {
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
    }
  ) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: 6,
        height: 30
      ),
      const Radius.circular(10),
    );

    final paint = Paint()
      // ..color = theme.data.background
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, paint);
  }
}

class _SliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true,
    bool isDiscrete = true,
  }) {
    final double thumbWidth = sliderTheme.thumbShape!.getPreferredSize(true, isDiscrete).width;
    final double trackHeight = parentBox.size.height;
    assert(thumbWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= thumbWidth);
    assert(parentBox.size.height >= trackHeight);

    const double trackLeft = 0; // offset.dx + thumbWidth / 2;
    const double trackTop = 0; // offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = true,
    bool isDiscrete = true,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final background = RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(trackRect.left - 7, trackRect.top),
        Offset(trackRect.right + 7, trackRect.bottom),
      ),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10)
    );

    final paintbackground = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.grey.shade500
      ..style = PaintingStyle.fill;
    context.canvas.drawRRect(background, paintbackground);


    final rRect = RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(trackRect.left - 7, trackRect.top),
        Offset(thumbCenter.dx + 7, trackRect.bottom),
      ),
      topLeft: const Radius.circular(0),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(0),
      bottomRight: const Radius.circular(10)
    );


    final paint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey.shade500
      ..style = PaintingStyle.fill;
    context.canvas.drawRRect(rRect, paint);

  }
}

