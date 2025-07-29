import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../components/toolbar/shape_type.dart';
import '../components/toolbar/datetime1.dart';
import '../components/toolbar/datetime2.dart';
import '../components/toolbar/date1.dart';
import '../components/toolbar/time1.dart';
import '../components/toolbar/time2.dart';
import '../components/toolbar/time3.dart';

import '../components/toolbar/draggable_shape.dart';
import '../components/toolbar/draggable_image.dart';
import '../components/connector_store.dart';
import '../components/drawing_area/selection_store.dart';
import '../components/toolbar/draggable_data_box.dart';
import '../components/toolbar/draggable_databox2.dart';
import '../components/toolbar/draggable_databox3.dart';
import '../components/toolbar/text_box_widget.dart';
import '../SmartWidgets/gauges/smart_gauge1.dart';
import '../SmartWidgets/gauges/smart_thermo1.dart';
import '../SmartWidgets/fan/smart_fan1.dart';

// Main widget for the UI Object Drawer
class UIObjectDrawer extends StatefulWidget {
  const UIObjectDrawer(
      {super.key, required this.connectorStore, required this.selectionStore});
  final ConnectorStore connectorStore;
  final SelectionStore selectionStore;

  @override
  _UIObjectDrawerState createState() => _UIObjectDrawerState();
}

