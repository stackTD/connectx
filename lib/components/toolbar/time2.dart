import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DateTimeWidget5 extends StatefulWidget {
  final Color color;

  const DateTimeWidget5({
    this.color = const Color.fromARGB(255, 255, 255, 255),
    Key? key,
  }) : super(key: key);

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget5> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.color,
      elevation: 1,
      child: Container(
        width: 150,
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(0, 189, 189, 189), width: 1.0),
          borderRadius: BorderRadius.circular(55),
        ),
        padding: const EdgeInsets.all(4.0),
        child: CustomPaint(
          painter: _ClockPainter(_currentTime),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime currentTime;

  _ClockPainter(this.currentTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);

    final hourHandLength = radius * 0.5;
    final minuteHandLength = radius * 0.7;
    final secondHandLength = radius * 0.9;

    final hourHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final minuteHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final hourAngle =
        (currentTime.hour % 12 + currentTime.minute / 60) * 30 * pi / 180;
    final minuteAngle =
        (currentTime.minute + currentTime.second / 60) * 6 * pi / 180;
    final secondAngle = currentTime.second * 6 * pi / 180;

    canvas.drawLine(
        center,
        center +
            Offset(hourHandLength * cos(hourAngle - pi / 2),
                hourHandLength * sin(hourAngle - pi / 2)),
        hourHandPaint);
    canvas.drawLine(
        center,
        center +
            Offset(minuteHandLength * cos(minuteAngle - pi / 2),
                minuteHandLength * sin(minuteAngle - pi / 2)),
        minuteHandPaint);
    canvas.drawLine(
        center,
        center +
            Offset(secondHandLength * cos(secondAngle - pi / 2),
                secondHandLength * sin(secondAngle - pi / 2)),
        secondHandPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DraggableDateTimeBox5 extends StatelessWidget {
  final Color color;

  const DraggableDateTimeBox5({
    this.color = const Color.fromARGB(255, 255, 255, 255),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'DateTimeBox5',
      feedback: DateTimeWidget5(color: color.withOpacity(0.7)),
      child: DateTimeWidget5(color: color),
    );
  }
}
