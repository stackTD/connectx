import 'package:flutter/material.dart';
import 'dart:io';

class DraggableImage extends StatelessWidget {
  final String imagePath;
  final bool isLocalFile;
  final double feedbackScale;

  const DraggableImage({
    Key? key,
    required this.imagePath,
    this.isLocalFile = false,
    this.feedbackScale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (isLocalFile) {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        fit: BoxFit.contain,
      );
    }

    return Draggable<Image>(
      data: isLocalFile ? Image.file(File(imagePath)) : Image.asset(imagePath),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: SizedBox(
            width: 100,
            height: 100,
            child: imageWidget,
          ),
        ),
      ),
      childWhenDragging: Container(),
      child: imageWidget,
      dragAnchorStrategy: (draggable, context, position) {
        return Offset(0, 0);
      },
    );
  }
}
