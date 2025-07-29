import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'shape_type.dart';
import 'shape_painter.dart';
import '../connector_store.dart';
import '../settings/log_store.dart';

class ShapeWidget extends StatelessWidget {
  final ShapeType shape;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final connectorStore = ConnectorStore(LogStore());

  ShapeWidget({
    required this.shape,
    this.color = const Color.fromARGB(4, 228, 0, 0),
    this.borderColor = const Color.fromARGB(255, 0, 136, 255),
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final dynamicText = connectorStore.streamData?.toString() ?? "No data";

        return CustomPaint(
          painter: ShapePainter(
              shape: shape,
              color: color,
              borderColor: borderColor,
              borderWidth: borderWidth,
              connectorStore: connectorStore),
          size: Size(100, 100),
        );
      },
    );
  }
}
