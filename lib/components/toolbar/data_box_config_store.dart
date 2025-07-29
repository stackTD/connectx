// data_box_config_store.dart
import 'package:mobx/mobx.dart';

part 'data_box_config_store.g.dart';

class DataBoxConfigStore = _DataBoxConfigStore with _$DataBoxConfigStore;

abstract class _DataBoxConfigStore with Store {
  @observable
  String deviceName = '';

  @observable
  String groupName = '';

  @observable
  String tagName = '';

  @action
  void updateConfig(Map<String, dynamic> config) {
    deviceName = config['deviceName']?.toString() ?? '';
    groupName = config['groupName']?.toString() ?? '';
    tagName = config['tagName']?.toString() ?? '';
  }
}
