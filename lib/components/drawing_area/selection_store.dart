import 'package:mobx/mobx.dart';

part 'selection_store.g.dart';

class SelectionStore = _SelectionStore with _$SelectionStore;

abstract class _SelectionStore with Store {
  @observable
  Map<String, dynamic>? selectedItem;
  @observable
  ObservableList<int> selectedIndices = ObservableList<int>();

  @action
  void updateSelection(Map<String, dynamic>? item) {
    selectedItem = item;
    // print(
    //     'Step@3: SelectionStore: received from drawing_area: {$selectedItem} ');
  }

  @action
  void addToSelection(int index) {
    if (!selectedIndices.contains(index)) {
      selectedIndices.add(index);
    }
  }

  @action
  void removeFromSelection(int index) {
    selectedIndices.remove(index);
  }

  @action
  void clearSelection() {
    selectedItem = null;
  }

  @action
  void updateSelectedItem(String key, dynamic newValue) {
    if (selectedItem != null) {
      // Create a new map with the updated value
      selectedItem = Map<String, dynamic>.from(selectedItem!);
      selectedItem![key] =
          newValue; // Use square bracket notation instead of update()

      print('SelectionStore: updated $key to $newValue');
    }
  }

  // @action
  // void updateSelectedItem(String key, dynamic newValue) {
  //   if (selectedItem != null) {
  //     if (key == 'source') {
  //       selectedItem = Map<String, dynamic>.from(selectedItem!)
  //         ..update(key, (value) => newValue);
  //     } else {
  //       selectedItem = Map<String, dynamic>.from(selectedItem!)
  //         ..update(key, (value) => newValue);
  //     }
  //     print('ConnectionStore: updated $key to $newValue');
  //   }
  // }

  @action
  void setSelectedIndices(List<int> indices) {
    selectedIndices.clear();
    selectedIndices.addAll(indices);
  }

  @action
  void clearSelectedIndices() {
    selectedIndices.clear();
  }
}
