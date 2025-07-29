import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../constants/app_constants.dart';

part 'app_state_manager.g.dart';

/// Central state management for the SCADA ConnectX application
/// Manages UI state, navigation, and form visibility
class AppStateManager = _AppStateManager with _$AppStateManager;

abstract class _AppStateManager with Store {
  // Column visibility states
  @observable
  bool showSecondColumn1 = false;
  
  @observable
  bool showAddDeviceForm = false;
  
  @observable
  bool showGroupForm = false;
  
  @observable
  bool showAlarms = false;
  
  // Device selection state
  @observable
  String? selectedDeviceName;
  
  // Navigation state tracking
  @observable
  bool hasSettingsBeenOpened = AppConstants.defaultHasSettingsBeenOpened;
  
  @observable
  bool hasAlarmsBeenOpened = AppConstants.defaultHasAlarmsBeenOpened;
  
  // Status notification
  @observable
  String statusText = AppConstants.defaultStatusText;
  
  /// Toggle between different main columns (Settings, Simulation, Alarms)
  @action
  void toggleColumn(String column) {
    switch (column) {
      case AppConstants.columnSettings:
        showSecondColumn1 = true;
        showAlarms = false;
        hasSettingsBeenOpened = true;
        showAddDeviceForm = false;
        showGroupForm = false;
        break;
      case AppConstants.columnSimulation:
        showSecondColumn1 = false;
        showAlarms = false;
        showAddDeviceForm = false;
        showGroupForm = false;
        break;
      case AppConstants.columnAlarms:
        showSecondColumn1 = false;
        showAlarms = true;
        hasAlarmsBeenOpened = true;
        showAddDeviceForm = false;
        showGroupForm = false;
        break;
    }
  }
  
  /// Show the add device form
  @action
  void showAddForm() {
    showAddDeviceForm = true;
  }
  
  /// Close the add device form and return to settings
  @action
  void closeForm() {
    showAddDeviceForm = false;
    toggleColumn(AppConstants.columnSettings);
  }
  
  /// Show the add group form for a specific device
  @action
  void showAddGroupForm(String deviceName) {
    showGroupForm = true;
    selectedDeviceName = deviceName;
  }
  
  /// Close the group form and return to settings
  @action
  void closeGroupForm() {
    showGroupForm = false;
    selectedDeviceName = null;
    toggleColumn(AppConstants.columnSettings);
  }
  
  /// Update the status text
  @action
  void updateStatus(String newStatus) {
    statusText = newStatus;
  }
  
  /// Reset all state to defaults
  @action
  void resetState() {
    showSecondColumn1 = false;
    showAddDeviceForm = false;
    showGroupForm = false;
    showAlarms = false;
    selectedDeviceName = null;
    hasSettingsBeenOpened = AppConstants.defaultHasSettingsBeenOpened;
    hasAlarmsBeenOpened = AppConstants.defaultHasAlarmsBeenOpened;
    statusText = AppConstants.defaultStatusText;
  }
}