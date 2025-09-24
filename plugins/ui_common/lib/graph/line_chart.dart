part of '../ui_common.dart';

class GraphEntry<T extends num> {
  final DateTime timestamp;
  final T value;

  GraphEntry({required this.timestamp, required this.value});
}

class GraphSeries<T extends num> {
  final List<GraphEntry<T>> entries;
  final String label;
  final Color color;
  final double? strokeWidth;
  final bool smooth;

  GraphSeries({
    required this.entries,
    required this.label,
    required this.color,
    this.strokeWidth,
    this.smooth = false,
  });
}

class GraphTheme {
  final Color axisColor;
  final Color gridLineColor;
  final Color labelColor;
  final double labelFontSize;
  final double axisStrokeWidth;
  final int gridStep;
  final EdgeInsets padding;
  final double seriesStrokeWidth;

  const GraphTheme({
    required this.axisColor,
    required this.gridLineColor,
    required this.labelColor,
    this.labelFontSize = 10,
    this.axisStrokeWidth = 1,
    this.gridStep = 10,
    this.padding = const EdgeInsets.all(30),
    this.seriesStrokeWidth = 2,
  });

  factory GraphTheme.fromBrightness(Brightness brightness, {
    EdgeInsets padding = const EdgeInsets.all(30),
    double seriesStrokeWidth = 2,
  }) {
    if (brightness == Brightness.dark) {
      return GraphTheme(
        axisColor: Colors.white54,
        gridLineColor: Colors.white12,
        labelColor: Colors.white70,
        padding: padding,
        seriesStrokeWidth: seriesStrokeWidth,
      );
    } else {
      return GraphTheme(
        axisColor: Colors.black45,
        gridLineColor: Colors.black12,
        labelColor: Colors.black87,
        padding: padding,
        seriesStrokeWidth: seriesStrokeWidth,
      );
    }
  }
}

class GraphWidget<T extends num> extends StatelessWidget {
  final List<GraphSeries<T>> series;
  final GraphTheme theme;
  final double height;

  const GraphWidget({
    super.key,
    required this.series,
    required this.theme,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: GraphPainter<T>(
          series: series,
          theme: theme,
        ),
      ),
    );
  }
}

class GraphPainter<T extends num> extends CustomPainter {
  final List<GraphSeries<T>> series;
  final GraphTheme theme;

  GraphPainter({required this.series, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final pad = theme.padding;
    final width = size.width - pad.left - pad.right;
    final height = size.height - pad.top - pad.bottom;

    final allEntries = series.expand((s) => s.entries);
    if (allEntries.isEmpty) return;

    final allValues = allEntries.map((e) => e.value.toDouble());
    final minValue = allValues.reduce(min);
    final maxValue = allValues.reduce(max);

    final rangePadding = 10;
    final paddedMin = (minValue - rangePadding).floorToDouble();
    final paddedMax = (maxValue + rangePadding).ceilToDouble();

    final timestamps = allEntries.map((e) => e.timestamp);
    final startTime = timestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    final endTime = timestamps.reduce((a, b) => a.isAfter(b) ? a : b);
    final totalDuration =
        max(endTime.difference(startTime).inMilliseconds, 1);

    final axisPaint = Paint()
      ..color = theme.axisColor
      ..strokeWidth = theme.axisStrokeWidth;

    final gridPaint = Paint()
      ..color = theme.gridLineColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final textStyle = TextStyle(
      fontSize: theme.labelFontSize,
      color: theme.labelColor,
    );

    canvas.drawLine(
      Offset(pad.left, pad.top),
      Offset(pad.left, size.height - pad.bottom),
      axisPaint,
    );

    canvas.drawLine(
      Offset(pad.left, size.height - pad.bottom),
      Offset(size.width - pad.right, size.height - pad.bottom),
      axisPaint,
    );

    final step = theme.gridStep;
    final startLabel = (paddedMin / step).floor() * step;
    final endLabel = (paddedMax / step).ceil() * step;

    for (int label = startLabel.toInt(); label <= endLabel; label += step) {
      final y = pad.top +
          ((paddedMax - label) / (paddedMax - paddedMin)) * height;

      if (y >= size.height - pad.bottom - 1) continue;

      textPainter.text = TextSpan(text: "$label", style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(pad.left - 25, y - 6));

      canvas.drawLine(
        Offset(pad.left, y),
        Offset(size.width - pad.right, y),
        gridPaint,
      );
    }

    for (var s in series) {
      final points = s.entries.map((entry) {
        final x = pad.left +
            (entry.timestamp.difference(startTime).inMilliseconds /
                totalDuration) *
                width;

        final y = pad.top +
            ((paddedMax - entry.value.toDouble()) /
                (paddedMax - paddedMin)) *
                height;

        return Offset(x, y);
      }).toList();

      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth ?? theme.seriesStrokeWidth
        ..style = PaintingStyle.stroke;

      final path = Path();
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
        for (var i = 1; i < points.length; i++) {
          if (s.smooth && i < points.length - 1) {
            final p1 = points[i];
            final p2 = points[i + 1];
            final control = Offset(
              (p1.dx + p2.dx) / 2,
              (p1.dy + p2.dy) / 2,
            );
            path.quadraticBezierTo(p1.dx, p1.dy, control.dx, control.dy);
          } else {
            path.lineTo(points[i].dx, points[i].dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter<T> oldDelegate) {
    return oldDelegate.series != series || oldDelegate.theme != theme;
  }
}
