import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'draggable_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../toolbar/shape_widget.dart';
import '../toolbar/shape_type.dart';
import '../toolbar/text_box_widget.dart';
import '../toolbar/data_box_widget.dart';
import '../toolbar/data_box_widget2.dart';
import '../toolbar/data_box_widget3.dart';

import '../toolbar/datetime1.dart';
import '../toolbar/datetime2.dart';
import '../toolbar/date1.dart';
import '../toolbar/time2.dart';
import '../toolbar/time3.dart';
import '../toolbar/time1.dart';

import '../toolbar/data_box_config_store.dart';
import '../drawing_area/selection_store.dart';
import '../connector_store.dart';
import '../../SmartWidgets/gauges/smart_gauge1.dart';
import '../../SmartWidgets/gauges/smart_thermo1.dart';
import '../../SmartWidgets/fan/smart_fan1.dart';

enum CanvasWidgetType {
  shape,
  image,
  dataBox,
  dataBox2,
  dataBox3,
  textBox,
  dateTimeBox1,
  dateTimeBox2,
  dateTimeBox3,
  dateTimeBox4,
  dateTimeBox5,
  dateTimeBox6,
  SmartGauge,
  SmartThermo,
  SmartFan,
}

class CanvasItemStateManager {
  final BuildContext context;
  final List<DraggableItem> _items;
  final List<Map<String, dynamic>> _canvasObjectStateList;
  final Function(List<DraggableItem>, List<Map<String, dynamic>>) onStateChange;
  final SelectionStore selectionStore;
  // final Color fillColor;//TD20/02
  final ConnectorStore connectorStore;

  CanvasItemStateManager({
    // required this.fillColor, //TD20/02
    required this.context,
    required List<DraggableItem> items,
    required List<Map<String, dynamic>> itemsState,
    required this.onStateChange,
    required this.selectionStore,
    required this.connectorStore,
  })  : _items = items,
        _canvasObjectStateList = itemsState;

  Future<String> saveItemsToPrefs() async {
    final itemsJson =
        jsonEncode(_canvasObjectStateList.map(_mapItemStateToJson).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedItem', itemsJson);
    // print('Items saved to SharedPreferences $itemsJson');
    // print('Items saved to SharedPreferences');
    return itemsJson;
  }

  Future<void> loadItemsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItem = prefs.getString('savedItem');

    if (savedItem != null) {
      final List<dynamic> jsonList = jsonDecode(savedItem);

      _items.clear();
      _canvasObjectStateList.clear();

      for (var itemData in jsonList) {
        final itemWidget = _createItemWidget(itemData);
        final canvasCommonItemProperties =
            _createCanvasCommonItemProperties(itemData);

        _items.add(
          DraggableItem(
            index: _items.length,
            canvasCommonItemProperties: canvasCommonItemProperties,
            item: itemWidget,
            onUpdate: updateCanvasItemState,
            isSelected: false,
            onTap: () {},
            selectionStore: selectionStore,
            connectorStore: connectorStore,
          ),
        );

        _canvasObjectStateList.add(_mapJsonToItemState(itemData));
      }

      onStateChange(_items, _canvasObjectStateList);
      // print('Items loaded from SharedPreferences $savedItem');
    }
  }

