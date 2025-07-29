import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GaugeExample(),
    );
  }
}

class GaugeExample extends StatefulWidget {
  @override
  _GaugeExampleState createState() => _GaugeExampleState();
}

class _GaugeExampleState extends State<GaugeExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 20, end: 80).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Gauge Example')),
      body: Center(
        child: CustomPaint(
          size: Size(300, 150), // Width and height of the gauge
          painter: GaugePainter(_animation.value),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;

  GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gaugeBackground = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final Paint gaugeRange = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final Paint needlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height;
    final radius = min(size.width / 2, size.height);

    // Draw the background arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      pi, // Start angle
      pi, // Sweep angle (180 degrees)
      false,
      gaugeBackground,
    );

    // Draw colored ranges
    double startAngle = pi;
    double sweepAngle = (pi / 3);

    // Red range
    gaugeRange.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      false,
      gaugeRange,
    );

    // Yellow range
    gaugeRange.color = Colors.yellow;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle + sweepAngle,
      sweepAngle,
      false,
      gaugeRange,
    );

    // Green range
    gaugeRange.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle + 2 * sweepAngle,
      sweepAngle,
      false,
      gaugeRange,
    );

    // Draw the needle
    final angle = pi + (pi * value / 100);
    final needleLength = radius * 0.8;
    final needleX = centerX + needleLength * cos(angle);
    final needleY = centerY + needleLength * sin(angle);
    canvas.drawLine(
        Offset(centerX, centerY), Offset(needleX, needleY), needlePaint);

    // Draw the center circle
    final Paint centerCircle = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 8, centerCircle);

    // Draw the current value
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toInt().toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(centerX - textPainter.width / 2, centerY - radius * 0.4));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
