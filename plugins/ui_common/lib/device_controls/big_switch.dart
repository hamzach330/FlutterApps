part of ui_common;

class UICBigSwitch extends StatelessWidget {
  final Function() switchOn;
  final Function()? switchOff;
  final bool? state;

  const UICBigSwitch({
    required this.switchOn,
    this.switchOff,
    this.state,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          border: Border(
            top: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            left: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            right: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
            bottom: BorderSide(width: 2, color: theme.colorScheme.onSecondaryContainer),
          ),
          borderRadius: BorderRadius.circular(80)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              width: 80,
              height: 100,
              child: Material(
                color: state == true ? theme.colorScheme.successVariant.primaryContainer : theme.colorScheme.secondary,
                borderRadius: BorderRadius.all(Radius.circular(80)),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                  splashColor: theme.colorScheme.primary,
                  onTap: switchOn,
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: state == true ? theme.colorScheme.successVariant.onPrimaryContainer : theme.colorScheme.secondaryContainer
                        )
                      ),
                    ),
                  )
                ),
              )
            ),

            if(switchOff != null) Container(
              width: 80,
              height: 100,
              child: Material(
                color: state == false ? theme.colorScheme.secondaryContainer : theme.colorScheme.secondary,
                borderRadius: BorderRadius.all(Radius.circular(80)),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                  splashColor: theme.colorScheme.primary,
                  onTap: switchOff,
                  child: Center(
                  child: CustomPaint(
                    painter: _DrawRing(
                      color: state == false ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.secondaryContainer,
                      radius: 20,
                      strokeWidth: 2
                    )
                  ),
                )
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawRing extends CustomPainter {
  late Paint _paint;
  final double radius;
  final double strokeWidth;
  final Color color;

  _DrawRing({
    required this.radius,
    this.strokeWidth = 2,
    this.color = Colors.white
  }) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
     canvas.drawCircle(Offset(0.0, 0.0), radius, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

