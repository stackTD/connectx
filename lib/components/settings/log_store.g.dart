// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LogStore on _LogStore, Store {
  late final _$logsAtom = Atom(name: '_LogStore.logs', context: context);

  @override
  ObservableList<String> get logs {
    _$logsAtom.reportRead();
    return super.logs;
  }

  @override
  set logs(ObservableList<String> value) {
    _$logsAtom.reportWrite(value, super.logs, () {
      super.logs = value;
    });
  }

  late final _$_LogStoreActionController =
      ActionController(name: '_LogStore', context: context);

  @override
  void addLog(String log) {
    final _$actionInfo =
        _$_LogStoreActionController.startAction(name: '_LogStore.addLog');
    try {
      return super.addLog(log);
    } finally {
      _$_LogStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLogs() {
    final _$actionInfo =
        _$_LogStoreActionController.startAction(name: '_LogStore.clearLogs');
    try {
      return super.clearLogs();
    } finally {
      _$_LogStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
logs: ${logs}
    ''';
  }
}
