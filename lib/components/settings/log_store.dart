// log_store.dart
import 'package:mobx/mobx.dart';

part 'log_store.g.dart';

class LogStore = _LogStore with _$LogStore;

abstract class _LogStore with Store {
  @observable
  ObservableList<String> logs = ObservableList<String>();

  @action
  void addLog(String log) {
    logs.insert(0, "${DateTime.now().toString()}: $log");
    if (logs.length > 100) {
      logs.removeLast();
    }
  }

  @action
  void clearLogs() {
    logs.clear();
  }
}
