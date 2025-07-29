// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connector_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConnectorStore on _ConnectorStore, Store {
  late final _$registerValuesAtom =
      Atom(name: '_ConnectorStore.registerValues', context: context);

  @override
  ObservableMap<String, String> get registerValues {
    _$registerValuesAtom.reportRead();
    return super.registerValues;
  }

  @override
  set registerValues(ObservableMap<String, String> value) {
    _$registerValuesAtom.reportWrite(value, super.registerValues, () {
      super.registerValues = value;
    });
  }

  late final _$streamDataAtom =
      Atom(name: '_ConnectorStore.streamData', context: context);

  @override
  String? get streamData {
    _$streamDataAtom.reportRead();
    return super.streamData;
  }

  @override
  set streamData(String? value) {
    _$streamDataAtom.reportWrite(value, super.streamData, () {
      super.streamData = value;
    });
  }

  late final _$isConnectedAtom =
      Atom(name: '_ConnectorStore.isConnected', context: context);

  @override
  bool get isConnected {
    _$isConnectedAtom.reportRead();
    return super.isConnected;
  }

  @override
  set isConnected(bool value) {
    _$isConnectedAtom.reportWrite(value, super.isConnected, () {
      super.isConnected = value;
    });
  }

  late final _$connectedDeviceConfigAtom =
      Atom(name: '_ConnectorStore.connectedDeviceConfig', context: context);

  @override
  Map<String, dynamic>? get connectedDeviceConfig {
    _$connectedDeviceConfigAtom.reportRead();
    return super.connectedDeviceConfig;
  }

  @override
  set connectedDeviceConfig(Map<String, dynamic>? value) {
    _$connectedDeviceConfigAtom.reportWrite(value, super.connectedDeviceConfig,
        () {
      super.connectedDeviceConfig = value;
    });
  }

  late final _$loadDeviceConfigAsyncAction =
      AsyncAction('_ConnectorStore.loadDeviceConfig', context: context);

  @override
  Future<Map<String, dynamic>> loadDeviceConfig() {
    return _$loadDeviceConfigAsyncAction.run(() => super.loadDeviceConfig());
  }

  late final _$connectAsyncAction =
      AsyncAction('_ConnectorStore.connect', context: context);

  @override
  Future<void> connect(String deviceName) {
    return _$connectAsyncAction.run(() => super.connect(deviceName));
  }

  late final _$connectAndReadAsyncAction =
      AsyncAction('_ConnectorStore.connectAndRead', context: context);

  @override
  Future<void> connectAndRead(String deviceName) {
    return _$connectAndReadAsyncAction
        .run(() => super.connectAndRead(deviceName));
  }

  late final _$_ConnectorStoreActionController =
      ActionController(name: '_ConnectorStore', context: context);

  @override
  void updateData(String receivedData) {
    final _$actionInfo = _$_ConnectorStoreActionController.startAction(
        name: '_ConnectorStore.updateData');
    try {
      return super.updateData(receivedData);
    } finally {
      _$_ConnectorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startReading() {
    final _$actionInfo = _$_ConnectorStoreActionController.startAction(
        name: '_ConnectorStore.startReading');
    try {
      return super.startReading();
    } finally {
      _$_ConnectorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void readRegister(String registerToRead) {
    final _$actionInfo = _$_ConnectorStoreActionController.startAction(
        name: '_ConnectorStore.readRegister');
    try {
      return super.readRegister(registerToRead);
    } finally {
      _$_ConnectorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void readD10Value() {
    final _$actionInfo = _$_ConnectorStoreActionController.startAction(
        name: '_ConnectorStore.readD10Value');
    try {
      return super.readD10Value();
    } finally {
      _$_ConnectorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disconnect() {
    final _$actionInfo = _$_ConnectorStoreActionController.startAction(
        name: '_ConnectorStore.disconnect');
    try {
      return super.disconnect();
    } finally {
      _$_ConnectorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
registerValues: ${registerValues},
streamData: ${streamData},
isConnected: ${isConnected},
connectedDeviceConfig: ${connectedDeviceConfig}
    ''';
  }
}
