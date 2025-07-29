// In components/toolbar/datetime.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import

class DateTimeWidget2 extends StatefulWidget {
  final Color color;

  const DateTimeWidget2({
    this.color =
        const Color.fromARGB(255, 0, 0, 0), // Set default color to black
    Key? key,
  }) : super(key: key);

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget2> {
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
    final dateStr =
        DateFormat('MM/dd/yyyy').format(_currentTime); // Change date format
    final timeStr =
        DateFormat('hh:mm a').format(_currentTime); // Change time format

    return Material(
      color: widget.color,
      elevation: 1,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4.0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(
                      255, 33, 32, 32), // Change text color to white
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(
                      255, 18, 18, 18), // Change text color to white
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

class DraggableDateTimeBox2 extends StatelessWidget {
  final Color color;

  const DraggableDateTimeBox2({
    this.color =
        const Color.fromARGB(255, 0, 0, 0), // Set default color to black
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'DateTimeBox2',
      feedback: DateTimeWidget2(color: color.withOpacity(0.7)),
      child: DateTimeWidget2(color: color),
    );
  }
}
