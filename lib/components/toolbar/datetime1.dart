// In components/toolbar/datetime.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import

class DateTimeWidget1 extends StatefulWidget {
  final Color color;

  const DateTimeWidget1({
    this.color = Colors.transparent,
    Key? key,
  }) : super(key: key);

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget1> {
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
    final dateStr = DateFormat('dd-MM-yyyy').format(_currentTime);
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 150,
        height: 60,
        padding: const EdgeInsets.all(4.0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 187, 187),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 187, 187),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DraggableDateTimeBox1 extends StatelessWidget {
  final Color color;

  const DraggableDateTimeBox1({
    this.color = Colors.transparent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'DateTimeBox1',
      feedback: DateTimeWidget1(color: color.withOpacity(0.7)),
      child: DateTimeWidget1(color: color),
    );
  }
}
