import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../components/drawing_area/selection_store.dart';

class UIPropetiesMenu extends StatefulWidget {
  final SelectionStore selectionStore;
  UIPropetiesMenu({Key? key, required this.selectionStore}) : super(key: key);

  @override
  _UIPropetiesMenuState createState() => _UIPropetiesMenuState();
}

class _UIPropetiesMenuState extends State<UIPropetiesMenu> {
  final Map<String, TextEditingController> _controllers = {};
  Color _selectedColor = Colors.white; // Default color
  final List<String> readOnlyFields = [
    'text',
    'widgetType',
    'type',
    'imagePath'
  ];
  // These properties are kept hidden from the user
  final List<String> hiddenProperties = [
    'text',
    'widgetType',
    'type',
    'imagePath',
    'index',
  ];

  List<String> devices = [];
  List<String> groups = [];
  List<String> tags = [];

  String? selectedDevice;
  String? selectedGroup;
  String? selectedTag;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    _loadConfigFromSharedPreferences();
  }

  void _initializeControllers() {
    final selectedItem = widget.selectionStore.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 5.5,
      color: const Color.fromARGB(255, 131, 131, 131),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Center(
            child: Text(
              'Properties',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30.0), // Added space
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Observer(
                builder: (_) {
                  final selectedItem = widget.selectionStore.selectedItem;
                  if (selectedItem == null) {
                    return const Center(
                      child: Text(
                        'No Object Selected on Workspace',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }
                  const SizedBox(height: 80.0);

                  _updateControllers(selectedItem);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...selectedItem.entries
                          .where(
                              (entry) => !hiddenProperties.contains(entry.key))
                          .map(
                        (entry) {
                          if (entry.key == 'color') {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}:',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final pickedColor =
                                            await showDialog<Color>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Pick a color'),
                                              content: ColorPicker(
                                                pickerColor: _selectedColor,
                                                onColorChanged: (color) {
                                                  setState(() {
                                                    _selectedColor = color;
                                                  });
                                                },
                                                showLabel: true,
                                                pickerAreaHeightPercent: 0.8,
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Select'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(_selectedColor);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (pickedColor != null) {
                                          setState(() {
                                            _selectedColor = pickedColor;

                                            widget.selectionStore
                                                .updateSelectedItem(
                                                    'color', pickedColor);
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: _selectedColor,
                                        child: Center(
                                          child: Icon(
                                            Icons.color_lens,
                                            color: Color.fromARGB(
                                                255, 1, 195, 254),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (entry.key == 'deviceName') {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    child: const Text(
                                      'PLC:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdown(
                                        devices, selectedDevice ?? '', (value) {
                                      setState(() => selectedDevice = value!);
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (entry.key == 'groupName') {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    child: const Text(
                                      'group:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdown(
                                        groups, selectedGroup ?? '', (value) {
                                      setState(() => selectedGroup = value!);
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (entry.key == 'tagName') {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    child: const Text(
                                      'tag:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdown(
                                        tags, selectedTag ?? '', (value) {
                                      setState(() => selectedTag = value!);
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  child: Text(
                                    '${entry.key}:',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: readOnlyFields.contains(entry.key)
                                        ? Text(
                                            _controllers[entry.key]?.text ?? '',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : TextFormField(
                                            controller: _controllers[entry.key],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      const SizedBox(height: 80.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: _updateAllFields,
                          child: const Text('Update'),
                        ),
                      ),
                      const SizedBox(height: 160.0),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateControllers(Map<String, dynamic> selectedItem) {
    selectedItem.forEach((key, value) {
      if (key != 'color') {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        } else {
          _controllers[key] = TextEditingController(text: value.toString());
        }
      }
    });
  }

  void _updateAllFields() {
    final selectedItem = widget.selectionStore.selectedItem;
    if (selectedItem == null) return;

    final updates = <String, dynamic>{};

    _controllers.forEach((key, controller) {
      if (selectedItem.containsKey(key)) {
        if (key == 'deviceName') {
          updates[key] = selectedDevice;
        } else if (key == 'groupName') {
          updates[key] = selectedGroup;
        } else if (key == 'tagName') {
          updates[key] = selectedTag;
        } else if (['left', 'top', 'width', 'height'].contains(key)) {
          updates[key] = double.tryParse(controller.text) ?? 0.0;
        } else {
          final text = controller.text.trim();
          if (text.isNotEmpty) {
            updates[key] = text;
          }
        }
      }
    });

    updates.forEach((key, value) {
      widget.selectionStore.updateSelectedItem(key, value);
    });
  }

  Widget _buildDropdown(
      List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 0.0,
        horizontal: 0.0,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  Future<void> _loadConfigFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final configString = prefs.getString('connectedDeviceConfig');

    if (configString != null) {
      try {
        final config = json.decode(configString);
        setState(() {
          devices = config.keys.toList().cast<String>();
          selectedDevice = devices.isNotEmpty ? devices[0] : null;

          if (selectedDevice != null &&
              config[selectedDevice]?['Groups'] != null) {
            groups =
                config[selectedDevice]['Groups'].keys.toList().cast<String>();
            selectedGroup = groups.isNotEmpty ? groups[0] : null;
          }

          if (selectedGroup != null &&
              config[selectedDevice]?['Groups']?[selectedGroup]?['Tags'] !=
                  null) {
            tags = config[selectedDevice]['Groups'][selectedGroup]['Tags']
                .keys
                .toList()
                .cast<String>();
            selectedTag = tags.isNotEmpty ? tags[0] : null;
          }
        });
      } catch (e) {
        print('Error parsing config: $e');
      }
    }
  }
}

class SourceData {
  final String deviceName;
  final String groupName;
  final String tagName;

  SourceData({
    required this.deviceName,
    required this.groupName,
    required this.tagName,
  });

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'groupName': groupName,
        'tagName': tagName,
      };

  static SourceData fromJson(Map<String, dynamic> json) => SourceData(
        deviceName: json['deviceName'] ?? '',
        groupName: json['groupName'] ?? '',
        tagName: json['tagName'] ?? '',
      );
}
