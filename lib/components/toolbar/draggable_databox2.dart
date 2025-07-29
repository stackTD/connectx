// draggable_data_box.dart
import 'package:flutter/material.dart';
import '../connector_store.dart';

// In draggable_data_box.dart
class DraggableDataBox2 extends StatelessWidget {
  final ConnectorStore connectorStore;
  final Color color;

  DraggableDataBox2({
    required this.connectorStore,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'DataBox2',
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: 150,
          height: 80,
          decoration: BoxDecoration(
            border:
                Border.all(color: const Color.fromARGB(0, 0, 0, 0), width: 2.0),
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'Dynamic Int data Box',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(),
      child: Container(
        width: 150,
        height: 80,
        decoration: BoxDecoration(
          border:
              Border.all(color: const Color.fromARGB(0, 0, 0, 0), width: 2.0),
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'Dynamic Int Data Box',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
