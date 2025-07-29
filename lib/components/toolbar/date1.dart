// In components/toolbar/datetime.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import

class DateTimeWidget3 extends StatefulWidget {
  final Color color;

  const DateTimeWidget3({
    this.color = const Color.fromARGB(255, 255, 255, 255),
    Key? key,
  }) : super(key: key);

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget3> {
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
    // final timeStr = DateFormat('HH:mm:ss').format(_currentTime);

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
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
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

class DraggableDateTimeBox3 extends StatelessWidget {
  final Color color;

  const DraggableDateTimeBox3({
    this.color = const Color.fromARGB(255, 255, 255, 255),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'DateTimeBox3',
      feedback: DateTimeWidget3(color: color.withOpacity(0.7)),
      child: DateTimeWidget3(color: color),
    );
  }
}
