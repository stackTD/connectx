import 'package:flutter/material.dart';
import 'dart:math';

class DraggableSmartFan extends StatefulWidget {
  @override
  _DraggableSmartFanState createState() => _DraggableSmartFanState();
}

class _DraggableSmartFanState extends State<DraggableSmartFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool isRotating = false;
  bool isHovered = false; // Add hover state

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  void _toggleFan() {
    setState(() {
      isRotating = !isRotating;
      if (isRotating) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: FanPainter(_rotationController.value * 2 * pi),
                size: Size(80, 80),
              );
            },
          ),
          Visibility(
            visible: isHovered,
            child: Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  isRotating ? Icons.pause : Icons.play_arrow,
                  size: 20,
                  color: Colors.blue,
                ),
                onPressed: _toggleFan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}

class FanPainter extends CustomPainter {
  final double angle;

  FanPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fanPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade800, Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2))
      ..style = PaintingStyle.fill;
    // ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < 3; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius),
            i * 2 * pi / 3,
            pi / 3,
            false,
          )
          ..close(),
        fanPaint,
      );
    }
    canvas.restore();

    // Draw center circle
    canvas.drawCircle(
      center,
      radius * 0.15,
      Paint()..color = Colors.grey,
    );
  }

  @override
  bool shouldRepaint(covariant FanPainter oldDelegate) => true;
}
