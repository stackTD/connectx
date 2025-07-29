import 'package:Sl_SCADA_ConnectX/components/toolbar/data_box_widget.dart';
import 'package:Sl_SCADA_ConnectX/components/toolbar/data_box_widget2.dart';
import 'package:Sl_SCADA_ConnectX/components/toolbar/data_box_widget3.dart';
import 'package:Sl_SCADA_ConnectX/components/toolbar/shape_widget.dart';
import 'package:Sl_SCADA_ConnectX/components/toolbar/datetime1.dart';
import 'package:Sl_SCADA_ConnectX/components/toolbar/time3.dart';
import '../toolbar/datetime2.dart';
import '../toolbar/date1.dart';
import '../toolbar/time1.dart';
import '../toolbar/time2.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'dart:async';
import 'dart:math' show pi;
import 'package:Sl_SCADA_ConnectX/components/toolbar/text_box_widget.dart';
import './selection_store.dart';
import '../connector_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../settings/log_store.dart';
import '../../SmartWidgets/gauges/smart_gauge1.dart';
import '../../SmartWidgets/gauges/smart_thermo1.dart';
import '../../SmartWidgets/fan/smart_fan1.dart';

// TD step 1 adding properties
class CanvasCommonItemProperties {
  final String name;
  final String description;
  final String text;
  // final Color shapecolor; //TD20/02
  final double initialLeft;
  final double initialTop;
  final double width;
  final double height;
  final double angle;
  final String? widgetType; // Can be 'TextBox', 'DataBox', etc.
  // final String? text; // For TextBox content
  final String? type; // For shape types like 'ShapeType.circle'
  final String? imagePath; // For image assets path
  final String? imageType; // For image type like 'local' or 'network'
  final String deviceName;
  final String groupName;
  final String tagName;

  CanvasCommonItemProperties(
      {required this.name,
      required this.description,
      required this.text,
      required this.initialLeft,
      required this.initialTop,
      required this.width,
      required this.height,
      required this.angle,
      // required this.shapecolor, //TD20/02
      required this.widgetType,
      // required this.text,
      required this.type,
      required this.imagePath,
      this.imageType,
      required this.deviceName,
      required this.groupName,
      required this.tagName});
}

class DraggableItem extends StatefulWidget {
  final int index;
  final Object item;
  final CanvasCommonItemProperties canvasCommonItemProperties;
  final bool isSelected;
  final VoidCallback onTap;
  final SelectionStore selectionStore;
  final ConnectorStore connectorStore;
  final Key? key;

  final Function(int, double, double, double, double, String, String, String,
      double, String, String, String) onUpdate;

  DraggableItem({
    required this.index,
    required this.canvasCommonItemProperties,
    required this.item,
    required this.onUpdate,
    required this.isSelected,
    required this.onTap,
    required this.selectionStore,
    required this.connectorStore,
    this.key,
  }) : super(key: key);

  @override
  _DraggableItemState createState() => _DraggableItemState();
}

class _DraggableItemState extends State<DraggableItem> {
  late double _left;
  late double _top;
  late double _width;
  late double _height;
  double _rotationAngle = 0.0;
  double _rotationDegrees = 0.0;

  final double _padding = 10.0;
  final ConnectorStore connectorStore = ConnectorStore(LogStore());

