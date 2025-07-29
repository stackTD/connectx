import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'ui_components/UIHeaderBar.dart';
import 'ui_components/UIStatusBar.dart';
import 'package:provider/provider.dart';
import 'ui_components/UITitleBar.dart';
import 'ui_components/UIMasterSideMenu.dart';
import 'ui_components/UISettingsOption.dart';
import 'ui_components/UIObjectDrawer.dart';
import 'ui_components/UICanvasArea.dart';
import 'ui_components/UIPropertiesMenu.dart';
import './components/drawing_area/selection_store.dart'; // Import the store
import './components/settings/add_device_form.dart';
import './components/settings/group_form.dart';
import './components/connector_store.dart';
import './components/settings/log_store.dart';
import './Alarm/alarmsObjectTray.dart';
import 'ui_components/ThemeManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logStore = LogStore();
  final connectorStore =
      ConnectorStore(logStore); // Instantiate once and pass it down
  final selectionStore = SelectionStore(); // Instantiate once and pass it down

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: PieEditor(
        connectorStore: connectorStore,
        selectionStore: selectionStore,
        logStore: logStore,
      ),
    ),
  );
}

class PieEditor extends StatefulWidget {
  final ConnectorStore connectorStore;
  final SelectionStore selectionStore;
  final LogStore logStore;

  static PieEditorState? of(BuildContext context) =>
      context.findAncestorStateOfType<PieEditorState>();

  const PieEditor({
    Key? key,
    required this.connectorStore,
    required this.selectionStore,
    required this.logStore,
  }) : super(key: key);

  @override
  PieEditorState createState() => PieEditorState();
}

class PieEditorState extends State<PieEditor> {
  // ThemeMode _themeMode = ThemeMode.light;

  // void setThemeMode(ThemeMode mode) {
  //   setState(() {
  //     _themeMode = mode;
  //   });
  // }

  bool showSecondColumn1 = false;
  bool showAddDeviceForm = false;
  bool showGroupForm = false;
  bool showAlarms = false; // Add new state variable
  String? _selectedDeviceName;
  bool hasSettingsBeenOpened = false;
  bool hasAlarmsBeenOpened = false;
  final ValueNotifier<String> statusNotifier =
      ValueNotifier<String>('Status Bar');

  void toggleColumn(String column) {
    setState(() {
      if (column == 'Settings') {
        showSecondColumn1 = true;
        showAlarms = false;
        hasSettingsBeenOpened = true;
        showAddDeviceForm = false;
        showGroupForm = false;
      } else if (column == 'Simulation') {
        showSecondColumn1 = false;
        showAlarms = false;
        showAddDeviceForm = false;
        showGroupForm = false;
      } else if (column == 'Alarms') {
        showSecondColumn1 = false;
        showAlarms = true;
        hasAlarmsBeenOpened = true;
        showAddDeviceForm = false;
        showGroupForm = false;
      }
    });
  }

  void showAddForm() {
    setState(() {
      showAddDeviceForm = true; // Show the form
    });
  }

  void closeForm() {
    setState(() {
      showAddDeviceForm = false; // Hide the form
    });
  }

  void showAddGroupForm(String deviceName) {
    setState(() {
      showGroupForm = true; // Show the group form
      _selectedDeviceName = deviceName; // Store the selected device name
    });
  }

  void closeGroupForm() {
    setState(() {
      showGroupForm = false; // Hide the group form
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return MaterialApp(
          title: 'SL Scada Application',
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            // Add other light theme customizations
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color.fromARGB(218, 0, 0, 0),
            // Add other dark theme customizations
          ),
          themeMode: themeManager.themeMode,
          home: Scaffold(
            body: Column(
              children: [
                // UITitleBar(),
                // Header Bar
                UIHeaderBar(),
                // Main content area
                Expanded(
                  child: Row(
                    children: [
                      // UIMasterSideMenu Column with buttons
                      UIMasterSideMenu(onButtonPressed: toggleColumn),
                      // Conditional rendering of the second column or the form
                      if (showSecondColumn1) ...[
                        Expanded(
                          child: Row(
                            children: [
                              UiSettingsOption(
                                hasSettingsBeenOpened: showSecondColumn1,
                                showAddForm: showAddForm,
                                showAddGroupForm:
                                    showAddGroupForm, // Pass the missing callback
                                connectorStore: widget.connectorStore,
                                logStore: widget.logStore,
                              ),
                              if (showAddDeviceForm)
                                Expanded(
                                  child: AddDeviceForm(
                                    onSave: () {
                                      closeForm();
                                      toggleColumn(
                                          'Settings'); // Reopen SecondColumn1
                                    },
                                    onCancel: closeForm,
                                  ),
                                ),
                              if (showGroupForm)
                                Expanded(
                                  child: GroupForm(
                                    onSave: () {
                                      closeGroupForm();
                                      toggleColumn(
                                          'Settings'); // Reopen SecondColumn1
                                    },
                                    onCancel: closeGroupForm,
                                    deviceName: _selectedDeviceName!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ] else if (showAlarms) ...[
                        Expanded(
                          child:
                              AlarmObjectTray(), // Add ObjectTray when Alarms is selected
                        ),
                      ] else ...[
                        // Show SecondColumn2 with UICanvasArea and UIPropetiesMenu
                        UIObjectDrawer(
                          connectorStore: widget.connectorStore,
                          selectionStore: widget.selectionStore,
                        ),
                        Expanded(
                          child: UICanvasArea(
                            selectionStore: widget.selectionStore,
                            connectorStore: widget.connectorStore,
                            hasSettingsBeenOpened: hasSettingsBeenOpened,
                            hasAlarmsBeenOpened:
                                hasAlarmsBeenOpened, // Fix: was passing hasSettingsBeenOpened
                            statusNotifier: statusNotifier,
                          ), // Pass the state variable
                        ),
                        UIPropetiesMenu(
                          selectionStore:
                              widget.selectionStore, // Pass the store
                        ),
                      ],
                    ],
                  ),
                ),
                UIStatusBar(statusNotifier: statusNotifier)
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    statusNotifier.dispose();
    super.dispose();
  }
}
