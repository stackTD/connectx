import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../components/settings/log_store.dart';

part 'connector_store.g.dart'; // Ensure that this file is generated correctly

class ConnectorStore = _ConnectorStore with _$ConnectorStore;

abstract class _ConnectorStore with Store {
  // Add this method to extract register addresses
  List<String> _getRegisterAddresses(Map<String, dynamic> deviceConfig) {
    List<String> registers = [];

    // Navigate through the Groups structure
    if (deviceConfig.containsKey('Groups')) {
      deviceConfig['Groups'].forEach((groupName, groupData) {
        if (groupData.containsKey('Tags')) {
          groupData['Tags'].forEach((tagName, tagData) {
            if (tagData.containsKey('R_address')) {
              registers.add(tagData['R_address']);
            }
          });
        }
      });
    }
    print("list of registers: $registers");
    return registers;
  }

  Socket? _socket;
  Timer? _timer;
  final LogStore logStore;
  bool _isReading = false;
  final Map<String, dynamic> _registerValues = {};
  // String registerToRead = 'D20';
  late SharedPreferences _loadedDeviceConfig;
  @observable
  ObservableMap<String, String> registerValues =
      ObservableMap<String, String>();

  @observable
  String? streamData;

  @observable
  bool isConnected = false;

  @observable
  Map<String, dynamic>? connectedDeviceConfig;

  _ConnectorStore(this.logStore) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _loadedDeviceConfig = await SharedPreferences.getInstance();
  }

  @action
  void updateData(String receivedData) {
    try {
      // Split the received data into register and value if it contains both
      List<String> parts = receivedData.split(':');
      if (parts.length == 2) {
        String register = parts[0].trim();
        String value = parts[1].trim();
        registerValues[register] = value;
        // print('Updated register $register with value $value');
      } else {
        print('Invalid data format received: $receivedData');
      }
    } catch (e) {
      print('Error processing data: $e');
      logStore.addLog('Error processing data: $e');
    }
  }

  @action
  Future<Map<String, dynamic>> loadDeviceConfig() async {
    try {
      final file = File('device_conf.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(contents);
        print('Step_1@ ConnectorStore: Loaded device configuration');
        logStore.addLog('Device configuration loaded successfully');
        return jsonData;
      } else {
        print('ConnectorStore: File not found: device_conf.json');
        logStore.addLog(
            'Configuration file not found. Please check the dependencies');
        return {};
      }
    } catch (e) {
      print('ConnectorStore: Error loading device configuration: $e');
      logStore.addLog('Error loading device configuration: $e');
      return {};
    }
  }

  @action
  Future<void> connect(String deviceName) async {
    try {
      if (isConnected) {
        print('connectorStore: Already connected to PLC');
        return;
      }

      final deviceConfig = await loadDeviceConfig();
      final deviceDetails = deviceConfig[deviceName];

      if (deviceDetails != null) {
        connectedDeviceConfig = {deviceName: deviceDetails};
        await _loadedDeviceConfig.setString(
            'connectedDeviceConfig', jsonEncode(connectedDeviceConfig));

        // print(
        //     'Connector store: Saved device configuration as connectedDeviceConfig:');
        print(
            'Connector Store: Connected PLC details: ${jsonEncode(connectedDeviceConfig)}');

        final String hostIp = deviceDetails['host_ip'];
        final int portNumber = deviceDetails['port_number'];

        _socket = await Socket.connect(hostIp, portNumber);
        isConnected = true;
        print(
            'Step_2@ConnectorStore: Connected to the PLC at $hostIp:$portNumber');
        logStore.addLog('Connected to PLC at $hostIp:$portNumber');
      } else {
        throw Exception('Device configuration not found for $deviceName');
      }
    } catch (e) {
      print('connectorStore: Connection error: $e');
      logStore.addLog('Connection error: $e');
      isConnected = false;
      rethrow;
    }
  }

  @action
  void startReading() {
    if (!isConnected || _socket == null || connectedDeviceConfig == null) {
      print('connectorStore: Cannot start reading - not connected to PLC');
      return;
    }

    _socket!.listen(
      (data) {
        String receivedData = String.fromCharCodes(data).trim();
        logStore.addLog(
            'Received data: $receivedData from PLC, Type: ${receivedData.runtimeType}');
        updateData(receivedData);
        print
            // 'connectorStore: Received data: $receivedData from PLC, Type: ${receivedData.runtimeType}');
            ('connectorStore: Received data: $receivedData from PLC');
      },
      onError: (error) {
        print('connectorStore: Error: $error');
        logStore.addLog('Error faced while fetching data: $error');
        _socket?.destroy();
        isConnected = false;
      },
      onDone: () {
        print('connectorStore: Server closed the connection');
        logStore.addLog('Server closed the connection');
        _socket?.destroy();
        isConnected = false;
      },
    );

    // Get registers dynamically from connected device config
    final deviceData = connectedDeviceConfig!.values.first;
    final registers = _getRegisterAddresses(deviceData);

    if (registers.isEmpty) {
      print('connectorStore: No registers found in device configuration');
      return;
    }

    // Add delay between register reads
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      for (var register in registers) {
        readRegister(register);
        await Future.delayed(Duration(milliseconds: 100));
      }
    });
  }

  @action
  void readRegister(String registerToRead) {
    if (_socket != null) {
      // print(
      //     'Step_3@ connectorStore: Reading register request sent: $registerToRead');
      _socket?.write("$registerToRead\n");
    }
  }

  @action
  Future<void> connectAndRead(String deviceName) async {
    await connect(deviceName);
    startReading();
  }

  @action
  void readD10Value() {
    if (_socket != null) {
      _socket?.write("D10\n");
    }
  }

  @action
  void disconnect() {
    _socket?.close();
    stopRegisterReads();
    if (_socket != null) {
      _socket?.destroy();
      _socket = null;
    }
    _timer?.cancel();
    isConnected = false;
    isConnected = false;
    streamData = null;
    print('connectorStore: Disconnected from PLC server');
    logStore.addLog('Disconnected from PLC server');
  }

  void stopRegisterReads() {
    _timer?.cancel();
    _timer = null;
    _registerValues.clear();
    _isReading = false;
  }

  // Add this method to clear stored data
  Future<void> clearConnectedDeviceConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connectedDeviceConfig');
  }

  // Override dispose to clear data when app closes
  void dispose() async {
    await clearConnectedDeviceConfig(); // Make sure to wait for the clear operation
  }
}
