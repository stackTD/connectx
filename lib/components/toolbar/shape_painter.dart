import 'package:flutter/material.dart';
import 'shape_type.dart';
import 'package:mobx/mobx.dart';
import '../drawing_area/selection_store.dart';
import 'dart:math';
// import '../settings/connection/tcp_connector.dart';
import '../connector_store.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ShapePainter extends CustomPainter {
  final ShapeType shape;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final ConnectorStore connectorStore; // Added dynamic text parameter

  ShapePainter(
      {required this.shape,
      required this.color,
      required this.borderColor,
      required this.borderWidth,
      required this.connectorStore});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; // Fill the shape

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke // Draw only the border
      ..strokeWidth = borderWidth; // Set the border thickness

    switch (shape) {
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, fillPaint); // Fill the shape
        canvas.drawPath(path, borderPaint); // Draw the border
        break;

      case ShapeType.square:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, fillPaint); // Fill the shape
        canvas.drawRect(rect, borderPaint); // Draw the border
        break;

      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;

        // Draw the filled circle
        canvas.drawCircle(center, radius, fillPaint);

        // Draw the circle border
        canvas.drawCircle(center, radius, borderPaint);

        break;

      case ShapeType.hexagon:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;
        final path = Path();

        // Calculate the six vertices of the hexagon
        for (int i = 0; i < 6; i++) {
          final angle = (i * 2 * pi) / 6;
          final x = center.dx + radius * cos(angle);
          final y = center.dy + radius * sin(angle);
          if (i == 0) {
            path.moveTo(x, y); // Move to the first vertex
          } else {
            path.lineTo(x, y); // Draw lines to the next vertices
          }
        }
        path.close(); // Close the path to form the hexagon

        canvas.drawPath(path, fillPaint); // Fill the hexagon
        canvas.drawPath(path, borderPaint); // Draw the border
        break;

      case ShapeType.ellipse:
        final center = Offset(size.width / 2, size.height / 2);
        final rect = Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height *
              0.6, // Adjust height to control ellipse aspect ratio
        );
        canvas.drawOval(rect, fillPaint); // Fill the ellipse
        canvas.drawOval(rect, borderPaint); // Draw the border
        break;

      case ShapeType.parallelogram:
        final path = Path();
        // Define the four points of the parallelogram
        path.moveTo(size.width * 0.2, size.height); // Bottom-left
        path.lineTo(size.width * 0.8, size.height); // Bottom-right
        path.lineTo(size.width * 0.6, 0); // Top-right
        path.lineTo(size.width * 0.0, 0); // Top-left
        path.close(); // Close the path to form the parallelogram

        canvas.drawPath(path, fillPaint); // Fill the shape
        canvas.drawPath(path, borderPaint); // Draw the border
        break;

      case ShapeType.trapezium:
        final path = Path()
          ..moveTo(size.width * 0.25, size.height) // Bottom-left corner
          ..lineTo(size.width * 0.75, size.height) // Bottom-right corner
          ..lineTo(size.width, 0) // Top-right corner
          ..lineTo(0, 0) // Top-left corner
          ..close();

        canvas.drawPath(path, fillPaint); // Fill the trapezium
        canvas.drawPath(path, borderPaint); // Draw the border of the trapezium
        break;

      case ShapeType.roundedRectangle:
        final radius = 20.0; // Adjust this value for desired corner radius
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

        canvas.drawRRect(rrect, fillPaint); // Fill the rounded rectangle
        canvas.drawRRect(
            rrect, borderPaint); // Draw the border of the rounded rectangle
        break;

      case ShapeType.line:
        final startPoint =
            Offset(0, size.height / 2); // Starting point of the line
        final endPoint =
            Offset(size.width, size.height / 2); // Ending point of the line

        canvas.drawLine(startPoint, endPoint, borderPaint); // Draw the line
        break;

      case ShapeType.curvedLine:
        final path = Path()
          ..moveTo(0, size.height / 2) // Starting point of the curve
          ..quadraticBezierTo(
              size.width / 2,
              0, // Control point (affects the curvature)
              size.width,
              size.height / 2); // End point of the curve

        canvas.drawPath(path, borderPaint); // Draw the curved line
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
//   @override
//   bool shouldRepaint(covariant ShapePainter oldDelegate) {
//     return oldDelegate.fillColor != fillColor;
//   }
// }
}

class ShapePainterWidget extends StatelessWidget {
  final ShapeType shape;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final ConnectorStore connectorStore;

  ShapePainterWidget({
    required this.shape,
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.connectorStore,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return CustomPaint(
          size: Size.infinite,
          painter: ShapePainter(
            shape: shape,
            color: color,
            borderColor: borderColor,
            borderWidth: borderWidth,
            connectorStore: connectorStore,
          ),
        );
      },
    );
  }
}
