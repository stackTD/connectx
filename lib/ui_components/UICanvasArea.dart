import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/drawing_area/draggable_item.dart';
import '../components/drawing_area/item_state_managment.dart';
import '../components/drawing_area/selection_store.dart';
import '../components/toolbar/shape_widget.dart';
import 'package:provider/provider.dart';
import '../components/toolbar/data_box_config_store.dart';
import 'package:mobx/mobx.dart' as mobx;
import '../components/connector_store.dart';
import './UISettingsOption.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'dart:convert';
import '../components/toolbar/shape_type.dart';
import '../components/toolbar/datetime1.dart';
import '../components/toolbar/datetime2.dart';
import '../components/toolbar/date1.dart';
import '../components/toolbar/time1.dart';
import '../components/toolbar/time2.dart';
import '../components/toolbar/time3.dart';
import 'ThemeManager.dart';
import './UISettingsOption.dart';
import '../components/toolbar/text_box_widget.dart';

import '../components/toolbar/data_box_widget.dart';
import '../components/toolbar/data_box_widget2.dart';
import '../components/toolbar/data_box_widget3.dart';

import '../components/settings/log_store.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../SmartWidgets/gauges/smart_gauge1.dart';
import '../SmartWidgets/gauges/smart_thermo1.dart';
import '../SmartWidgets/fan/smart_fan1.dart';
import '../core/constants/app_constants.dart';

class UICanvasArea extends StatefulWidget {
  final SelectionStore selectionStore;
  final ConnectorStore connectorStore;
  final bool hasSettingsBeenOpened;
  final bool hasAlarmsBeenOpened;
  final ValueNotifier<String> statusNotifier;

  const UICanvasArea({
    required this.selectionStore,
    required this.connectorStore,
    required this.hasSettingsBeenOpened,
    required this.hasAlarmsBeenOpened,
    required this.statusNotifier,
  });

  @override
  _UICanvasAreaState createState() => _UICanvasAreaState();
}

class _UICanvasAreaState extends State<UICanvasArea> {
  final Map<int, DataBoxConfigStore> dataBoxConfigStores = {};
  final Map<int, SelectionStore> dataBoxSelectionStores = {};
  List<DraggableItem> _items = []; // all Items on the canvas
  List<Map<String, dynamic>> _canvasObjectStateList = []; // Object's properties
  int? _canvasSelectedObjectIndex;
  late CanvasItemStateManager _canvasItemStateManager;
  Color shapecolor = Color(AppConstants.defaultShapeColorValue);
  final logStore = LogStore();
  late final ConnectorStore connectorStore;
  List<Widget> rectangles = [];
  double _scale = AppConstants.defaultScale;
  double _minScale = AppConstants.minScale;
  double _maxScale = AppConstants.maxScale;
  bool _hasShownWelcomeDialog = false;

