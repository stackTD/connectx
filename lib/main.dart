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
import './components/drawing_area/selection_store.dart';
import './components/settings/add_device_form.dart';
import './components/settings/group_form.dart';
import './components/connector_store.dart';
import './components/settings/log_store.dart';
import './Alarm/alarmsObjectTray.dart';
import 'ui_components/ThemeManager.dart';
import 'core/constants/app_constants.dart';
import 'core/state/app_state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logStore = LogStore();
  final connectorStore = ConnectorStore(logStore);
  final selectionStore = SelectionStore();
  final appStateManager = AppStateManager();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: PieEditor(
        connectorStore: connectorStore,
        selectionStore: selectionStore,
        logStore: logStore,
        appStateManager: appStateManager,
      ),
    ),
  );
}

class PieEditor extends StatefulWidget {
  final ConnectorStore connectorStore;
  final SelectionStore selectionStore;
  final LogStore logStore;
  final AppStateManager appStateManager;

  static PieEditorState? of(BuildContext context) =>
      context.findAncestorStateOfType<PieEditorState>();

  const PieEditor({
    Key? key,
    required this.connectorStore,
    required this.selectionStore,
    required this.logStore,
    required this.appStateManager,
  }) : super(key: key);

  @override
  PieEditorState createState() => PieEditorState();
}

class PieEditorState extends State<PieEditor> {
  final ValueNotifier<String> statusNotifier =
      ValueNotifier<String>(AppConstants.defaultStatusText);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return MaterialApp(
          title: AppConstants.appTitle,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            // Add other light theme customizations
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color.fromARGB(218, 0, 0, 0),
            // Add other dark theme customizations
          ),
          themeMode: themeManager.themeMode,
          home: Observer(
            builder: (_) => Scaffold(
              body: Column(
                children: [
                  // Header Bar
                  UIHeaderBar(),
                  // Main content area
                  Expanded(
                    child: Row(
                      children: [
                        // UIMasterSideMenu Column with buttons
                        UIMasterSideMenu(
                          onButtonPressed: widget.appStateManager.toggleColumn,
                        ),
                        // Conditional rendering based on app state
                        if (widget.appStateManager.showSecondColumn1) ...[
                          _buildSettingsSection(),
                        ] else if (widget.appStateManager.showAlarms) ...[
                          Expanded(
                            child: AlarmObjectTray(),
                          ),
                        ] else ...[
                          ..._buildMainWorkspaceSection(),
                        ],
                      ],
                    ),
                  ),
                  UIStatusBar(statusNotifier: statusNotifier)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the settings section with forms
  Widget _buildSettingsSection() {
    return Expanded(
      child: Row(
        children: [
          UiSettingsOption(
            hasSettingsBeenOpened: widget.appStateManager.showSecondColumn1,
            showAddForm: widget.appStateManager.showAddForm,
            showAddGroupForm: widget.appStateManager.showAddGroupForm,
            connectorStore: widget.connectorStore,
            logStore: widget.logStore,
          ),
          if (widget.appStateManager.showAddDeviceForm)
            Expanded(
              child: AddDeviceForm(
                onSave: widget.appStateManager.closeForm,
                onCancel: widget.appStateManager.closeForm,
              ),
            ),
          if (widget.appStateManager.showGroupForm)
            Expanded(
              child: GroupForm(
                onSave: widget.appStateManager.closeGroupForm,
                onCancel: widget.appStateManager.closeGroupForm,
                deviceName: widget.appStateManager.selectedDeviceName!,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the main workspace section with canvas and properties
  List<Widget> _buildMainWorkspaceSection() {
    return [
      UIObjectDrawer(
        connectorStore: widget.connectorStore,
        selectionStore: widget.selectionStore,
      ),
      Expanded(
        child: UICanvasArea(
          selectionStore: widget.selectionStore,
          connectorStore: widget.connectorStore,
          hasSettingsBeenOpened: widget.appStateManager.hasSettingsBeenOpened,
          hasAlarmsBeenOpened: widget.appStateManager.hasAlarmsBeenOpened,
          statusNotifier: statusNotifier,
        ),
      ),
      UIPropertiesMenu(
        selectionStore: widget.selectionStore,
      ),
    ];
  }

  @override
  void dispose() {
    statusNotifier.dispose();
    super.dispose();
  }
}
