import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../connector_store.dart';
import 'package:mobx/mobx.dart';
import '../drawing_area/selection_store.dart';
import 'dart:convert';
import 'dart:io';
import './data_box_config_store.dart';

class DataBoxWidget3 extends StatefulWidget {
  final ConnectorStore connectorStore;
  final SelectionStore selectionStore;
  final DataBoxConfigStore configStore;
  final int index;

  const DataBoxWidget3({
    required this.index,
    required this.connectorStore,
    required this.selectionStore,
    required this.configStore,
    Key? key,
  }) : super(key: key);

  @override
  _DataBoxWidgetState3 createState() => _DataBoxWidgetState3();
}

class _DataBoxWidgetState3 extends State<DataBoxWidget3> {
  String currentAddress = '';
  late final ReactionDisposer _disposer;
  bool _isHovered = false;

  // State variables for user-selected ranges, colors, and texts
  List<int> ranges = [30, 60, 90, 150];
  List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.purple,
    Colors.white,
    Colors.black
  ];
  List<String> texts = ["Safe", "Caution", "Warning", "Danger"];

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

  Color getBackgroundColor(int? value) {
    if (value == null) return Colors.white;
    for (int i = 0; i < ranges.length; i++) {
      if (value <= ranges[i]) {
        return colors[i];
      }
    }
    return Colors.white;
  }

  String getDisplayText(int? value) {
    if (value == null) return 'No Data';
    for (int i = 0; i < ranges.length; i++) {
      if (value <= ranges[i]) {
        return texts[i];
      }
    }
    return 'No Data';
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final value = widget.connectorStore.registerValues[currentAddress];
        final intValue = int.tryParse(value ?? '');
        final backgroundColor = getBackgroundColor(intValue);
        final displayText = getDisplayText(intValue);
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Stack(
            children: [
              Material(
                color: backgroundColor,
                elevation: 1,
                child: Container(
                  width: 150,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isHovered)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit, size: 10),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text('Edit Data'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < ranges.length; i++)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue:
                                                  ranges[i].toString(),
                                              decoration: InputDecoration(
                                                labelText: 'Range ${i + 1}',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  ranges[i] =
                                                      int.tryParse(value) ??
                                                          ranges[i];
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: DropdownButton<Color>(
                                              value: colors[i],
                                              items: [
                                                DropdownMenuItem(
                                                  value: Colors.red,
                                                  child: Text('Red'),
                                                ),
                                                DropdownMenuItem(
                                                  value: Colors.yellow,
                                                  child: Text('Yellow'),
                                                ),
                                                DropdownMenuItem(
                                                  value: Colors.green,
                                                  child: Text('Green'),
                                                ),
                                                DropdownMenuItem(
                                                  value: Colors.purple,
                                                  child: Text('Purple'),
                                                ),
                                                DropdownMenuItem(
                                                  value: const Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  child: Text('White'),
                                                ),
                                                DropdownMenuItem(
                                                  value: const Color.fromARGB(
                                                      255, 107, 104, 104),
                                                  child: Text('Grey'),
                                                ),
                                              ],
                                              onChanged: (color) {
                                                setState(() {
                                                  colors[i] =
                                                      color ?? colors[i];
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: texts[i],
                                              decoration: InputDecoration(
                                                labelText: 'Text ${i + 1}',
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  texts[i] = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
