// data_box_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../connector_store.dart';
import 'package:mobx/mobx.dart';
import '../drawing_area/selection_store.dart';
import 'dart:convert';
import 'dart:io';
import './data_box_config_store.dart';

class DataBoxWidget extends StatefulWidget {
  final ConnectorStore connectorStore;
  final Color color;
  final SelectionStore selectionStore;
  final DataBoxConfigStore configStore;
  final int index;

  const DataBoxWidget({
    required this.index,
    required this.connectorStore,
    required this.selectionStore,
    required this.configStore,
    this.color = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  _DataBoxWidgetState createState() => _DataBoxWidgetState();
}

class _DataBoxWidgetState extends State<DataBoxWidget> {
  String currentAddress = '';
  late final ReactionDisposer _disposer;

  @override
  void initState() {
    super.initState();
    _disposer = reaction((_) => widget.selectionStore.selectedItem,
        (Map<String, dynamic>? selectedItem) {
      // Only update if this specific box is selected
      if (selectedItem != null &&
          mounted &&
          selectedItem['index'] == widget.index) {
        widget.configStore.updateConfig(selectedItem);
        updateAddress();
      }
    });
    // Initial configuration if available
    _loadInitialConfig();
  }

  void _loadInitialConfig() {
    if (widget.configStore.deviceName.isNotEmpty) {
      updateAddress();
    }
  }

  Future<void> updateAddress() async {
    final address = await getAddressFromConfig();
    if (address != null && mounted) {
      setState(() {
        currentAddress = address;
      });
    }
  }

  Future<String?> getAddressFromConfig() async {
    try {
      final file = File('device_conf.json');
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      if (jsonData[widget.configStore.deviceName] != null &&
          jsonData[widget.configStore.deviceName]['Groups'] != null &&
          jsonData[widget.configStore.deviceName]['Groups']
                  [widget.configStore.groupName] !=
              null &&
          jsonData[widget.configStore.deviceName]['Groups']
                  [widget.configStore.groupName]['Tags'] !=
              null &&
          jsonData[widget.configStore.deviceName]['Groups']
                      [widget.configStore.groupName]['Tags']
                  [widget.configStore.tagName] !=
              null) {
        return jsonData[widget.configStore.deviceName]['Groups']
                [widget.configStore.groupName]['Tags']
            [widget.configStore.tagName]['R_address'];
      }
      return null;
    } catch (e) {
      print('Error reading config: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material wrapper
      color: widget.color,
      elevation: 1,
      child: Container(
        width: 150,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Observer(
          builder: (_) => Center(
            child: Text(
              // connectorStore.streamData ?? 'No Data',
              widget.connectorStore.registerValues[currentAddress]
                      ?.toString() ??
                  'No Data',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
