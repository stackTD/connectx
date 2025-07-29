/**
 - This code file deals with the status bar which is located at the bottom of the application
 - Currently it displays the text "Status bar" 
 */

import 'package:flutter/material.dart';
import './UICanvasArea.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package
import '../components/connector_store.dart';
import '../components/drawing_area/selection_store.dart';
import '../components/settings/log_store.dart';

class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusNotifier = ValueNotifier<String>('Status Bar');

    return Column(
      children: [
        Expanded(
          child: UICanvasArea(
            statusNotifier: statusNotifier,
            selectionStore: SelectionStore(), // Add appropriate store
            connectorStore:
                ConnectorStore(LogStore()), // Pass LogStore instance
            hasSettingsBeenOpened: false, // Set initial value
            hasAlarmsBeenOpened: false, // Set initial value
          ),
        ),
        UIStatusBar(statusNotifier: statusNotifier),
      ],
    );
  }
}

class UIStatusBar extends StatelessWidget {
  final ValueNotifier<String> statusNotifier;

  UIStatusBar({required this.statusNotifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Color.fromARGB(255, 131, 131, 131),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: statusNotifier,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
