// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SelectionStore on _SelectionStore, Store {
  late final _$selectedItemAtom =
      Atom(name: '_SelectionStore.selectedItem', context: context);

  @override
  Map<String, dynamic>? get selectedItem {
    _$selectedItemAtom.reportRead();
    return super.selectedItem;
  }

  @override
  set selectedItem(Map<String, dynamic>? value) {
    _$selectedItemAtom.reportWrite(value, super.selectedItem, () {
      super.selectedItem = value;
    });
  }

  late final _$selectedIndicesAtom =
      Atom(name: '_SelectionStore.selectedIndices', context: context);

  @override
  ObservableList<int> get selectedIndices {
    _$selectedIndicesAtom.reportRead();
    return super.selectedIndices;
  }

  @override
  set selectedIndices(ObservableList<int> value) {
    _$selectedIndicesAtom.reportWrite(value, super.selectedIndices, () {
      super.selectedIndices = value;
    });
  }

  late final _$_SelectionStoreActionController =
      ActionController(name: '_SelectionStore', context: context);

  @override
  void updateSelection(Map<String, dynamic>? item) {
    final _$actionInfo = _$_SelectionStoreActionController.startAction(
        name: '_SelectionStore.updateSelection');
    try {
      return super.updateSelection(item);
    } finally {
      _$_SelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$_SelectionStoreActionController.startAction(
        name: '_SelectionStore.clearSelection');
    try {
      return super.clearSelection();
    } finally {
      _$_SelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSelectedItem(String key, dynamic newValue) {
    final _$actionInfo = _$_SelectionStoreActionController.startAction(
        name: '_SelectionStore.updateSelectedItem');
    try {
      return super.updateSelectedItem(key, newValue);
    } finally {
      _$_SelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedIndices(List<int> indices) {
    final _$actionInfo = _$_SelectionStoreActionController.startAction(
        name: '_SelectionStore.setSelectedIndices');
    try {
      return super.setSelectedIndices(indices);
    } finally {
      _$_SelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedIndices() {
    final _$actionInfo = _$_SelectionStoreActionController.startAction(
        name: '_SelectionStore.clearSelectedIndices');
    try {
      return super.clearSelectedIndices();
    } finally {
      _$_SelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedItem: ${selectedItem},
selectedIndices: ${selectedIndices}
    ''';
  }
}
