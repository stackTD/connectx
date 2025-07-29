// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_box_config_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DataBoxConfigStore on _DataBoxConfigStore, Store {
  late final _$deviceNameAtom =
      Atom(name: '_DataBoxConfigStore.deviceName', context: context);

  @override
  String get deviceName {
    _$deviceNameAtom.reportRead();
    return super.deviceName;
  }

  @override
  set deviceName(String value) {
    _$deviceNameAtom.reportWrite(value, super.deviceName, () {
      super.deviceName = value;
    });
  }

  late final _$groupNameAtom =
      Atom(name: '_DataBoxConfigStore.groupName', context: context);

  @override
  String get groupName {
    _$groupNameAtom.reportRead();
    return super.groupName;
  }

  @override
  set groupName(String value) {
    _$groupNameAtom.reportWrite(value, super.groupName, () {
      super.groupName = value;
    });
  }

  late final _$tagNameAtom =
      Atom(name: '_DataBoxConfigStore.tagName', context: context);

  @override
  String get tagName {
    _$tagNameAtom.reportRead();
    return super.tagName;
  }

  @override
  set tagName(String value) {
    _$tagNameAtom.reportWrite(value, super.tagName, () {
      super.tagName = value;
    });
  }

  late final _$_DataBoxConfigStoreActionController =
      ActionController(name: '_DataBoxConfigStore', context: context);

  @override
  void updateConfig(Map<String, dynamic> config) {
    final _$actionInfo = _$_DataBoxConfigStoreActionController.startAction(
        name: '_DataBoxConfigStore.updateConfig');
    try {
      return super.updateConfig(config);
    } finally {
      _$_DataBoxConfigStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
deviceName: ${deviceName},
groupName: ${groupName},
tagName: ${tagName}
    ''';
  }
}
