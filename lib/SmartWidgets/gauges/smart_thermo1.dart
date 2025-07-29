// draggable_smart_Thermo.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../components/connector_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class DraggableSmartThermo extends StatefulWidget {
  final double initialValue;
  final Color color;
  final ConnectorStore connectorStore;

  DraggableSmartThermo({
    required this.initialValue,
    this.color = Colors.white,
    required this.connectorStore,
  });

  @override
  _DraggableSmartThermoState createState() => _DraggableSmartThermoState();
}

class _DraggableSmartThermoState extends State<DraggableSmartThermo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;
  double _currentValue = 50;
  Timer? _updateTimer;
  ReactionDisposer? reactionDisposer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    // Initialize value animation
    _valueAnimation = Tween<double>(
      begin: _currentValue,
      end: _currentValue,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
    // Add MobX reaction to watch register values
    reactionDisposer = reaction(
        (_) => widget.connectorStore.registerValues['D30'], (String? value) {
      if (value != null) {
        setState(() {
          _currentValue = double.parse(value);
          _updateAnimation(_currentValue);
        });
      }
    });
  }

  void _updateAnimation(double newValue) {
    if (!mounted || !_animationController.isAnimating) {
      _valueAnimation = Tween<double>(
        begin: _currentValue,
        end: newValue,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutSine,
        ),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    reactionDisposer?.call(); // Dispose MobX reaction
    _updateTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _valueAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 50, // Reduced width
          height: 150, // Reduced height
          child: CustomPaint(
            painter: ThermometerPainter(_valueAnimation.value),
          ),
        );
      },
    );
  }
}

class ThermometerPainter extends CustomPainter {
  final double value;

  ThermometerPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint thermometerBackground = Paint()
      ..color = const Color.fromARGB(0, 224, 224, 224)!
      ..style = PaintingStyle.fill;

    final Paint thermometerFill = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double bulbRadius = size.width / 4;
    final double tubeWidth = size.width / 8;
    final double tubeHeight = size.height - bulbRadius * 2;

    // Draw the tube
    Rect tubeRect = Rect.fromLTWH(
      size.width / 2 - tubeWidth / 2,
      bulbRadius / 2,
      tubeWidth,
      tubeHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, Radius.circular(tubeWidth / 2)),
      thermometerBackground,
    );

    // Draw the fill inside the tube
    double fillHeight = (value / 100) * tubeHeight;
    Rect fillRect = Rect.fromLTWH(
      size.width / 2 - tubeWidth / 2,
      tubeHeight - fillHeight + bulbRadius / 2,
      tubeWidth,
      fillHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, Radius.circular(tubeWidth / 2)),
      thermometerFill,
    );

    // Draw the bulb
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      thermometerBackground,
    );

    // Draw the red fill inside the bulb
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius * 0.8,
      thermometerFill,
    );

    // Draw the border
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, Radius.circular(tubeWidth / 2)),
      borderPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      borderPaint,
    );

    // Draw the current value as text inside the bulb
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toInt().toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2,
          size.height - bulbRadius - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