  String _canvasTitle = AppConstants.defaultCanvasTitle;
  final FocusNode _focusNode = FocusNode();
  Offset? _selectionStart;
  Offset? _selectionEnd;
  bool _isSelecting = false;
  bool _isDraggingObject = false;
  bool _isDraggingSelected = false;
  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];
  List<Map<String, dynamic>> _canvases = []; // Stores multiple canvases
  int _currentCanvasIndex = 0; // Tracks active canvas

  // Update existing variables to handle multiple canvases
  Map<int, List<DraggableItem>> _allCanvasItems = {};
  bool _selected = false;
  Map<int, List<Map<String, dynamic>>> _allCanvasObjectStates = {};
  List<int> _selectedObjectIndices = [];

  get imagePath => null;

  get imageType => null;

  @override
  void initState() {
    super.initState();
    connectorStore = ConnectorStore(logStore);
    _canvasItemStateManager = CanvasItemStateManager(
      connectorStore: widget.connectorStore,
      context: context,
      items: _items,
      itemsState: _canvasObjectStateList,
      onStateChange: (updatedItems, updatedState) {
        setState(() {
          _items = updatedItems;
          _canvasObjectStateList = updatedState;
        });

        if (_canvasSelectedObjectIndex != null) {
          widget.selectionStore.updateSelection(_createCommonProperties(
              _canvasObjectStateList[_canvasSelectedObjectIndex!]));
        }
        _canvasItemStateManager.saveItemsToPrefs();
      },
      selectionStore: widget.selectionStore,
      // fillColor: shapecolor, //TD20/02
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _canvasItemStateManager.loadItemsFromPrefs();
      _showWelcomeDialog();
      _hasShownWelcomeDialog = true;
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!_hasShownWelcomeDialog) {
    //     _showWelcomeDialog();
    //     _hasShownWelcomeDialog = true;
    //   }
    // });

    mobx.autorun((_) {
      final selectedItem = widget.selectionStore.selectedItem;
      if (selectedItem != null) {
        final newName = selectedItem['name']?.toString() ?? '';
        final newDescription = selectedItem['description']?.toString() ?? '';
        final newText = selectedItem['text']?.toString() ?? '';
        final left = selectedItem['left']?.toString() ?? '0.0';
        final top = selectedItem['top']?.toString() ?? '0.0';
        final width = selectedItem['width']?.toString() ?? '0.0';
        final height = selectedItem['height']?.toString() ?? '0.0';
        final angle = selectedItem['angle']?.toString() ?? '';
        final deviceName = selectedItem['deviceName']?.toString() ?? '';
        final groupName = selectedItem['groupName']?.toString() ?? '';
        final tagName = selectedItem['tagName']?.toString() ?? '';
        final color = selectedItem['color']?.toString() ?? '';

        _updateCanvasItemNameDetails(newName);
        _updateCanvasItemDescription(newDescription);
        _updateCanvasItemtext(newText);
        _updateCanvasItemDeviceName(deviceName);
        _updateCanvasItemGroupName(groupName);
        _updateCanvasItemTagName(tagName);
        _updateTopPosition(top);
        _updateLeftPosition(left);
        _updateWidth(width);
        _updateHeight(height);
        _updateAngle(angle);
      }
    });

    // print("Canvas fillColor: $fillColor");
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.delete) {
        _removeSelectedItem();
      }

      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyS) {
        _canvasItemStateManager.saveItemsToFile();
      }
      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyZ) {
        _undo();
      }

      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyY) {
        _redo();
      }
      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _selectAllItems();
      }
      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyN) {
        _createNewCanvas();
      }

      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _duplicateSelectedItem();
      }

      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _zoomIn();
      }

      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _zoomOut();
      }

      if (HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          final newTop =
              (_canvasObjectStateList[_canvasSelectedObjectIndex!]['top'] - 1)
                  .toString();
          _updateTopPosition(newTop);

          // Update the selection store to reflect new position
          widget.selectionStore.updateSelectedItem('top', double.parse(newTop));
        });
      }

      if (HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          final newTop =
              (_canvasObjectStateList[_canvasSelectedObjectIndex!]['top'] + 1)
                  .toString();
          _updateTopPosition(newTop);

          // Update the selection store to reflect new position
          widget.selectionStore.updateSelectedItem('top', double.parse(newTop));
        });
      }

      if (HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          final newLeft =
              (_canvasObjectStateList[_canvasSelectedObjectIndex!]['left'] - 1)
                  .toString();
          _updateLeftPosition(newLeft);
          widget.selectionStore
              .updateSelectedItem('left', double.parse(newLeft));
        });
      }

      if (HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          final newLeft =
              (_canvasObjectStateList[_canvasSelectedObjectIndex!]['left'] + 1)
                  .toString();
          _updateLeftPosition(newLeft);
          widget.selectionStore
              .updateSelectedItem('left', double.parse(newLeft));
        });
      }
    }
  }

  void _duplicateSelectedItem() {
    if (_canvasSelectedObjectIndex != null) {
      final selectedItem = _items[_canvasSelectedObjectIndex!];
      final newIndex = _items.length;

      final newItem = DraggableItem(
        index: newIndex,
        canvasCommonItemProperties: CanvasCommonItemProperties(
          name: 'Item $newIndex',
          description:
              '${selectedItem.canvasCommonItemProperties.description}_copy',
          text: selectedItem.canvasCommonItemProperties.text,
          initialLeft: selectedItem.canvasCommonItemProperties.initialLeft +
              20, // Offset to avoid overlap
          initialTop: selectedItem.canvasCommonItemProperties.initialTop +
              20, // Offset to avoid overlap
          width: selectedItem.canvasCommonItemProperties.width,
          height: selectedItem.canvasCommonItemProperties.height,
          angle: selectedItem.canvasCommonItemProperties.angle,
          widgetType: selectedItem.canvasCommonItemProperties.widgetType,
          type: selectedItem.canvasCommonItemProperties.type,
          imagePath: selectedItem.canvasCommonItemProperties.imagePath,
          deviceName: selectedItem.canvasCommonItemProperties.deviceName,
          groupName: selectedItem.canvasCommonItemProperties.groupName,
          tagName: selectedItem.canvasCommonItemProperties.tagName,
          // shapecolor: shapecolor, //TD20/02
        ),
        item: selectedItem.item,
        onUpdate: selectedItem.onUpdate,
        isSelected: false,
        onTap: () => _toggleSelection(newIndex),
        selectionStore: widget.selectionStore,
        connectorStore: widget.connectorStore,
      );

      setState(() {
        _items.add(newItem);
        _canvasObjectStateList.add(_createCommonProperties({
          'name': newItem.canvasCommonItemProperties.name,
          'description': newItem.canvasCommonItemProperties.description,
          'text': newItem.canvasCommonItemProperties.text,
          'left': newItem.canvasCommonItemProperties.initialLeft,
          'top': newItem.canvasCommonItemProperties.initialTop,
          'width': newItem.canvasCommonItemProperties.width,
          'height': newItem.canvasCommonItemProperties.height,
          'angle': newItem.canvasCommonItemProperties.angle,
          'widgetType': newItem.canvasCommonItemProperties.widgetType,
          'type': newItem.canvasCommonItemProperties.type,
          'imagePath': newItem.canvasCommonItemProperties.imagePath,
          'deviceName': newItem.canvasCommonItemProperties.deviceName,
          'groupName': newItem.canvasCommonItemProperties.groupName,
          'tagName': newItem.canvasCommonItemProperties.tagName,
        }));
        print('Duplicated item with new index: $newIndex');

        _undoStack.add({
          'action': 'duplicate',
          'item': newItem,
        });
        _redoStack.clear();
      });

      _canvasItemStateManager.saveItemsToPrefs();
    }
  }

  void _selectAllItems() {
    setState(() {
      _selectedObjectIndices =
          List<int>.generate(_items.length, (index) => index);
      if (_items.isNotEmpty) {
        // Convert first selected item properties to a map
        widget.selectionStore.updateSelection(
            _createCommonProperties(_canvasObjectStateList[0]));
      }
    });
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      final lastAction = _undoStack.removeLast();

      setState(() {
        if (lastAction['action'] == 'delete') {
          final item = lastAction['item'];
          final index = lastAction['index'];

          _items.insert(index, item);
          _canvasObjectStateList.insert(
              index,
              _createCommonProperties({
                'name': item.canvasCommonItemProperties.name,
                'description': item.canvasCommonItemProperties.description,
                'text': item.canvasCommonItemProperties.text,
                'left': item.canvasCommonItemProperties.initialLeft,
                'top': item.canvasCommonItemProperties.initialTop,
                'width': item.canvasCommonItemProperties.width,
                'height': item.canvasCommonItemProperties.height,
                'angle': item.canvasCommonItemProperties.angle,
                'widgetType': item.canvasCommonItemProperties.widgetType,
                'type': item.canvasCommonItemProperties.type,
                'imagePath': item.canvasCommonItemProperties.imagePath,
                'deviceName': item.canvasCommonItemProperties.deviceName,
                'groupName': item.canvasCommonItemProperties.groupName,
                'tagName': item.canvasCommonItemProperties.tagName,
              }));

          _redoStack.add(lastAction);
        } else if (lastAction['action'] == 'duplicate') {
          final item = lastAction['item'];

          _items.remove(item);
          _canvasObjectStateList.removeWhere((element) =>
              element['name'] == item.canvasCommonItemProperties.name);

          _redoStack.add(lastAction);
        }
      });

      _canvasItemStateManager.saveItemsToPrefs();
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final lastAction = _redoStack.removeLast();

      setState(() {
        if (lastAction['action'] == 'delete') {
          final item = lastAction['item'];
          final index = lastAction['index'];

          _items.removeAt(index);
          _canvasObjectStateList.removeAt(index);

          _undoStack.add(lastAction);
        } else if (lastAction['action'] == 'duplicate') {
          final item = lastAction['item'];

          _items.add(item);
          _canvasObjectStateList.add(_createCommonProperties({
            'name': item.canvasCommonItemProperties.name,
            'description': item.canvasCommonItemProperties.description,
            'text': item.canvasCommonItemProperties.text,
            'left': item.canvasCommonItemProperties.initialLeft,
            'top': item.canvasCommonItemProperties.initialTop,
            'width': item.canvasCommonItemProperties.width,
            'height': item.canvasCommonItemProperties.height,
            'angle': item.canvasCommonItemProperties.angle,
            'widgetType': item.canvasCommonItemProperties.widgetType,
            'type': item.canvasCommonItemProperties.type,
            'imagePath': item.canvasCommonItemProperties.imagePath,
            'deviceName': item.canvasCommonItemProperties.deviceName,
            'groupName': item.canvasCommonItemProperties.groupName,
            'tagName': item.canvasCommonItemProperties.tagName,
          }));

          _undoStack.add(lastAction);
        }
      });

      _canvasItemStateManager.saveItemsToPrefs();
    }
  }

  // TD edit here, this is the list of properties displayed during dragging
  Map<String, dynamic> _createCommonProperties(Map<String, dynamic> itemState) {
    return {
      'name': itemState['name'],
      'description': itemState['description'],
      // 'color': _colorToString(itemState['color'] ?? fillColor),
      'text': itemState['text'],
      'left': itemState['left'],
      'top': itemState['top'],
      'width': itemState['width'],
      'height': itemState['height'],
      'angle': itemState['angle'],
      'widgetType': itemState['widgetType'], // Add this field
      // 'text': itemState['text'],
      'type': itemState['type'],
      'imagePath': itemState['imagePath'],
      'imageType': itemState['imageType'],
      'deviceName': itemState['deviceName'],
      'groupName': itemState['groupName'],
      'tagName': itemState['tagName'],
    };
  }

  Widget _createShapeWidgetFromType(String? type) {
    if (type == AppConstants.typeTextBox) {
      return TextBoxWidget(
        // selectionStore: widget.selectionStore,
        initialText: _canvasObjectStateList[_items.length - 1]['text'] ?? '',
        isSelected: false,
        onTextChanged: (String newText) {
          _canvasObjectStateList[_items.length - 1]['text'] = newText;
          _canvasItemStateManager.saveItemsToPrefs();
        },
      );
    }

    if (type == 'DateTimeBox1') {
      return DateTimeWidget1(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }
    if (type == 'DateTimeBox2') {
      return DateTimeWidget2(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }
    if (type == 'DateTimeBox3') {
      return DateTimeWidget3(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }
    if (type == 'DateTimeBox4') {
      return DateTimeWidget4(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }
    if (type == 'DateTimeBox5') {
      return DateTimeWidget5(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }
    if (type == 'DateTimeBox6') {
      return DateTimeWidget6(
        color: const Color.fromARGB(255, 250, 248, 248),
      );
    }

    if (type == 'SmartGauge') {
      return DraggableSmartGauge(
        initialValue: 50,
        color: const Color.fromARGB(255, 54, 48, 48),
        connectorStore: widget.connectorStore,
      );
    }
    if (type == 'SmartThermo') {
      return DraggableSmartThermo(
        initialValue: 50,
        // color: const Color.fromARGB(255, 54, 48, 48),
        connectorStore: widget.connectorStore,
      );
    }

    if (type == 'SmartFan') {
      return DraggableSmartFan();
    }

    if (type == AppConstants.typeDataBox) {
      final configStore = DataBoxConfigStore();
      dataBoxConfigStores[_items.length] = configStore;
      return DataBoxWidget(
        connectorStore: widget.connectorStore,
        selectionStore: widget.selectionStore,
        configStore: configStore,
        index: _items.length,
      );
    }

    if (type == AppConstants.typeDataBox2) {
      final configStore = DataBoxConfigStore();
      dataBoxConfigStores[_items.length] = configStore;
      return DataBoxWidget2(
        connectorStore: widget.connectorStore,
        selectionStore: widget.selectionStore,
        configStore: configStore,
        index: _items.length,
      );
    }

    if (type == AppConstants.typeDataBox3) {
      final configStore = DataBoxConfigStore();
      dataBoxConfigStores[_items.length] = configStore;
      return DataBoxWidget3(
        connectorStore: widget.connectorStore,
        selectionStore: widget.selectionStore,
        configStore: configStore,
        index: _items.length,
      );
    }
    switch (type) {
      case 'ShapeType.circle':
        return ShapeWidget(shape: ShapeType.circle);
      case 'ShapeType.square':
        return ShapeWidget(shape: ShapeType.square);
      case 'ShapeType.triangle':
        return ShapeWidget(shape: ShapeType.triangle);
      case 'ShapeType.hexagon':
        return ShapeWidget(shape: ShapeType.hexagon);
      case 'ShapeType.ellipse':
        return ShapeWidget(shape: ShapeType.ellipse);
      case 'ShapeType.parallelogram':
        return ShapeWidget(shape: ShapeType.parallelogram);
      case 'ShapeType.trapezium':
        return ShapeWidget(shape: ShapeType.trapezium);
      case 'ShapeType.roundedRectangle':
        return ShapeWidget(shape: ShapeType.roundedRectangle);
      case 'ShapeType.line':
        return ShapeWidget(shape: ShapeType.line);
      case 'ShapeType.curvedLine':
        return ShapeWidget(shape: ShapeType.curvedLine);

      default:
        return DataBoxWidget(
          connectorStore: widget.connectorStore,
          selectionStore: widget.selectionStore,
          configStore: DataBoxConfigStore(),
          index: _items.length,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        final clickedIndex = _getClickedItemIndex(event.localPosition);
        if (clickedIndex != -1) {
          Offset adjustedPosition = event.localPosition - Offset(0, 55);
          widget.statusNotifier.value =
              "Object: Item $clickedIndex, Position: $adjustedPosition";
        } else {
          Offset adjustedPosition = event.localPosition - Offset(0, 55);
          widget.statusNotifier.value =
              "Empty Space Clicked: Position $adjustedPosition";
        }
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          _isDraggingSelected = false;
          _selectionStart = null;
          _selectionEnd = null;
          if (!_isDraggingSelected && _selectionStart != null) {
            // _selectObjectsInRect(); // Final selection check
          }
        });
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                _canvasTitle,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 117, 117, 117),
              elevation: 10,
              actions: [
                Tooltip(
                  message: "New Canvas",
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      if (_items.isNotEmpty) {
                        _showSaveConfirmationDialog();
                      } else {
                        _createNewCanvas();
                      }
                    },
                  ),
                ),
                Tooltip(
                  message: "Toggle Theme",
                  child: IconButton(
                    icon: Icon(
                      Provider.of<ThemeManager>(context).isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Provider.of<ThemeManager>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ),
                Tooltip(
                  message: "Save Canvas",
                  child: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: () {
                      _canvasItemStateManager
                          .saveItemsToFile()
                          .then((fileName) {
                        if (fileName != null) {
                          _updateTitle(fileName);
                        }
                      });
                    },
                    // onPressed: _canvasItemStateManager.saveItemsToFile,
                  ),
                ),
                Tooltip(
                  message: "Load Canvas",
                  child: IconButton(
                    icon:
                        const Icon(Icons.open_in_browser, color: Colors.white),
                    onPressed: _canvasItemStateManager.loadItemsFromFile,
                  ),
                ),

                const SizedBox(width: 15),

                // Add zoom controls
                Tooltip(
                  message: "Zoom In",
                  child: IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: _zoomIn,
                  ),
                ),
                Tooltip(
                  message: "Zoom Out",
                  child: IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: _zoomOut,
                  ),
                ),
                const SizedBox(width: 15),
                Tooltip(
                  message: "Clear Canvas",
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: _createNewCanvas,
                  ),
                ),
                Tooltip(
                  message: "Delete Selection",
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _canvasSelectedObjectIndex != null
                        ? _removeSelectedItem
                        : null, // Disable when no selection
                    // Change icon color when disabled
                    color: _canvasSelectedObjectIndex != null
                        ? Colors.white
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: DragTarget<Object>(
                    onAcceptWithDetails: (DragTargetDetails<Object> details) {
                      setState(() {
                        final Object draggedItem = details.data;
                        Widget itemWidget;
                        String widgetType = 'Unknown';

                        if (draggedItem == AppConstants.typeTextBox) {
                          itemWidget = TextBoxWidget(
                            initialText: '',
                            // selectionStore: widget.selectionStore,
                            isSelected: false,
                            onTextChanged: (String newText) {
                              if (_items.isNotEmpty) {
                                _canvasItemStateManager.updateTextContent(
                                    _items.length - 1, newText);
                              }
                            },
                          );
                          widgetType = AppConstants.typeTextBox;

                          /// TODO@TD: Remove/change the hard coded values like color, size etc so they can be loaded from prefs/properties
                          // Handle different types of dragged items
                        } else if (draggedItem == 'DateTimeBox1') {
                          itemWidget = DateTimeWidget1(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox1';
                        } else if (draggedItem == 'DateTimeBox2') {
                          itemWidget = DateTimeWidget2(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox2';
                        } else if (draggedItem == 'DateTimeBox3') {
                          itemWidget = DateTimeWidget3(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox3';
                        } else if (draggedItem == 'DateTimeBox4') {
                          itemWidget = DateTimeWidget4(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox4';
                        } else if (draggedItem == 'DateTimeBox5') {
                          itemWidget = DateTimeWidget5(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox5';
                        } else if (draggedItem == 'DateTimeBox6') {
                          itemWidget = DateTimeWidget6(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          );
                          widgetType = 'DateTimeBox6';
                        } else if (draggedItem == 'SmartGauge') {
                          itemWidget = DraggableSmartGauge(
                            initialValue: 50,
                            color: Colors.white,
                            connectorStore: widget.connectorStore,
                          );
                          widgetType = 'SmartGauge';
                        } else if (draggedItem == 'SmartThermo') {
                          itemWidget = DraggableSmartThermo(
                            initialValue: 50,
                            // color: Colors.white,
                            connectorStore: widget.connectorStore,
                          );
                          widgetType = 'SmartThermo';
                        } else if (draggedItem == 'SmartFan') {
                          itemWidget = DraggableSmartFan();
                          widgetType = 'SmartFan';
                        } else if (draggedItem is ShapeWidget) {
                          itemWidget = ShapeWidget(
                            shape: draggedItem.shape,
                            color: shapecolor,
                          );
                          widgetType = 'ShapeType.${draggedItem.shape}';
                        }
                        // else if (draggedItem is Image) {
                        //   itemWidget = draggedItem;
                        // }
                        else if (draggedItem is Image) {
                          itemWidget = draggedItem;
                          String? imagePath;
                          String imageType;

                          if (draggedItem.image is AssetImage) {
                            imagePath =
                                (draggedItem.image as AssetImage).assetName;
                            imageType = 'AssetImage';
                          } else if (draggedItem.image is FileImage) {
                            imagePath =
                                (draggedItem.image as FileImage).file.path;
                            imageType = 'FileImage';
                          } else {
                            imageType = 'Unknown';
                          }
                          widgetType = 'Image';
                        } else if (draggedItem is ShapeWidget) {
                          itemWidget = ShapeWidget(
                            shape: draggedItem.shape,
                            color: shapecolor,
                          );
                        } else if (draggedItem == AppConstants.typeDataBox) {
                          final configStore = DataBoxConfigStore();
                          dataBoxConfigStores[_items.length] = configStore;
                          itemWidget = DataBoxWidget(
                            connectorStore: widget.connectorStore,
                            selectionStore: widget.selectionStore,
                            index: _items.length,
                            configStore: configStore,
                            color: const Color.fromARGB(255, 220, 171, 171),
                          );
                          widgetType = AppConstants.typeDataBox;
                        } else if (draggedItem == AppConstants.typeDataBox2) {
                          final configStore = DataBoxConfigStore();
                          dataBoxConfigStores[_items.length] = configStore;
                          itemWidget = DataBoxWidget2(
                            connectorStore: widget.connectorStore,
                            selectionStore: widget.selectionStore,
                            index: _items.length,
                            configStore: configStore,
                            // color: const Color.fromARGB(255, 186, 199, 219),
                          );
                          widgetType = AppConstants.typeDataBox2;
                        } else if (draggedItem == AppConstants.typeDataBox3) {
                          final configStore = DataBoxConfigStore();
                          dataBoxConfigStores[_items.length] = configStore;
                          itemWidget = DataBoxWidget3(
                            connectorStore: widget.connectorStore,
                            selectionStore: widget.selectionStore,
                            index: _items.length,
                            configStore: configStore,
                            // color: const Color.fromARGB(255, 186, 199, 219),
                          );
                          widgetType = AppConstants.typeDataBox3;
                        } else {
                          return; // Invalid item type
                        }

                        final newItem = DraggableItem(
                          canvasCommonItemProperties:
                              CanvasCommonItemProperties(
                            name: 'Item ${_items.length}',
                            description: 'Item ${_items.length}',
                            text: widgetType == AppConstants.typeTextBox
                                ? 'Enter text'
                                : '', // EDIT HERE
                            initialLeft: details.offset.dx - 160,
                            initialTop: details.offset.dy - 120,
                            width: 150,
                            height: 110,
                            angle: 0,
                            // shapecolor: shapecolor,
                            widgetType: widgetType, // Add this
                            // text: widgetType == AppConstants.typeTextBox
                            //     ? 'Enter text'
                            //     : null, // Add this
                            type: draggedItem is ShapeWidget
                                ? draggedItem.shape.toString()
                                : null, // Add this
                            imagePath: draggedItem is Image
                                ? (draggedItem.image is AssetImage
                                    ? (draggedItem.image as AssetImage)
                                        .assetName
                                    : draggedItem.image is FileImage
                                        ? (draggedItem.image as FileImage)
                                            .file
                                            .path
                                        : null)
                                : null, // Add this
                            // source:
                            //     widgetType == CanvasWidgetType.dataBox ? '' : null,
                            deviceName: '',
                            groupName: '',
                            tagName: '',
                          ),
                          key: ValueKey(_items.length),
                          index: _items.length,
                          item: itemWidget,
                          onUpdate:
                              _canvasItemStateManager.updateCanvasItemState,
                          isSelected: false,
                          onTap: () => _toggleSelection(_items.length),
                          selectionStore: widget.selectionStore,
                          connectorStore: widget.connectorStore,
                        );
                        // print("CanvasUI: New object dropped to canvas $newItem");
// TD edit here
                        _items.add(newItem);
                        _canvasObjectStateList.add(_createCommonProperties({
                          'id': _items.length - 1,
                          'left': details.offset.dx - 157,
                          'top': details.offset.dy - 120,
                          'width': 150.0,
                          'height': 110.0,
                          'type': widgetType,
                          'widgetType': widgetType,
                          'angle': 0.0,
                          // 'text': widgetType == AppConstants.typeTextBox ? 'Enter text' : '',
                          'imagePath': imagePath,
                          'imageType': imageType,
                          'name': 'Item ${_items.length}',
                          'description': 'Item ${_items.length}',
                          'text': widgetType == AppConstants.typeTextBox
                              ? 'Enter text'
                              : '', //EDIT HERE
                          'deviceName': '', // Add default empty string
                          'groupName': '', // Add default empty string
                          'tagName': '',
                          // 'color': _colorToString(fillColor),
                        }));
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return InteractiveViewer(
                        minScale: _minScale,
                        maxScale: _maxScale,
                        scaleEnabled: true,
                        panEnabled: true,
                        child: Transform.scale(
                          scale: _scale,
                          child: Stack(
                            children: [
                              Listener(
                                onPointerDown: (PointerDownEvent event) {
                                  print(
                                      "DEBUG@754: Mouse clicked at ${event.localPosition}");
                                  setState(() {
                                    if (_selected) {
                                      // If an object is selected, do not start forming the rectangle
                                      return;
                                    }
                                    _selectionStart = event.localPosition;
                                    _selectionEnd = event.localPosition;
                                    _isSelecting = true;
                                  });
                                },
                                onPointerMove: (PointerMoveEvent event) {
                                  if (_isSelecting && !_selected) {
                                    setState(() {
                                      _selectionEnd = event.localPosition;
                                      // _selectObjectsInRect();
                                    });
                                  }
                                },
                                onPointerUp: (PointerUpEvent event) {
                                  print(
                                      "DEBUG2@770 : Click released at ${event.localPosition}");
                                  setState(() {
                                    if (_selected) {
                                      // If an object is selected, do not finalize the rectangle
                                      _isSelecting = false;
                                      return;
                                    }
                                    _isSelecting = false;
                                    if (_selectionStart != null &&
                                        _selectionEnd != null) {
                                      final width = (_selectionEnd!.dx -
                                              _selectionStart!.dx)
                                          .abs();
                                      final height = (_selectionEnd!.dy -
                                              _selectionStart!.dy)
                                          .abs();
                                      final area = width * height;
                                      // print(
                                      // "DEBUG@784: Area of rectangle: $area");

                                      final centerX = (_selectionStart!.dx +
                                              _selectionEnd!.dx) /
                                          2;
                                      final centerY = (_selectionStart!.dy +
                                              _selectionEnd!.dy) /
                                          2;
                                      // print(
                                      //     "DEBUG@793: Center of rectangle: Offset($centerX, $centerY)");

                                      _getObjectsSpottedInRect(
                                              _selectionStart!.dx,
                                              _selectionStart!.dy,
                                              _selectionEnd!.dx,
                                              _selectionEnd!.dy)
                                          .then((selectedObjects) {
                                        // print(
                                        //     "DEBUG@799: Objects within selection: ${selectedObjects.join(', ')}");
                                      });
                                    }

                                    _selectionStart = null;
                                    _selectionEnd = null;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      // color of the canvas
                                      color: Provider.of<ThemeManager>(context)
                                              .isDarkMode
                                          ? const Color.fromARGB(
                                              255, 101, 96, 96) // Dark theme
                                          : const Color.fromARGB(
                                              255, 255, 255, 255),
                                      width: MediaQuery.of(context).size.width *
                                          0.82,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Stack(
                                        children:
                                            _items.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var item = entry.value;
                                          return DraggableItem(
                                            canvasCommonItemProperties:
                                                item.canvasCommonItemProperties,
                                            key: ValueKey(item.index),
                                            index: index,
                                            item: item.item,
                                            // canvasCommonItemProperties: item.canvasCommonItemProperties,
                                            isSelected: _selectedObjectIndices
                                                .contains(index),
                                            onTap: () =>
                                                _toggleSelection(index),
                                            selectionStore:
                                                widget.selectionStore,
                                            connectorStore:
                                                widget.connectorStore,
                                            // onUpdate: item.onUpdate,
                                            onUpdate: _canvasItemStateManager
                                                .updateCanvasItemState,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    if (!_isDraggingSelected &&
                                        _selectionStart != null &&
                                        _selectionEnd != null)
                                      CustomPaint(
                                        painter: SelectionRectPainter(
                                          start: _selectionStart!,
                                          end: _selectionEnd!,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Container(
                //   height: 30,
                //   color: Colors.grey[200],
                //   padding: EdgeInsets.symmetric(horizontal: 8),
                //   child: Row(
                //     children: [
                //       Text(
                //         'new canvas setting bar',
                //         style: TextStyle(
                //           fontSize: 14,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

// below cod is for multi canvas, commented to continue with later
                // Container(
                //   height: 30,
                //   color: Colors.grey[200],
                //   padding: EdgeInsets.symmetric(horizontal: 8),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Row(
                //             children: List.generate(
                //               _allCanvasItems.length,
                //               (index) => Padding(
                //                 padding: EdgeInsets.only(right: 2),
                //                 child: InkWell(
                //                   onTap: () => _switchCanvas(index),
                //                   child: Container(
                //                     padding: EdgeInsets.symmetric(
                //                         horizontal: 12, vertical: 4),
                //                     decoration: BoxDecoration(
                //                       color: _currentCanvasIndex == index
                //                           ? Colors.white
                //                           : Colors.grey[300],
                //                       border:
                //                           Border.all(color: Colors.grey[400]!),
                //                       borderRadius: BorderRadius.circular(4),
                //                     ),
                //                     child: Text(
                //                       'Canvas ${index + 1}',
                //                       style: TextStyle(
                //                         fontSize: 14,
                //                         fontWeight: _currentCanvasIndex == index
                //                             ? FontWeight.bold
                //                             : FontWeight.normal,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       IconButton(
                //         icon: Icon(Icons.add, size: 20),
                //         onPressed: _addNewCanvas,
                //         tooltip: 'Add Canvas',
                //       ),
                //     ],
                //   ),
                // ),
              ],
            )),
      ),
    );
  }

  // Color _getItemColor(Object draggedItem) {
  //   if (draggedItem == 'DataBox') {
  //     return const Color.fromARGB(255, 84, 24, 24);
  //   } else if (draggedItem == 'TextBox') {
  //     return Colors.white;
  //   }
  //   return fillColor;
  // }

  // String _colorToString(Color color) {
  //   return color.value.toRadixString(16).padLeft(8, '0');
  // }

  // Color _stringToColor(String colorString) {
  //   return Color(int.parse(colorString, radix: 16));
  // }

  void _addNewCanvas() {
    setState(() {
      final newIndex = _allCanvasItems.length;
      _allCanvasItems[newIndex] = [];
      _allCanvasObjectStates[newIndex] = [];
      _switchCanvas(newIndex);
    });
  }

  void _switchCanvas(int index) {
    setState(() {
      // Save current canvas state
      _allCanvasItems[_currentCanvasIndex] = List.from(_items);
      _allCanvasObjectStates[_currentCanvasIndex] =
          List.from(_canvasObjectStateList);

      // Switch to selected canvas
      _currentCanvasIndex = index;
      _items = List.from(_allCanvasItems[index] ?? []);
      _canvasObjectStateList = List.from(_allCanvasObjectStates[index] ?? []);
      _canvasTitle = "Canvas ${index + 1}";

      // Clear selection when switching
      _clearSelection();
    });
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale + 0.1).clamp(_minScale, _maxScale);
    });
  }

  int _getClickedItemIndex(Offset position) {
    // First adjust for AppBar
    position = Offset(position.dx, position.dy - 55);

    // Scale the click position to match zoomed canvas
    position = position / _scale;
    // print("DEBUG@Scaled Position: $position");s
    // _showPositionSnackBar("DEBUG@Scaled Position: $position");

    for (int i = _items.length - 1; i >= 0; i--) {
      final rect = _getItemRect(i);
      final item = _items[i];

      if (item.canvasCommonItemProperties.angle != 0) {
        final center = rect.center;

        // Use scaled position for rotation calculations
        final dx = position.dx - center.dx;
        final dy = position.dy - center.dy;

        final rotatedDx = dx * cos(-item.canvasCommonItemProperties.angle) -
            dy * sin(-item.canvasCommonItemProperties.angle);
        final rotatedDy = dx * sin(-item.canvasCommonItemProperties.angle) +
            dy * cos(-item.canvasCommonItemProperties.angle);

        final rotatedPoint =
            Offset(center.dx + rotatedDx, center.dy + rotatedDy);

        if (rect.contains(rotatedPoint)) {
          return i;
        }
      } else if (rect.contains(position)) {
        return i;
      }
    }
    return -1;
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.1).clamp(_minScale, _maxScale);
    });
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Canvas?'),
          content: Text(
              'Do you want to save the current canvas before creating new?'),
          actions: <Widget>[
            TextButton(
              child: Text('Don\'t Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _createNewCanvas();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _canvasItemStateManager.saveItemsToFile();
                _createNewCanvas();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTitle(String? filePath) {
    setState(() {
      if (filePath == null) {
        _canvasTitle = "Untitled";
      } else {
        // Extract filename without extension
        final fileName = filePath.split(Platform.pathSeparator).last;
        _canvasTitle = fileName.replaceAll('.json', '');
      }
    });
  }

  void _showWelcomeDialog() {
    // Only show if settings haven't been opened yet
    if (!widget.hasSettingsBeenOpened && !widget.hasAlarmsBeenOpened) {
      showDialog(
        context: context,
        barrierDismissible: false, // User must choose an option
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Welcome to SCADA ConnectX',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Please choose an option to begin:'),
            actions: <Widget>[
              TextButton(
                child: Text('Create New Project'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _createNewCanvas();
                  _updateTitle(null);
                },
              ),
              TextButton(
                child: Text('Load Previous Project'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _canvasItemStateManager.loadItemsFromPrefs();
                  _updateTitle(null);
                },
              ),
              TextButton(
                child: Text('Load a connectx File'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final filePath =
                      await _canvasItemStateManager.loadItemsFromFile();
                  if (filePath != null) {
                    _updateTitle(filePath);
                  }
                },
              )
            ],
          );
        },
      );
    }
  }

  // void _createNewCanvas() {
  //   setState(() {
  //     _items.clear();
  //     _canvasObjectStateList.clear();
  //     _canvasSelectedObjectIndex = null;
  //     _updateTitle(null);
  //     widget.selectionStore.clearSelection();
  //   });
  // }
  void _createNewCanvas() {
    setState(() {
      _items.clear();
      _canvasObjectStateList.clear();
      _undoStack.clear();
      _redoStack.clear();
      _clearSelection();
      _canvasItemStateManager.clearPrefs();

      // Initialize first canvas
      _allCanvasItems = {0: []};
      _allCanvasObjectStates = {0: []};
      _currentCanvasIndex = 0;
      _canvasTitle = "Canvas";
    });
  }

  void _toggleSelection(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    setState(() {
      // If clicking the same item that's already selected
      if (_canvasSelectedObjectIndex == index) {
        // Deselect the item
        _canvasSelectedObjectIndex = null;
        _selected = false;
        widget.selectionStore.clearSelection();
      } else {
        // Select the new item
        _canvasSelectedObjectIndex = index;
        _selected = true;
        var selectionData = _canvasObjectStateList[index];
        selectionData['index'] = index;
        widget.selectionStore.updateSelection(_canvasObjectStateList[index]);
      }

      // Update all items' selection state
      for (int i = 0; i < _items.length; i++) {
        final currentItem = _items[i];
        _items[i] = DraggableItem(
          canvasCommonItemProperties: currentItem.canvasCommonItemProperties,
          key: currentItem.key,
          index: currentItem.index,
          item: currentItem.item,
          onUpdate: currentItem.onUpdate,
          isSelected: i == _canvasSelectedObjectIndex,
          onTap: () => _toggleSelection(i),
          selectionStore: widget.selectionStore,
          connectorStore: widget.connectorStore,
        );
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _canvasSelectedObjectIndex = null;
      widget.selectionStore.clearSelection();

      // Clear selection state for all items
      for (int i = 0; i < _items.length; i++) {
        final currentItem = _items[i];
        _items[i] = DraggableItem(
          canvasCommonItemProperties: currentItem.canvasCommonItemProperties,
          key: currentItem.key,
          index: currentItem.index,
          item: currentItem.item,
          onUpdate: currentItem.onUpdate,
          isSelected: false,
          onTap: () => _toggleSelection(i),
          selectionStore: widget.selectionStore,
          connectorStore: widget.connectorStore,
        );
      }
    });
  }

  void _handleBackgroundTap() {
    _clearSelection();
  }

  void _setSelection(List<int> indices) {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        final currentItem = _items[i];
        final newItem = DraggableItem(
          canvasCommonItemProperties: currentItem.canvasCommonItemProperties,
          key: currentItem.key,
          index: currentItem.index,
          item: currentItem.item,
          onUpdate: currentItem.onUpdate,
          isSelected: indices.contains(i),
          onTap: currentItem.onTap,
          selectionStore: currentItem.selectionStore,
          connectorStore: currentItem.connectorStore,
        );
        _items[i] = newItem;
      }
    });
  }

  void _removeSelectedItem() {
    if (_canvasSelectedObjectIndex != null) {
      dataBoxSelectionStores.remove(_canvasSelectedObjectIndex);
      setState(() {
        _items.removeAt(_canvasSelectedObjectIndex!);
        _canvasObjectStateList.removeAt(_canvasSelectedObjectIndex!);
        widget.selectionStore.clearSelection(); // Clear selection store
        _selected = false;

        // Update indices of remaining items
        for (int i = _canvasSelectedObjectIndex!; i < _items.length; i++) {
          _items[i] = DraggableItem(
            key: ValueKey('$i-${DateTime.now().millisecondsSinceEpoch}'),
            index: i,
            item: _items[i].item,
            canvasCommonItemProperties: _items[i].canvasCommonItemProperties,
            onUpdate: _items[i].onUpdate,
            isSelected: false,
            onTap: () => _toggleSelection(i),
            selectionStore: widget.selectionStore,
            connectorStore: widget.connectorStore,
          );
        }

        _clearSelection();
        _canvasItemStateManager.saveItemsToPrefs();
      });
    }
  }

  void _updateCanvasItemState(String field, dynamic value) {
    if (_canvasSelectedObjectIndex != null) {
      setState(() {
        _canvasObjectStateList[_canvasSelectedObjectIndex!] = {
          ..._canvasObjectStateList[_canvasSelectedObjectIndex!],
          field: value,
        };
        _items[_canvasSelectedObjectIndex!] =
            createUpdatedDraggableCanvasItem(field, value);
      });
    }
  }

  void _showPositionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      ),
    );
  }

  DraggableItem createUpdatedDraggableCanvasItem(String field, dynamic value) {
    final currentItem = _items[_canvasSelectedObjectIndex!];
    final updatedProperties = CanvasCommonItemProperties(
      name:
          field == 'name' ? value : currentItem.canvasCommonItemProperties.name,
      description: field == 'description'
          ? value
          : currentItem.canvasCommonItemProperties.description,
      text:
          field == 'text' ? value : currentItem.canvasCommonItemProperties.text,
      initialLeft: field == 'left'
          ? value
          : currentItem.canvasCommonItemProperties.initialLeft,
      initialTop: field == 'top'
          ? value
          : currentItem.canvasCommonItemProperties.initialTop,
      width: field == 'width'
          ? value
          : currentItem.canvasCommonItemProperties.width,
      height: field == 'height'
          ? value
          : currentItem.canvasCommonItemProperties.height,
      angle: field == 'angle'
          ? value
          : currentItem.canvasCommonItemProperties.angle,
      // shapecolor: field == 'color'
      //     ? value
      //     : currentItem.canvasCommonItemProperties.shapecolor, //TD20/02
      widgetType: currentItem.canvasCommonItemProperties.widgetType,
      type: currentItem.canvasCommonItemProperties.type,
      imagePath: currentItem.canvasCommonItemProperties.imagePath,
      // source: field == 'source'
      //     ? value
      //     : currentItem.canvasCommonItemProperties.source,
      deviceName: field == 'deviceName'
          ? value
          : currentItem.canvasCommonItemProperties.deviceName,
      groupName: field == 'groupName'
          ? value
          : currentItem.canvasCommonItemProperties.groupName,
      tagName: field == 'tagName'
          ? value
          : currentItem.canvasCommonItemProperties.tagName,
    );

    return DraggableItem(
      // key: ValueKey(currentItem.index),
      key: ValueKey(
          '${currentItem.index}-${DateTime.now().millisecondsSinceEpoch}'),
      index: currentItem.index,
      item: currentItem.item,
      canvasCommonItemProperties: updatedProperties,
      onUpdate: currentItem.onUpdate,
      isSelected: true,
      onTap: () => _toggleSelection(currentItem.index),
      selectionStore: widget.selectionStore,
      connectorStore: widget.connectorStore,
    );
  }

  void _updateCanvasItemNameDetails(String value) =>
      _updateCanvasItemState('name', value);

  void _updateCanvasItemDescription(String value) =>
      _updateCanvasItemState('description', value);

  void _updateCanvasItemtext(String value) =>
      _updateCanvasItemState('text', value);

  void _updateCanvasItemDeviceName(String value) =>
      _updateCanvasItemState('deviceName', value);

  void _updateCanvasItemGroupName(String value) =>
      _updateCanvasItemState('groupName', value);
  void _updateCanvasItemTagName(String value) =>
      _updateCanvasItemState('tagName', value);
  void _updateTopPosition(String value) =>
      _updateCanvasItemState('top', double.tryParse(value) ?? 0.0);
  void _updateLeftPosition(String value) =>
      _updateCanvasItemState('left', double.tryParse(value) ?? 0.0);
  void _updateWidth(String value) =>
      _updateCanvasItemState('width', double.tryParse(value) ?? 0.0);
  void _updateHeight(String value) =>
      _updateCanvasItemState('height', double.tryParse(value) ?? 0.0);
  void _updateAngle(String value) =>
      _updateCanvasItemState('angle', double.tryParse(value) ?? 0.0);

  Rect _getItemRect(int index) {
    final item = _items[index];
    // Add padding to make hit testing more forgiving
    final padding = 5.0;

    return Rect.fromLTWH(
        item.canvasCommonItemProperties.initialLeft - padding,
        item.canvasCommonItemProperties.initialTop - padding,
        item.canvasCommonItemProperties.width + (padding * 2),
        item.canvasCommonItemProperties.height + (padding * 2));
  }

  Future<List<String>> _getObjectsSpottedInRect(
      double startX, double startY, double endX, double endY) async {
    List<String> selectedObjects = [];
    List<int> selectedIndices = [];

    debugPrint(
        "DEBUG: start of rectangle: ${startX.toStringAsFixed(2)}, ${startY.toStringAsFixed(2)}");
    debugPrint(
        "DEBUG: end of rectangle: ${endX.toStringAsFixed(2)}, ${endY.toStringAsFixed(2)}");

    final width = (endX - startX).abs();
    final height = (endY - startY).abs();
    final area = double.parse((width * height).toStringAsFixed(2));
    print("DEBUG: Area of rectangle: $area");

    for (int i = 0; i < _items.length; i++) {
      final itemRect = _getItemRect(i);
      if (itemRect.overlaps(
          Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)))) {
        selectedObjects.add(_items[i].canvasCommonItemProperties.name);
        selectedIndices.add(i);
      }
    }

    setState(() {
      _selectedObjectIndices = selectedIndices;
    });

    print(
        "DEBUG: Found ${selectedObjects.length} objects in selection: ${selectedObjects.join(' ')}");
    return selectedObjects;
  }
}

class SelectionRectPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  SelectionRectPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(SelectionRectPainter oldDelegate) {
    return start != oldDelegate.start || end != oldDelegate.end;
  }
}
