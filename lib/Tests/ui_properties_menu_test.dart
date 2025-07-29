// test/ui_properties_menu_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';
import '../components/drawing_area/item_state_managment.dart';
import '../components/drawing_area/selection_store.dart';
import '../components/connector_store.dart';
import '../ui_components/UIPropertiesMenu.dart';
import '../components/settings/log_store.dart';

void main() {
  group('UIPropertiesMenu Source Data Flow Tests', () {
    late SelectionStore selectionStore;
    late CanvasItemStateManager stateManager;
    late BuildContext context;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      selectionStore = SelectionStore();
      // Mock context
      final builder = Builder(builder: (BuildContext ctx) {
        context = ctx;
        return Container();
      });

      stateManager = CanvasItemStateManager(
        context: context,
        items: [],
        itemsState: [],
        onStateChange: (items, state) {},
        selectionStore: selectionStore,
        connectorStore: ConnectorStore(LogStore()),
      );
    });

    testWidgets('Updates source properties and saves to preferences',
        (WidgetTester tester) async {
      // Create test data
      final sourceData = {
        'deviceName': 'Device1',
        'groupName': 'Group1',
        'tagName': 'Tag1'
      };

      // Build widget
      await tester.pumpWidget(MaterialApp(
        home: UIPropertiesMenu(
          selectionStore: selectionStore,
        ),
      ));

      // Simulate dropdown selections
      await tester.tap(find.byKey(Key('deviceDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Device1').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('groupDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Group1').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('tagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tag1').last);
      await tester.pumpAndSettle();

      // Tap update button
      await tester.tap(find.text('Update'));
      await tester.pump();

      // Verify selection store updated
      expect(selectionStore.selectedItem?['source'], equals(sourceData));

      // Verify data saved to preferences
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('savedItem');
      expect(savedData, contains('"deviceName":"Device1"'));
      expect(savedData, contains('"groupName":"Group1"'));
      expect(savedData, contains('"tagName":"Tag1"'));
    });

    test('SelectionStore updates trigger UICanvasArea updates', () {
      // Setup
      final sourceData = {
        'source': {
          'deviceName': 'Device1',
          'groupName': 'Group1',
          'tagName': 'Tag1'
        }
      };

      // Update selection store
      selectionStore.updateSelectedItem('source', json.encode(sourceData));

      // Verify canvas area received updates
      final canvasState = stateManager.getCanvasObjectState(0);
      expect(canvasState['deviceName'], equals('Device1'));
      expect(canvasState['groupName'], equals('Group1'));
      expect(canvasState['tagName'], equals('Tag1'));
    });

    test('Source properties persist after save and load', () async {
      // Setup test data
      final sourceData = {
        'deviceName': 'Device1',
        'groupName': 'Group1',
        'tagName': 'Tag1'
      };

      // Save to preferences
      await stateManager.saveItemsToPrefs();

      // Clear current state
      stateManager.clearPrefs();

      // Load from preferences
      await stateManager.loadItemsFromPrefs();

      // Verify data restored correctly
      final loadedState = stateManager.getCanvasObjectState(0);
      expect(loadedState['deviceName'], equals('Device1'));
      expect(loadedState['groupName'], equals('Group1'));
      expect(loadedState['tagName'], equals('Tag1'));
    });
  });
}
