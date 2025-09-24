part of '../module.dart';

class CPChannelSelector extends StatefulWidget {
  final List<Color> gradient;
  final bool repeat;
  final int segment;

  const CPChannelSelector({
    super.key,
    this.gradient = const [Colors.red, Colors.blue, Colors.green, Colors.red],
    this.segment = 0,
    this.repeat = true
  });

  @override
  State<CPChannelSelector> createState() => _CPChannelSelectorState();
}

class _CPChannelSelectorState extends State<CPChannelSelector> with SingleTickerProviderStateMixin {
  final double width = 80;
  final ratio = 18.5 / 8;
  final circleWidth = 8.0;
  final Color buttonColor  = const Color.fromARGB(255, 111, 111, 111);
  final Color dividerColor = const Color.fromARGB(255, 60, 60, 60);
  final deg360 = pi * 2;

  late AnimationController controller;
  late final double height;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if(widget.repeat) {
      controller.repeat();
    } else {
      // controller.forward();
    }

    height = width * ratio;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CPChannelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget != widget) {
      // controller.reset();

      if(widget.repeat) {
        controller.repeat();
      } else {
        // print("ANIMATE TO: ${1 / 4 * widget.segment}");
        controller.stop();
        controller.animateTo(1 / 4 * widget.segment, curve: Curves.easeInOutCubic);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width / 2),
            gradient: SweepGradient(
              center: FractionalOffset.center,
              transform: GradientRotation(radians(controller.value * 360)),
              // transform: GradientRotation(deg360 / 8 * 2),
              colors: widget.gradient,
              stops: [
                for(var i = 0; i < widget.gradient.length; i++)
                  i / (widget.gradient.length - 1),
              ],
            ),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: buttonColor, width: 2),
            borderRadius: BorderRadius.circular(width / 2),
          ),
          width: width,
          height: height,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(circleWidth),
              ),
        
              Positioned(
                top: 0,
                right: 0,
                bottom: height / 2,
                left: width / 2,
                child: Container(color: Colors.transparent)
              ),
        
              Container(
                clipBehavior: Clip.hardEdge,
                margin: EdgeInsets.all(circleWidth),
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(width / 2),
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border.all(color: buttonColor, width: 2),
                  borderRadius: BorderRadius.circular(width / 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        color: buttonColor,
                        child: CustomPaint(
                          painter: _DrawUp(color: Colors.white, scale: 0.6,),
                        ),
                      ),
                    ),
                    Container(
                      height: 3,
                    ),
                    Expanded(
                      child: Container(
                        color: buttonColor,
                        child: CustomPaint(
                          painter: _DrawStop(color: Colors.white, scale: 0.6,),
                        ),
                      ),
                    ),
                    Container(
                      height: 3,
                    ),
                    Expanded(
                      child: Container(
                        color: buttonColor,
                        child: CustomPaint(
                          painter: _DrawDown(color: Colors.white, scale: 0.6,),
                        ),
                      ),
                    )
                  ]
                )
              ),
            ],
          )
        );
      }
    );
  }
}

class _DrawStop extends CustomPainter {
  final Paint _paint;
  final double strokeWidth;
  final Color color;
  final double scale;

  _DrawStop({
    this.strokeWidth = 2,
    this.color = Colors.white,
    this.scale = 1
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Rect.fromPoints(const Offset(0,0), Offset(40 * scale, 36 * scale));
    canvas.drawRect(path.shift(Offset(
      (size.width - path.width) / 2,
      (size.height - path.height) / 2
    )), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


class _DrawUp extends CustomPainter {
  final Paint _paint;
  final double strokeWidth;
  final Color color;
  final double scale;

  _DrawUp({
    this.strokeWidth = 2,
    this.color = Colors.white,
    this.scale = 1,
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    
    path.moveTo(20 * scale, 0);
    path.lineTo(40 * scale, 31 * scale);
    path.lineTo(0, 31 * scale);

    path.close();

    canvas.drawPath(path.shift(Offset(
      (size.width - 40) / 2 * scale,
      (size.height - 31) / 2 / scale
    )), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


class _DrawDown extends CustomPainter {
  final Paint _paint;
  final double strokeWidth;
  final Color color;
  final double scale;

  _DrawDown({
    this.strokeWidth = 2,
    this.color = Colors.white,
    this.scale = 1,
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    
    path.moveTo(0, 0);
    path.lineTo(40 * scale, 0);
    path.lineTo(20 * scale, 31 * scale);

    path.close();
    canvas.drawPath(path.shift(Offset(
      (size.width - 40) / 2 * scale,
      (size.height - 31) / 2 / scale
    )), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}