  // Clear SharedPreferences
  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _items.clear();
    _canvasObjectStateList.clear();
    onStateChange(_items, _canvasObjectStateList);
    print('SharedPreferences cleared');
  }

  Map<String, dynamic> _mapItemStateToJson(Map<String, dynamic> state) {
    return {
      'Details': {
        'name': state['name'],
        'description': state['description'],
        'text': state['text'],
        'widgetType': state['widgetType'], // Add widget type
        // 'color': state['shapecolor'], //TD20/02
      },
      'Measurements': {
        'left': state['left'],
        'top': state['top'],
        'width': state['width'],
        'height': state['height'],
        'angle': state['angle'],
      },
      'source': {
        'deviceName': state['deviceName'],
        'groupName': state['groupName'],
        'tagName': state['tagName'],
      },
      'type': state['type'],
      'imagePath': state['imagePath'],
      'imageType': state['imageType'],
    };
  }

  Map<String, dynamic> _mapJsonToItemState(Map<String, dynamic> itemData) {
    return {
      'name': itemData['Details']['name'],
      'description': itemData['Details']['description'],
      'text': itemData['Details']['text'],
      'left': itemData['Measurements']['left'],
      'top': itemData['Measurements']['top'],
      'width': itemData['Measurements']['width'],
      'height': itemData['Measurements']['height'],
      'angle': (itemData['Measurements']['angle'] as num).toDouble(),
      'type': itemData['type'],
      'imagePath': itemData['imagePath'],
      'imageType': itemData['imageType'],
      'widgetType': itemData['Details']['widgetType'],
      'deviceName': itemData['source']['deviceName'],
      'groupName': itemData['source']['groupName'],
      'tagName': itemData['source']['tagName'],
      // 'color': itemData['Details']['color'], //TD20/02
    };
  }

  Future<String?> saveItemsToFile() async {
    try {
      // Create json content
      final itemsJson =
          jsonEncode(_canvasObjectStateList.map(_mapItemStateToJson).toList());

      // Open file picker in save mode
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Canvas',
        fileName: 'canvas.connectx',
        type: FileType.custom,
        allowedExtensions: ['connectx'],
      );

      // Check if user selected a location
      if (result != null) {
        final file = File(result);

        // Add .json extension if not present
        final path = file.path.endsWith('.connectx')
            ? file.path
            : '${file.path}.connectx';

        // Save the file
        await File(path).writeAsString(itemsJson);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Canvas saved successfully to ${file.path}')),
        );
        return path;
      }
    } catch (e) {
      print('Error saving file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving canvas: $e')),
      );
    }
    return null;
  }