class _UIObjectDrawerState extends State<UIObjectDrawer> {
  Color _selectedColor = Color.fromARGB(0, 217, 59, 59); // Default color
  bool _isExpanded = false; // State to track if the drawer is expanded
  final ScrollController _scrollController = ScrollController();
  List<String> _customImagePaths = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 131, 131, 131), // Background color

      child: Column(
        children: [
          _buildExpansionToggle(), // Toggle button to expand/collapse the drawer
          if (_isExpanded)
            Expanded(
                child: RawScrollbar(
                    thumbColor: Colors.white54,
                    radius: Radius.circular(20),
                    thickness: 5,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(children: [
                          _buildExpansionTile(
                              'Time & Date', _buildDateBoxContent()),
                          _buildExpansionTile('Data & Text Box',
                              _buildTextBoxContent()), // Text Box section
                          _buildExpansionTile('Shapes',
                              _buildShapesContent()), // Shapes section
                          _buildExpansionTile(
                            'Gauges',
                            _buildGridView([
                              // Add the smart gauge as first item
                              Container(
                                color: Color.fromARGB(255, 209, 205, 205),
                                child: Center(
                                  child: Draggable<String>(
                                    data: 'SmartGauge',
                                    feedback: Material(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        child: DraggableSmartGauge(
                                          initialValue: 50,
                                          color: Colors.white,
                                          connectorStore: widget.connectorStore,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      child: DraggableSmartGauge(
                                        initialValue: 50,
                                        color: Colors.white,
                                        connectorStore: widget.connectorStore,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                color: Color.fromARGB(255, 209, 205, 205),
                                child: Center(
                                  child: Draggable<String>(
                                    data: 'SmartThermo',
                                    feedback: Material(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        child: DraggableSmartThermo(
                                          initialValue: 50,
                                          // color: Colors.white,
                                          connectorStore: widget.connectorStore,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      child: DraggableSmartThermo(
                                        initialValue: 50,
                                        // color: Colors.white,
                                        connectorStore: widget.connectorStore,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              _buildDraggableImages([
                                // 'assets/image24.jpg',
                                'assets/image25.jpg',
                                'assets/image26.jpg',
                                'assets/image27.jpg',
                                'assets/image28.jpg',
                                'assets/image29.jpg',
                                'assets/image30.jpg',
                                'assets/image31.jpg',
                                // 'assets/image41.svg',
                              ]),
                            ]),
                          ),
                          _buildExpansionTile(
                              'Switches & Buttons',
                              _buildDraggableImages([
                                'assets/image32.jpg',
                                'assets/image33.jpg',
                                'assets/image34.jpg',
                                'assets/image35.jpg',
                                'assets/image36.avif',
                                'assets/image37.avif',
                                'assets/image38.avif',
                              ])),
                          _buildExpansionTile(
                              'Pipes',
                              _buildDraggableImages([
                                'assets/image8.png',
                                'assets/image9.png',
                                'assets/image10.png',
                                'assets/image11.png',
                                'assets/image12.png',
                                'assets/image13.png',
                                'assets/image14.png',
                                'assets/image15.png',
                                'assets/image16.png',
                              ])), // Pipes section
                          _buildExpansionTile(
                              'Fans',
                              _buildGridView([
                                // Add the smart gauge as first item
                                Container(
                                  color: Color.fromARGB(0, 255, 255, 255),
                                  child: Center(
                                    child: Draggable<String>(
                                      data: 'SmartFan',
                                      feedback: Material(
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          child: DraggableSmartFan(),
                                        ),
                                      ),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        child: DraggableSmartFan(),
                                      ),
                                    ),
                                  ),
                                ),
                                _buildDraggableImages([
                                  'assets/image1.png',
                                  'assets/image3.png',
                                  'assets/image4.png',
                                  'assets/image17.png',
                                ])
                              ])), // Fans section
                          _buildExpansionTile(
                              'Lights & bulbs',
                              _buildDraggableImages([
                                'assets/image40.jpg',
                                'assets/image39.jpg',
                              ])),
                          _buildExpansionTile(
                              'Motors',
                              _buildDraggableImages([
                                'assets/image5.png',
                                'assets/image6.png',
                                'assets/image7.png',
                                'assets/image18.png',
                                'assets/image19.png',
                              ])), // Motors section
                          _buildExpansionTile(
                              'Arrows',
                              _buildDraggableImages([
                                'assets/image20.png',
                                'assets/image21.png',
                                'assets/image22.png',
                                'assets/image23.png',
                              ])), // Arrows section],
                          _buildExpansionTile('Custom', _buildCustomImages([])),
                        ]))))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Widget to build the expansion toggle button
  Widget _buildExpansionToggle() {
    return IconButton(
      icon: Icon(
        _isExpanded ? Icons.menu_open : Icons.menu,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      tooltip: 'Object Drawer',
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded; // Toggle the expanded state
        });
      },
    );
  }

  Widget _buildExpansionTile(String title, Widget content) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 10,
      child: SingleChildScrollView(
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding: EdgeInsets.zero,
          backgroundColor: const Color.fromARGB(255, 149, 141, 141),
          collapsedBackgroundColor: Color.fromARGB(255, 209, 205, 205),
          children: [content],
        ),
      ),
    );
  }

  // Widget to build the content for the Text Box section
  Widget _buildTextBoxContent() {
    return _buildGridView([
      Draggable<String>(
        data: 'TextBox',
        feedback: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border.all(color: const Color.fromARGB(0, 158, 158, 158)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'Text Box',
              style: TextStyle(
                color: Color.fromARGB(255, 209, 205, 205),
                fontSize: 14,
              ),
            ),
          ),
        ),
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'Text Box',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),

      /////////////////////////// Data Box ///////////////////////////
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDataBox2(
            connectorStore: widget.connectorStore,
            color: Colors.white,
          ),
        ),
      ),

      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDataBox3(
            connectorStore: widget.connectorStore,
            color: Colors.white,
          ),
        ),
      ),

      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDataBox(
            connectorStore: widget.connectorStore,
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }

  Widget _buildDateBoxContent() {
    return _buildGridView([
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDateTimeBox5(
            color: Colors.white,
          ),
        ),
      ),
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDateTimeBox1(
            color: Colors.white,
          ),
        ),
      ),
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDateTimeBox2(
            color: const Color.fromARGB(255, 222, 243, 222),
          ),
        ),
      ),
      Container(
        color: Color.fromARGB(255, 187, 178, 224),
        child: Center(
          child: DraggableDateTimeBox3(
            color: Colors.white,
          ),
        ),
      ),
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDateTimeBox6(
            color: Colors.white,
          ),
        ),
      ),
      Container(
        color: Color.fromARGB(255, 209, 205, 205),
        child: Center(
          child: DraggableDateTimeBox4(
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }

  // Widget to build the content for the Shapes section
  Widget _buildShapesContent() {
    return _buildGridView([
      DraggableShape(
        shape: ShapeType.line,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.curvedLine,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.triangle,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.hexagon,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.square,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.trapezium,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.circle,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.ellipse,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.parallelogram,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
      DraggableShape(
        shape: ShapeType.roundedRectangle,
        color: _selectedColor,
        onSelected: (shape) => print('Selected shape: $shape'),
      ),
    ]);
  }

  // Helper function to build a grid view of draggable images
  Widget _buildDraggableImages(List<String> imagePaths) {
    return _buildGridView(
      imagePaths.map((path) => DraggableImage(imagePath: path)).toList(),
    );
  }

  Widget _buildCustomImages(List<String> imagePaths) {
    return Column(
      children: [
        // Import button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png'],
                  allowMultiple: true,
                );

                if (result != null) {
                  setState(() {
                    _customImagePaths.addAll(
                      result.paths
                          .where((path) => path != null)
                          .map((path) => path!),
                    );
                  });
                }
              } catch (e) {
                print('Error picking files: $e');
              }
            },
            icon: const Icon(Icons.drive_folder_upload_outlined, size: 16),
            label: const Text('Import', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 36),
            ),
          ),
        ),
        // Grid view of images
        _buildGridView(
          [
            ..._customImagePaths
                .map((path) => DraggableImage(
                      imagePath: path,
                      isLocalFile: true,
                    ))
                .toList(),
          ],
        ),
      ],
    );
  }

  // Widget to build a grid view with the given children
  Widget _buildGridView(List<Widget> children) {
    return Container(
      height: 100, // Height of the grid view
      color: const Color.fromARGB(255, 173, 169, 169), // Background color
      child: GridView.count(
        crossAxisCount: 2, // Number of columns
        padding: const EdgeInsets.all(10), // Padding around the grid
        crossAxisSpacing: 5, // Spacing between columns
        mainAxisSpacing: 5, // Spacing between rows
        shrinkWrap: true, // Shrink wrap the grid view
        children: children, // Children widgets
      ),
    );
  }
}