  @override
  void initState() {
    super.initState();

    _left = widget.canvasCommonItemProperties.initialLeft;
    _top = widget.canvasCommonItemProperties.initialTop;
    _width = widget.canvasCommonItemProperties.width;
    _height = widget.canvasCommonItemProperties.height;
    _rotationAngle = widget.canvasCommonItemProperties.angle;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUpdate(
        widget.index,
        _left,
        _top,
        _width,
        _height,
        widget.canvasCommonItemProperties.name,
        widget.canvasCommonItemProperties.description,
        widget.canvasCommonItemProperties.text,
        _rotationAngle,
        widget.canvasCommonItemProperties.deviceName,
        widget.canvasCommonItemProperties.groupName,
        widget.canvasCommonItemProperties.tagName,
      );
    });
  }

  @override
  void didUpdateWidget(DraggableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canvasCommonItemProperties.angle !=
        oldWidget.canvasCommonItemProperties.angle) {
      setState(() {
        _rotationAngle = widget.canvasCommonItemProperties.angle;
      });
    }
    if (widget.canvasCommonItemProperties.initialLeft !=
            oldWidget.canvasCommonItemProperties.initialLeft ||
        widget.canvasCommonItemProperties.initialTop !=
            oldWidget.canvasCommonItemProperties.initialTop ||
        widget.canvasCommonItemProperties.width !=
            oldWidget.canvasCommonItemProperties.width ||
        widget.canvasCommonItemProperties.height !=
            oldWidget.canvasCommonItemProperties.height) {
      setState(() {
        _left = widget.canvasCommonItemProperties.initialLeft;
        _top = widget.canvasCommonItemProperties.initialTop;
        _width = widget.canvasCommonItemProperties.width;
        _height = widget.canvasCommonItemProperties.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final parentSize = MediaQuery.of(context).size;
    return Transform.translate(
      offset: Offset(_left, _top),
      child: Transform.rotate(
        angle: _rotationAngle,
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.onTap,
              onPanStart: (details) {
                // Optional: Add drag start handling
              },
              onPanUpdate: (details) {
                setState(() {
                  // Apply movement immediately
                  _left += details.delta.dx;
                  _top += details.delta.dy;

                  // Defer bounds checking to next frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final canvasWidth = MediaQuery.of(context).size.width;
                    final canvasHeight = MediaQuery.of(context).size.height;

                    setState(() {
                      // Apply bounds
                      _left = _left.clamp(0.0, canvasWidth - _width - 349);
                      _top = _top.clamp(0.0, canvasHeight - _height - 137);
                    });

                    // Update position
                    widget.onUpdate(
                      widget.index,
                      _left,
                      _top,
                      _width,
                      _height,
                      widget.canvasCommonItemProperties.name,
                      widget.canvasCommonItemProperties.description,
                      widget.canvasCommonItemProperties.text,
                      _rotationAngle,
                      widget.canvasCommonItemProperties.deviceName,
                      widget.canvasCommonItemProperties.groupName,
                      widget.canvasCommonItemProperties.tagName,
                    );
                  });
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _rotationAngle,
                    child: _buildSelectionBox(),
                  ),
                  Transform.rotate(
                    angle: _rotationAngle,
                    child: Container(
                      width: _width,
                      height: _height,
                      padding: EdgeInsets.all(_padding),
                      child: _buildItemWidget(),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isSelected) _buildResizeHandle(),
            if (widget.isSelected) _buildRotationHandle()
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBox() {
    return Container(
      width: _width * 1.09,
      height: _height * 1.09,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isSelected
              ? Color.fromARGB(248, 154, 203, 246)
              : Color.fromARGB(0, 173, 47, 47),
          width: widget.isSelected ? 2 : 0,
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onPanUpdate: (details) => _Resize(details.delta),
        child: const Icon(
          Icons.drag_handle_rounded,
          color: Color.fromARGB(255, 107, 107, 107),
          size: 18.0,
        ),
      ),
    );
  }

  void _Resize(Offset delta) {
    setState(() {
      final canvasSize = MediaQuery.of(context).size;

      // Calculate new dimensions
      double newWidth =
          (_width + delta.dx).clamp(20.0, canvasSize.width - _left - 500);
      double newHeight =
          (_height + delta.dy).clamp(20.0, canvasSize.height - _top - 156);

      // Adjust position if resizing pushes the object out of bounds
      if (_left + newWidth > canvasSize.width - 500) {
        _left = canvasSize.width - newWidth - 500;
      }
      if (_top + newHeight > canvasSize.height - 156) {
        _top = canvasSize.height - newHeight - 156;
      }

      // Update dimensions
      _width = newWidth;
      _height = newHeight;

      // Notify parent widget of the updated dimensions
      widget.onUpdate(
        widget.index,
        _left,
        _top,
        _width,
        _height,
        widget.canvasCommonItemProperties.name,
        widget.canvasCommonItemProperties.description,
        widget.canvasCommonItemProperties.text,
        _rotationAngle,
        widget.canvasCommonItemProperties.deviceName,
        widget.canvasCommonItemProperties.groupName,
        widget.canvasCommonItemProperties.tagName,
      );
    });
  }

  Widget _buildRotationHandle() {
    return Positioned(
      left: 1,
      top: 1,
      child: GestureDetector(
        onPanUpdate: (details) => _updateRotation(details.delta.dx),
        child: const Icon(
          Icons.rotate_right,
          color: Color.fromARGB(255, 107, 107, 107),
          size: 16.0,
        ),
      ),
    );
  }

  void _updateRotation(double deltaX) {
    setState(() {
      // Update rotation in degrees
      _rotationDegrees = (_rotationDegrees + deltaX).roundToDouble() % 360;
      print('Rotation Degrees: $_rotationDegrees');
      // Notify parent widget of the updated rotation
      widget.onUpdate(
        widget.index,
        _left,
        _top,
        _width,
        _height,
        widget.canvasCommonItemProperties.name,
        widget.canvasCommonItemProperties.description,
        widget.canvasCommonItemProperties.text,
        _rotationDegrees, // Pass degrees directly
        widget.canvasCommonItemProperties.deviceName,
        widget.canvasCommonItemProperties.groupName,
        widget.canvasCommonItemProperties.tagName,
      );
    });
  }

  Widget _buildItemWidget() {
    final item = widget.item;

    if (item is TextBoxWidget ||
        item is DataBoxWidget ||
        item is DataBoxWidget2 ||
        item is DataBoxWidget3 ||
        item is DateTimeWidget1 ||
        item is DateTimeWidget2 ||
        item is DateTimeWidget3 ||
        item is DateTimeWidget4 ||
        item is DateTimeWidget5 ||
        item is DateTimeWidget6 ||
        item is DraggableSmartGauge ||
        item is DraggableSmartThermo ||
        item is DraggableSmartFan ||
        item is Image) {
      return item as Widget;
    }

    if (item is ShapeWidget) {
      return ShapeWidget(
        shape: item.shape,
        // color: widget.canvasCommonItemProperties.shapecolor, // Uncomment if needed
      );
    }

    return Container();
  }
}