// TD this method displays the list of properties in UI
  void updateCanvasItemState(
    int index,
    double left,
    double top,
    double width,
    double height,
    String? name,
    String? description,
    String? text,
    double angle,
    String deviceName,
    String groupName,
    String tagName,
    // Color fillColor,
  ) {
    if (index < _canvasObjectStateList.length) {
      String widgetType;

      if (_items[index].item is TextBoxWidget) {
        widgetType = CanvasWidgetType.textBox.toString();
      } else if (_items[index].item is DataBoxWidget) {
        widgetType = CanvasWidgetType.dataBox.toString();
      } else if (_items[index].item is DataBoxWidget2) {
        widgetType = CanvasWidgetType.dataBox2.toString();
      } else if (_items[index].item is DataBoxWidget3) {
        widgetType = CanvasWidgetType.dataBox3.toString();
      } else if (_items[index].item is Image) {
        widgetType = CanvasWidgetType.image.toString();
      } else if (_items[index].item is DateTimeWidget1) {
        widgetType = CanvasWidgetType.dateTimeBox1.toString();
      } else if (_items[index].item is DateTimeWidget2) {
        widgetType = CanvasWidgetType.dateTimeBox2.toString();
      } else if (_items[index].item is DateTimeWidget3) {
        widgetType = CanvasWidgetType.dateTimeBox3.toString();
      } else if (_items[index].item is DateTimeWidget4) {
        widgetType = CanvasWidgetType.dateTimeBox4.toString();
      } else if (_items[index].item is DateTimeWidget5) {
        widgetType = CanvasWidgetType.dateTimeBox5.toString();
      } else if (_items[index].item is DateTimeWidget6) {
        widgetType = CanvasWidgetType.dateTimeBox6.toString();
      } else if (_items[index].item is DraggableSmartGauge) {
        widgetType = CanvasWidgetType.SmartGauge.toString();
      } else if (_items[index].item is DraggableSmartThermo) {
        widgetType = CanvasWidgetType.SmartThermo.toString();
      } else if (_items[index].item is DraggableSmartFan) {
        widgetType = CanvasWidgetType.SmartFan.toString();
      } else {
        widgetType = CanvasWidgetType.shape.toString();
      }

      _canvasObjectStateList[index] = {
        'name': name ?? _canvasObjectStateList[index]['name'],
        'description':
            description ?? _canvasObjectStateList[index]['description'],
        'text': text ?? _canvasObjectStateList[index]['text'],
        'left': left,
        'top': top,
        'width': width,
        'height': height,
        'angle': angle,
        // 'shapecolor': fillColor, //TD20/02
        'widgetType': widgetType,
        'type': _items[index].item is ShapeWidget
            ? (_items[index].item as ShapeWidget).shape.toString()
            : null,
        // 'imagePath': _items[index].item is Image
        //     ? ((_items[index].item as Image).image as AssetImage).assetName
        //     : null,
        'imagePath': _items[index].item is Image
            ? (_items[index].item as Image).image is AssetImage
                ? ((_items[index].item as Image).image as AssetImage).assetName
                : (_items[index].item as Image).image is FileImage
                    ? ((_items[index].item as Image).image as FileImage)
                        .file
                        .path
                    : null
            : null,
        'imageType': _items[index].item is Image
            ? (_items[index].item as Image).image is AssetImage
                ? 'AssetImage'
                : (_items[index].item as Image).image is FileImage
                    ? 'FileImage'
                    : null
            : null,
        'deviceName': deviceName ?? _canvasObjectStateList[index]['deviceName'],
        'groupName': groupName ?? _canvasObjectStateList[index]['groupName'],
        'tagName': tagName ?? _canvasObjectStateList[index]['tagName'],
      };

      onStateChange(_items, _canvasObjectStateList);
    }
  }

  Widget _createItemWidget(Map<String, dynamic> itemData) {
    final widgetType = itemData['Details']['widgetType'] as String?;
    final type = itemData['type'] as String?;
    final imagePath = itemData['imagePath'] as String?;
    final imageType = itemData['imageType'] as String?;
    // final text = itemData['Details']['text'] as String?;

    switch (widgetType) {
      case 'CanvasWidgetType.textBox':
        return TextBoxWidget(
          initialText: itemData['Details']['text'] ?? '',
          isSelected: false,
          onTextChanged: (String newText) {
            final index = _items.indexWhere((item) =>
                item.canvasCommonItemProperties.name ==
                itemData['Details']['name']);
            if (index != -1) {
              updateTextContent(index, newText);
            }
          },
        );

      case 'CanvasWidgetType.dataBox':
        final configStore = DataBoxConfigStore();
        // Restore the configuration
        configStore.updateConfig({
          'deviceName': itemData['source']['deviceName'],
          'groupName': itemData['source']['groupName'],
          'tagName': itemData['source']['tagName']
        });
        return DataBoxWidget(
          index: 0,
          selectionStore: selectionStore,
          connectorStore: connectorStore,
          configStore: configStore, // Pass configured store
          color: const Color.fromARGB(255, 165, 135, 135),
        );
      case 'CanvasWidgetType.dataBox2':
        final configStore = DataBoxConfigStore();
        // Restore the configuration
        configStore.updateConfig({
          'deviceName': itemData['source']['deviceName'],
          'groupName': itemData['source']['groupName'],
          'tagName': itemData['source']['tagName']
        });
        return DataBoxWidget2(
          index: 0,
          selectionStore: selectionStore,
          connectorStore: connectorStore,
          configStore: configStore, // Pass configured store
          // color: const Color.fromARGB(255, 165, 135, 135),
        );

      case 'CanvasWidgetType.dataBox3':
        final configStore = DataBoxConfigStore();
        // Restore the configuration
        configStore.updateConfig({
          'deviceName': itemData['source']['deviceName'],
          'groupName': itemData['source']['groupName'],
          'tagName': itemData['source']['tagName']
        });
        return DataBoxWidget3(
          index: 0,
          selectionStore: selectionStore,
          connectorStore: connectorStore,
          configStore: configStore, // Pass configured store
          // color: const Color.fromARGB(255, 165, 135, 135),
        );

      case 'CanvasWidgetType.dateTimeBox1':
        return DateTimeWidget1(color: const Color.fromARGB(255, 255, 255, 255));
      case 'CanvasWidgetType.dateTimeBox2':
        return DateTimeWidget2(color: const Color.fromARGB(255, 255, 255, 255));
      case 'CanvasWidgetType.dateTimeBox3':
        return DateTimeWidget3(color: const Color.fromARGB(255, 255, 255, 255));
      case 'CanvasWidgetType.dateTimeBox4':
        return DateTimeWidget4(color: const Color.fromARGB(255, 255, 255, 255));
      case 'CanvasWidgetType.dateTimeBox5':
        return DateTimeWidget5(color: const Color.fromARGB(255, 255, 255, 255));
      case 'CanvasWidgetType.dateTimeBox6':
        return DateTimeWidget6(color: const Color.fromARGB(255, 255, 255, 255));

      case 'CanvasWidgetType.SmartGauge':
        return DraggableSmartGauge(
          // index: 0,
          initialValue: 50,
          connectorStore: connectorStore,

          color: const Color.fromARGB(255, 165, 135, 135),
        );

      case 'CanvasWidgetType.SmartThermo':
        return DraggableSmartThermo(
          // index: 0,
          initialValue: 50,
          connectorStore: connectorStore,

          // color: const Color.fromARGB(255, 165, 135, 135),
        );
      case 'CanvasWidgetType.SmartFan':
        return DraggableSmartFan(
            // index: 0,

            // color: const Color.fromARGB(255, 165, 135, 135),
            );

      case 'CanvasWidgetType.image':
        if (imagePath != null) {
          if (imageType == 'FileImage') {
            return Image.file(File(imagePath), fit: BoxFit.contain);
          } else {
            return Image.asset(imagePath, fit: BoxFit.contain);
          }
        }
        break;

      case 'CanvasWidgetType.shape':
        if (type != null) {
          return _createShapeWidgetFromType(type);
        }
        break;
    }

    // Fallback for legacy data without widgetType
    if (type == 'TextBox') {
      return TextBoxWidget(
        initialText: itemData['Details']['text'] ?? '',
        // selectionStore: SelectionStore(),
        isSelected: false,
        onTextChanged: (String newText) {},
      );
    } else if (type == 'DataBox') {
      return DataBoxWidget(
        index: 0,
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        color: const Color.fromARGB(255, 154, 133, 133),
      );
    } else if (type == 'DataBox2') {
      return DataBoxWidget2(
        index: 0,
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        // color: const Color.fromARGB(255, 154, 133, 133),
      );
    } else if (type == 'DataBox3') {
      return DataBoxWidget3(
        index: 0,
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        // color: const Color.fromARGB(255, 154, 133, 133),
      );
    } else if (type == 'DateTimeBox1') {
      return DateTimeWidget1(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'DateTimeBox2') {
      return DateTimeWidget2(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'DateTimeBox3') {
      return DateTimeWidget3(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'DateTimeBox4') {
      return DateTimeWidget4(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'DateTimeBox5') {
      return DateTimeWidget5(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'DateTimeBox6') {
      return DateTimeWidget6(color: const Color.fromARGB(255, 255, 251, 251));
    } else if (type == 'SmartGauge') {
      return DraggableSmartGauge(
        initialValue: 50,
        color: const Color.fromARGB(255, 154, 133, 133),
        connectorStore: connectorStore,
      );
    } else if (type == 'SmartThermo') {
      return DraggableSmartThermo(
        initialValue: 50,
        // color: const Color.fromARGB(255, 154, 133, 133),
        connectorStore: connectorStore,
      );
    } else if (type == 'SmartFan') {
      return DraggableSmartFan(
          // color: const Color.fromARGB(255, 154, 133, 133),
          );
    } else if (imagePath != null) {
      return Image.asset(imagePath);
    }

    return _createShapeWidgetFromType(type ?? 'ShapeType.roundedRectangle');
  }

  //////////////
  ///
  ///
  Future<String?> loadItemsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['connectx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      _items.clear();
      _canvasObjectStateList.clear();

      for (var itemData in jsonList) {
        final itemWidget = _createItemWidget(itemData);
        final canvasCommonItemProperties =
            _createCanvasCommonItemProperties(itemData);

        _items.add(
          DraggableItem(
            index: _items.length,
            canvasCommonItemProperties: canvasCommonItemProperties,
            item: itemWidget,
            onUpdate: updateCanvasItemState,
            isSelected: false,
            onTap: () {},
            selectionStore: selectionStore,
            connectorStore: connectorStore,
          ),
        );

        _canvasObjectStateList.add(_mapJsonToItemState(itemData));
      }

      onStateChange(_items, _canvasObjectStateList);
      _showSnackBar('Previous canvas loaded successfully');
      return result.files.single.path;
    }
    return null;
  }

  CanvasCommonItemProperties _createCanvasCommonItemProperties(
      Map<String, dynamic> itemData) {
    return CanvasCommonItemProperties(
      name: itemData['Details']['name'],
      description: itemData['Details']['description'],
      text: itemData['Details']['text'],
      initialLeft: itemData['Measurements']['left'],
      initialTop: itemData['Measurements']['top'],
      width: itemData['Measurements']['width'],
      height: itemData['Measurements']['height'],
      angle: (itemData['Measurements']['angle'] as num).toDouble(),
      // shapecolor: fillColor, //TD20/02
      widgetType: itemData['Details']['widgetType'] as String?,
      // text: itemData['Details']['text'] as String?,
      type: itemData['type'] as String?,
      imagePath: itemData['imagePath'] as String?,

      deviceName: itemData['source']['deviceName'] ?? '',
      groupName: itemData['source']['groupName'] ?? '',
      tagName: itemData['source']['tagName'] ?? '',
    );
  }

  Widget _createShapeWidgetFromType(String? type, {String? imagePath}) {
    print('Creating widget with type: $type, imagePath: $imagePath');

    // Handle image type first
    if (imagePath != null) {
      print('Creating Image widget with path: $imagePath');
      return Image.asset(imagePath, fit: BoxFit.contain);
    }

    // Handle special widget types
    if (type == 'CanvasWidgetType.textBox' || type == 'TextBox') {
      print('Creating TextBox widget');
      return TextBoxWidget(
        initialText: '',
        isSelected: false,
        // selectionStore: SelectionStore(),
        onTextChanged: (String newText) {
          // Handle text changes if needed
        },
      );
    }

    if (type == 'CanvasWidgetType.dataBox' || type == 'DataBox') {
      print('Creating DataBox widget');
      return DataBoxWidget(
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        color: const Color.fromARGB(255, 184, 144, 144),
        index: 0,
      );
    }

    if (type == 'CanvasWidgetType.dataBox2' || type == 'DataBox2') {
      print('Creating dynamic DataBox2 widget');
      return DataBoxWidget2(
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        // color: const Color.fromARGB(255, 184, 144, 144),
        index: 0,
      );
    }

    if (type == 'CanvasWidgetType.dataBox3' || type == 'DataBox3') {
      print('Creating dynamic DataBox3 widget');
      return DataBoxWidget3(
        configStore: DataBoxConfigStore(),
        selectionStore: selectionStore,
        connectorStore: connectorStore,
        // color: const Color.fromARGB(255, 184, 144, 144),
        index: 0,
      );
    }

    if (type == 'CanvasWidgetType.dateTimeBox1' || type == 'DateTimeBox1') {
      print('Creating DateTimeBox widget1');
      return DateTimeWidget1(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.dateTimeBox2' || type == 'DateTimeBox2') {
      print('Creating DateTimeBox widget2');
      return DateTimeWidget2(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.dateTimeBox3' || type == 'DateTimeBox3') {
      print('Creating DateTimeBox widget3');
      return DateTimeWidget3(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.dateTimeBox4' || type == 'DateTimeBox4') {
      print('Creating DateTimeBox widget4');
      return DateTimeWidget4(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.dateTimeBox5' || type == 'DateTimeBox5') {
      print('Creating DateTimeBox widget5');
      return DateTimeWidget5(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.dateTimeBox6' || type == 'DateTimeBox6') {
      print('Creating DateTimeBox widget6');
      return DateTimeWidget6(color: const Color.fromRGBO(255, 255, 255, 1));
    }
    if (type == 'CanvasWidgetType.SmartGauge' || type == 'SmartGauge') {
      print('Creating SmartGauge widget');
      return DraggableSmartGauge(
        initialValue: 50,
        connectorStore: connectorStore,
        color: const Color.fromARGB(255, 184, 144, 144),
      );
    }
    if (type == 'CanvasWidgetType.SmartThermo' || type == 'SmartThermo') {
      print('Creating SmartThermo widget');
      return DraggableSmartThermo(
        initialValue: 50,
        connectorStore: connectorStore,
        // color: const Color.fromARGB(255, 184, 144, 144),
      );
    }
    if (type == 'CanvasWidgetType.SmartFan' || type == 'SmartFan') {
      print('Creating SmartFan widget');
      return DraggableSmartFan(
          // color: const Color.fromARGB(255, 184, 144, 144),
          );
    }

    // Handle shape types
    print('Creating Shape widget of type: $type');
    final fillColor = const Color.fromARGB(255, 184, 144, 144);
    switch (type) {
      case 'ShapeType.circle':
        return ShapeWidget(shape: ShapeType.circle, color: fillColor);
      case 'ShapeType.square':
        return ShapeWidget(shape: ShapeType.square, color: fillColor);
      case 'ShapeType.triangle':
        return ShapeWidget(shape: ShapeType.triangle, color: fillColor);
      case 'ShapeType.hexagon':
        return ShapeWidget(shape: ShapeType.hexagon, color: fillColor);
      case 'ShapeType.ellipse':
        return ShapeWidget(shape: ShapeType.ellipse, color: fillColor);
      case 'ShapeType.parallelogram':
        return ShapeWidget(shape: ShapeType.parallelogram, color: fillColor);
      case 'ShapeType.trapezium':
        return ShapeWidget(shape: ShapeType.trapezium, color: fillColor);
      case 'ShapeType.roundedRectangle':
        return ShapeWidget(shape: ShapeType.roundedRectangle, color: fillColor);
      case 'ShapeType.line':
        return ShapeWidget(shape: ShapeType.line, color: fillColor);
      case 'ShapeType.curvedLine':
        return ShapeWidget(shape: ShapeType.curvedLine, color: fillColor);
      default:
        print('Unknown type: $type, defaulting to roundedRectangle');
        return ShapeWidget(shape: ShapeType.roundedRectangle, color: fillColor);
    }
  }

  Map<String, dynamic> getCanvasObjectState(int index) {
    if (index >= 0 && index < _canvasObjectStateList.length) {
      return Map<String, dynamic>.from(_canvasObjectStateList[index]);
    }
    throw RangeError('Index $index is out of range');
  }

  void updateTextContent(int index, String text) {
    if (index < _canvasObjectStateList.length) {
      // _canvasObjectStateList[index]['text'] = text;
      _canvasObjectStateList[index]['text'] = text;

      void updateTextContent(int index, String text) {
        if (index < _canvasObjectStateList.length) {
          _canvasObjectStateList[index]['text'] = text;
          // _canvasObjectStateList[index]['Description'] = text;
          _canvasObjectStateList[index]['widgetType'] =
              CanvasWidgetType.textBox.toString();

          onStateChange(_items, _canvasObjectStateList);
        }
      }

      onStateChange(_items, _canvasObjectStateList);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
