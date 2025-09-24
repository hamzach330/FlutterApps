part of ui_common;

class UICBigMove extends StatelessWidget {

  final void Function()? onUp;
  final void Function()? onStop;
  final void Function()? onDown;
  final void Function()? onRelease;
  final double upOpacity;
  final double stopOpacity;
  final double downOpacity;

  const UICBigMove({
    required this.onStop,
    this.onUp,
    this.onDown,
    this.onRelease,
    this.upOpacity = 1,
    this.stopOpacity = 1,
    this.downOpacity = 1,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onExit: (_) => onRelease?.call(),
      child: Container(
        width: 110,
        height: 244,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            left: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            right: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            bottom: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
          ),
          borderRadius: BorderRadius.circular(theme.defaultWhiteSpace)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if(onUp != null) SizedBox(
              height: 80,
              child: Material(
                color: theme.colorScheme.secondary.withValues(alpha: upOpacity),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.defaultWhiteSpace - 2),
                  topRight: Radius.circular(theme.defaultWhiteSpace - 2)
                ),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(theme.defaultWhiteSpace - 2)),
                  splashColor: theme.colorScheme.primary,
                  onTapDown: (_) => onUp!(),
                  onTapUp: (_) => onRelease?.call(),
                  onTapCancel: () => onRelease?.call(),
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _DrawUp(
                      color: theme.colorScheme.onSecondary
                    ),
                  ),
                ),
              )
            ),
            
            if(onStop != null) SizedBox(
              height: 80,
              child: Material(
                borderRadius: onUp == null ? BorderRadius.only(
                  topLeft: Radius.circular(theme.defaultWhiteSpace - 2),
                  topRight: Radius.circular(theme.defaultWhiteSpace - 2),
                ) : onDown == null ? BorderRadius.only(
                  bottomLeft: Radius.circular(theme.defaultWhiteSpace - 2),
                  bottomRight: Radius.circular(theme.defaultWhiteSpace - 2),
                ) : null,
                color: theme.colorScheme.secondary.withValues(alpha: stopOpacity),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(theme.defaultWhiteSpace - 2)),
                  splashColor: theme.colorScheme.primary,
                  onTapDown: (_) => onStop?.call(),
                  onTapUp: (_) => onRelease?.call(),
                  onTapCancel: () => onRelease?.call(),
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _DrawStop(
                      color: theme.colorScheme.onSecondary
                    ),
                  ),
                ),
              )
            ),
            
            if(onDown != null) SizedBox(
              height: 80,
              child: Material(
                color: theme.colorScheme.secondary.withValues(alpha: downOpacity),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(theme.defaultWhiteSpace - 2),
                  bottomRight: Radius.circular(theme.defaultWhiteSpace - 2)
                ),
                child: InkWell(
                  splashColor: theme.colorScheme.primary,
                  borderRadius: BorderRadius.all(Radius.circular(theme.defaultWhiteSpace - 2)),
                  onTapDown: (_) => onDown!(),
                  onTapUp: (_) => onRelease?.call(),
                  onTapCancel: () => onRelease?.call(),
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _DrawDown(
                      color: theme.colorScheme.onSecondary
                    ),
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}


class _DrawStop extends CustomPainter {
  final Paint _paint;
  final double strokeWidth;
  final Color color;

  _DrawStop({
    this.strokeWidth = 2,
    this.color = Colors.white
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Rect.fromPoints(const Offset(0,0), const Offset(40, 36));
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

  _DrawUp({
    this.strokeWidth = 2,
    this.color = Colors.white
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(20, 0);
    path.lineTo(40, 31);
    path.lineTo(0, 31);
    path.close();

    canvas.drawPath(
        path.shift(Offset(
          (size.width - 40) / 2,
          (size.height - 31) / 2,
        )),
        _paint);
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

  _DrawDown({
    this.strokeWidth = 2,
    this.color = Colors.white
  }): _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    
    path.moveTo(0, 0);
    path.lineTo(40, 0);
    path.lineTo(20, 31);

    path.close();
    canvas.drawPath(path.shift(Offset(
      (size.width - 40) / 2,
      (size.height - 31) / 2
    )), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}