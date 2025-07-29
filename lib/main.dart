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
import 'core/constants/app_constants.dart';
import 'core/state/app_state_manager.dart';
import 'core/services/theme_service.dart';
import 'core/services/error_service.dart';
import 'core/widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final themeService = ThemeService();
  final errorService = ErrorService();
  
  // Initialize stores
  final logStore = LogStore();
  final connectorStore = ConnectorStore(logStore);
  final selectionStore = SelectionStore();
  final appStateManager = AppStateManager();

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: PieEditor(
        connectorStore: connectorStore,
        selectionStore: selectionStore,
        logStore: logStore,
        appStateManager: appStateManager,
        errorService: errorService,
      ),
    ),
  );
}

class PieEditor extends StatefulWidget {
  final ConnectorStore connectorStore;
  final SelectionStore selectionStore;
  final LogStore logStore;
  final AppStateManager appStateManager;
  final ErrorService errorService;

  static PieEditorState? of(BuildContext context) =>
      context.findAncestorStateOfType<PieEditorState>();

  const PieEditor({
    Key? key,
    required this.connectorStore,
    required this.selectionStore,
    required this.logStore,
    required this.appStateManager,
    required this.errorService,
  }) : super(key: key);

  @override
  PieEditorState createState() => PieEditorState();
}

class PieEditorState extends State<PieEditor> {
  final ValueNotifier<String> statusNotifier =
      ValueNotifier<String>(AppConstants.defaultStatusText);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: AppConstants.appTitle,
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          home: ErrorBoundary(
            errorTitle: 'Application Error',
            errorMessage: 'The SCADA ConnectX application encountered an error. Please try restarting.',
            child: Observer(
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
                              child: ErrorBoundary(
                                errorTitle: 'Alarms Error',
                                errorMessage: 'There was an error loading the alarms panel.',
                                child: AlarmObjectTray(),
                              ),
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
          ),
        );
      },
    );
  }

  /// Builds the settings section with forms
  Widget _buildSettingsSection() {
    return ErrorBoundary(
      errorTitle: 'Settings Error',
      errorMessage: 'There was an error loading the settings panel.',
      child: Expanded(
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
      ),
    );
  }

  /// Builds the main workspace section with canvas and properties
  List<Widget> _buildMainWorkspaceSection() {
    return [
      ErrorBoundary(
        errorTitle: 'Object Drawer Error',
        errorMessage: 'There was an error loading the object drawer.',
        child: UIObjectDrawer(
          connectorStore: widget.connectorStore,
          selectionStore: widget.selectionStore,
        ),
      ),
      Expanded(
        child: ErrorBoundary(
          errorTitle: 'Canvas Error',
          errorMessage: 'There was an error loading the canvas area.',
          child: UICanvasArea(
            selectionStore: widget.selectionStore,
            connectorStore: widget.connectorStore,
            hasSettingsBeenOpened: widget.appStateManager.hasSettingsBeenOpened,
            hasAlarmsBeenOpened: widget.appStateManager.hasAlarmsBeenOpened,
            statusNotifier: statusNotifier,
          ),
        ),
      ),
      ErrorBoundary(
        errorTitle: 'Properties Error',
        errorMessage: 'There was an error loading the properties panel.',
        child: UIPropertiesMenu(
          selectionStore: widget.selectionStore,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    statusNotifier.dispose();
    super.dispose();
  }
}
