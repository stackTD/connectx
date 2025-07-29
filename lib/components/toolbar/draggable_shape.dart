// draggable_shape.dart
import 'package:flutter/material.dart';
import 'shape_widget.dart';
import 'shape_type.dart';

class DraggableShape extends StatelessWidget {
  final ShapeType shape;
  final Color color; ////////
  final ValueChanged<ShapeType> onSelected; ////////

  DraggableShape({
    required this.shape,
    required this.color, //////
    required this.onSelected,
  }); ///////

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelected(shape);
      },
      child: Draggable<ShapeWidget>(
        data: ShapeWidget(shape: shape, color: color),
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.7,
            child: ShapeWidget(shape: shape, color: color),
          ),
        ),
        childWhenDragging: Container(),
        child: ShapeWidget(shape: shape, color: color),
      ),
    );
  }
}
