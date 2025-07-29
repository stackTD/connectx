// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_manager.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStateManager on _AppStateManager, Store {
  late final _$showSecondColumn1Atom =
      Atom(name: '_AppStateManager.showSecondColumn1', context: context);

  @override
  bool get showSecondColumn1 {
    _$showSecondColumn1Atom.reportRead();
    return super.showSecondColumn1;
  }

  @override
  set showSecondColumn1(bool value) {
    _$showSecondColumn1Atom.reportWrite(value, super.showSecondColumn1, () {
      super.showSecondColumn1 = value;
    });
  }

  late final _$showAddDeviceFormAtom =
      Atom(name: '_AppStateManager.showAddDeviceForm', context: context);

  @override
  bool get showAddDeviceForm {
    _$showAddDeviceFormAtom.reportRead();
    return super.showAddDeviceForm;
  }

  @override
  set showAddDeviceForm(bool value) {
    _$showAddDeviceFormAtom.reportWrite(value, super.showAddDeviceForm, () {
      super.showAddDeviceForm = value;
    });
  }

  late final _$showGroupFormAtom =
      Atom(name: '_AppStateManager.showGroupForm', context: context);

  @override
  bool get showGroupForm {
    _$showGroupFormAtom.reportRead();
    return super.showGroupForm;
  }

  @override
  set showGroupForm(bool value) {
    _$showGroupFormAtom.reportWrite(value, super.showGroupForm, () {
      super.showGroupForm = value;
    });
  }

  late final _$showAlarmsAtom =
      Atom(name: '_AppStateManager.showAlarms', context: context);

  @override
  bool get showAlarms {
    _$showAlarmsAtom.reportRead();
    return super.showAlarms;
  }

  @override
  set showAlarms(bool value) {
    _$showAlarmsAtom.reportWrite(value, super.showAlarms, () {
      super.showAlarms = value;
    });
  }

  late final _$selectedDeviceNameAtom =
      Atom(name: '_AppStateManager.selectedDeviceName', context: context);

  @override
  String? get selectedDeviceName {
    _$selectedDeviceNameAtom.reportRead();
    return super.selectedDeviceName;
  }

  @override
  set selectedDeviceName(String? value) {
    _$selectedDeviceNameAtom.reportWrite(value, super.selectedDeviceName, () {
      super.selectedDeviceName = value;
    });
  }

  late final _$hasSettingsBeenOpenedAtom =
      Atom(name: '_AppStateManager.hasSettingsBeenOpened', context: context);

  @override
  bool get hasSettingsBeenOpened {
    _$hasSettingsBeenOpenedAtom.reportRead();
    return super.hasSettingsBeenOpened;
  }

  @override
  set hasSettingsBeenOpened(bool value) {
    _$hasSettingsBeenOpenedAtom.reportWrite(value, super.hasSettingsBeenOpened,
        () {
      super.hasSettingsBeenOpened = value;
    });
  }

  late final _$hasAlarmsBeenOpenedAtom =
      Atom(name: '_AppStateManager.hasAlarmsBeenOpened', context: context);

  @override
  bool get hasAlarmsBeenOpened {
    _$hasAlarmsBeenOpenedAtom.reportRead();
    return super.hasAlarmsBeenOpened;
  }

  @override
  set hasAlarmsBeenOpened(bool value) {
    _$hasAlarmsBeenOpenedAtom.reportWrite(value, super.hasAlarmsBeenOpened, () {
      super.hasAlarmsBeenOpened = value;
    });
  }

  late final _$statusTextAtom =
      Atom(name: '_AppStateManager.statusText', context: context);

  @override
  String get statusText {
    _$statusTextAtom.reportRead();
    return super.statusText;
  }

  @override
  set statusText(String value) {
    _$statusTextAtom.reportWrite(value, super.statusText, () {
      super.statusText = value;
    });
  }

  late final _$_AppStateManagerActionController =
      ActionController(name: '_AppStateManager', context: context);

  @override
  void toggleColumn(String column) {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.toggleColumn');
    try {
      return super.toggleColumn(column);
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showAddForm() {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.showAddForm');
    try {
      return super.showAddForm();
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeForm() {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.closeForm');
    try {
      return super.closeForm();
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showAddGroupForm(String deviceName) {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.showAddGroupForm');
    try {
      return super.showAddGroupForm(deviceName);
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeGroupForm() {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.closeGroupForm');
    try {
      return super.closeGroupForm();
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateStatus(String newStatus) {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.updateStatus');
    try {
      return super.updateStatus(newStatus);
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetState() {
    final _$actionInfo = _$_AppStateManagerActionController.startAction(
        name: '_AppStateManager.resetState');
    try {
      return super.resetState();
    } finally {
      _$_AppStateManagerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showSecondColumn1: ${showSecondColumn1},
showAddDeviceForm: ${showAddDeviceForm},
showGroupForm: ${showGroupForm},
showAlarms: ${showAlarms},
selectedDeviceName: ${selectedDeviceName},
hasSettingsBeenOpened: ${hasSettingsBeenOpened},
hasAlarmsBeenOpened: ${hasAlarmsBeenOpened},
statusText: ${statusText}
    ''';
  }
}