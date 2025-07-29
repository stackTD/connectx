import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/settings/group_form.dart';
import '../components/settings/tag_form.dart';
import '../components/settings/add_device_form.dart';
// import '../components/settings/add_alarm_form.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../components/connector_store.dart';
import '../components/settings/log_store.dart';

class UiSettingsOption extends StatefulWidget {
  bool hasSettingsBeenOpened = false;
  final VoidCallback showAddForm;
  final void Function(String) showAddGroupForm;
  final ConnectorStore connectorStore;
  final LogStore logStore;
  static const String deviceConfigFile = 'device_conf.json';

  UiSettingsOption({
    required this.hasSettingsBeenOpened,
    required this.showAddForm,
    required this.showAddGroupForm,
    required this.connectorStore,
    required this.logStore,
    super.key,
  }) {
    hasSettingsBeenOpened = true;
  }

  @override
  _UiSettingsOptionState createState() => _UiSettingsOptionState();
}

class _UiSettingsOptionState extends State<UiSettingsOption> {
  List<String> _deviceNames = [];
  List<String> _alarmNames = [];
  Map<String, Map<String, dynamic>> _deviceGroups = {};
  final Set<String> _selectedDevices = {};
  late Stream<FileSystemEvent> _fileStream;
  bool _isFormVisible = false; // State variable to control form visibility
  Map<String, dynamic>? _currentFormData;
  bool _isConnected = false;
  bool _connectionError = false;
  bool _showLogs = false; // Add this state variable

  @override
  void initState() {
    super.initState();
    _fileStream = File(UiSettingsOption.deviceConfigFile).watch();
    _fileStream.listen((event) {
      // print('File change detected: ${event.type}');
      if (event.type == FileSystemEvent.modify) {
        _loadDeviceNames();
      }
    });
    _loadFormState();
    _loadDeviceNames();
    _loadSelectedDevices();
    _loadConnectionState(); // Add this
  }

  Future<void> _loadFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final isVisible = prefs.getBool('isFormVisible') ?? false;
    final selectedDevice = prefs.getString('selectedDevice');

    if (isVisible && selectedDevice != null) {
      // Load device details from device_conf.json
      final deviceDetails = await _loadDeviceDetails(selectedDevice);

      setState(() {
        _isFormVisible = true;
        _selectedDevices.add(selectedDevice);
        _currentFormData = deviceDetails;
      });
    }
  }

  Future<Map<String, dynamic>?> _loadDeviceDetails(String deviceName) async {
    final file = File(UiSettingsOption.deviceConfigFile);
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        final Map<String, dynamic> devices = jsonDecode(contents);
        return devices[deviceName];
      } catch (e) {
        print('Error reading device details: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _saveFormState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFormVisible', _isFormVisible);

    if (_selectedDevices.isNotEmpty) {
      await prefs.setString('selectedDevice', _selectedDevices.first);
    } else {
      await prefs.remove('selectedDevice');
    }
  }

  // When showing the form for editing, include all device details
  void _showDeviceForm(String deviceName) async {
    final file = File(UiSettingsOption.deviceConfigFile);
    if (await file.exists()) {
      final contents = await file.readAsString();
      final devices = jsonDecode(contents) as Map<String, dynamic>;
      final deviceDetails = devices[deviceName];

      setState(() {
        _isFormVisible = true;
        _currentFormData = deviceDetails;
      });
    }
  }

  // When adding a new device, don't pass initial values
  void _showAddDeviceForm() {
    setState(() {
      _isFormVisible = true;
      _currentFormData = null;
    });
  }

  // Function to hide the form
  void _hideAddDeviceForm() {
    setState(() {
      _isFormVisible = false; // Hide the form when canceled
    });
    _saveFormState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left panel (device list)
          Container(
            width: MediaQuery.of(context).size.width / 6,
            color: Color.fromARGB(255, 131, 131, 131),
            child: Column(
              children: [
                _buildConnectionButtons(),
                // Add Log toggle button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showLogs = !_showLogs;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                          width: 10), // Add empty space between text and icon
                      Icon(
                        _showLogs
                            ? Icons.keyboard_double_arrow_left_rounded
                            : Icons.keyboard_double_arrow_right_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDevicesExpansionTile(),
                      // _buildAlarmExpansionTile(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right panels
          if (_isFormVisible)
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3.2 / 4,
                child: AddDeviceForm(
                  initialValues: _currentFormData,
                  onSave: () {
                    _hideAddDeviceForm();
                    _loadDeviceNames();
                  },
                  onCancel: _hideAddDeviceForm,
                ),
              ),
            ),
          if (_showLogs) // Conditional logger display
            Flexible(
              fit: FlexFit.loose,
              child: _buildLogger(),
            ),
        ],
      ),
    );
  }

  Widget _buildLogger() {
    return Observer(
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: 200, // Minimum width
        ),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PLC Connection Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Tooltip(
                  message: 'Clear logs',
                  child: IconButton(
                    icon: Icon(Icons.clear_all, color: Colors.white),
                    onPressed: widget.logStore.clearLogs,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.logStore.logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      widget.logStore.logs[index],
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// In UISettingsOption.dart, update _buildConnectionButtons()
  Widget _buildConnectionButtons() {
    if (!widget.connectorStore.isConnected && _selectedDevices.isEmpty) {
      return Container();
    }
    return Observer(
      builder: (context) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              child: ElevatedButton(
                // onPressed:
                //     widget.connectorStore.isConnected ? null : _connectToPLC,
                onPressed: (_selectedDevices.isNotEmpty &&
                        !widget.connectorStore.isConnected)
                    ? _connectToPLC
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.connectorStore.isConnected
                      ? Colors.green
                      : _connectionError
                          ? Colors.red
                          : Colors.blue,
                  disabledBackgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  widget.connectorStore.isConnected ? 'Connected' : 'Connect',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: widget.connectorStore.isConnected
                    ? _disconnectFromPLC
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'Disconnect',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update connection methods
  Future<void> _connectToPLC() async {
    if (_selectedDevices.isEmpty) return;

    try {
      // Load device details to check com_driver
      final deviceDetails = await _loadDeviceDetails(_selectedDevices.first);

      if (deviceDetails != null &&
          deviceDetails['com_driver'] == 'Modbus TCP') {
        await widget.connectorStore.connectAndRead(_selectedDevices.first);
        setState(() {
          _connectionError = false;
        });
      } else {
        print(
            'Communication driver ${deviceDetails?['com_driver']} is under development');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Communication driver ${deviceDetails?['com_driver']} is under development'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _connectionError = true;
        });
      }
    } catch (e) {
      setState(() {
        _connectionError = true;
      });
      print('Connection error: $e');
    }
  }

  void _disconnectFromPLC() {
    widget.connectorStore.disconnect();
    setState(() {
      _connectionError = false;
    });
  }

  Widget _buildDevicesExpansionTile() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: 8, right: 8),
        title: Text(
          'Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        children: [
          ...(_deviceNames
              .map((deviceName) => _buildDeviceExpansionTile(deviceName))),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: ListTile(
              dense: true,
              title: Text(
                '+ Add Device',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: _showAddDeviceForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceExpansionTile(String deviceName) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(left: 8, right: 8),
          title: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _selectedDevices.contains(deviceName),
                  onChanged: (bool? isChecked) {
                    _onDeviceSelectionChanged(deviceName, isChecked ?? false);
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  deviceName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteDevice(deviceName),
              ),
            ],
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: [
            ...(_deviceGroups[deviceName]?.keys.map((groupName) =>
                    _buildGroupExpansionTile(deviceName, groupName)) ??
                []),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: ListTile(
                dense: true,
                title: Text(
                  '+ Group',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onTap: () => _showAddGroupForm(deviceName),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add this method to UISettingsOption.dart
  Future<void> _deleteDevice(String deviceName) async {
    final file = File(UiSettingsOption.deviceConfigFile);
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        final Map<String, dynamic> devices = jsonDecode(contents);

        if (devices.containsKey(deviceName)) {
          devices.remove(deviceName);

          await file.writeAsString(
            JsonEncoder.withIndent('  ').convert(devices),
            mode: FileMode.write,
          );

          setState(() {
            _deviceNames.remove(deviceName);
            _selectedDevices.remove(deviceName);
            _deviceGroups.remove(deviceName);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Device $deviceName deleted successfully')),
          );
        }
      } catch (e) {
        print('Error deleting device: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting device: $e')),
        );
      }
    }
  }

  Widget _buildGroupExpansionTile(String deviceName, String groupName) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(right: 8),
          title: Text(
            groupName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: [
            if (_deviceGroups[deviceName]?[groupName]?.containsKey('Tags'))
              ..._buildTagsList(deviceName, groupName),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: ListTile(
                dense: true,
                title: Text(
                  '+ Tags',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onTap: () => _showTagForm(deviceName, groupName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTagsList(String deviceName, String groupName) {
    final tags = (_deviceGroups[deviceName]?[groupName]['Tags']
            as Map<String, dynamic>?) ??
        {};
    return tags.entries
        .map((tagEntry) => Padding(
              padding: EdgeInsets.only(left: 24),
              child: ListTile(
                dense: true,
                title: Text(
                  tagEntry.key,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: Text(
                  'DataType: ${tagEntry.value['DataType']}\nRegister Address: ${tagEntry.value['R_address']}',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ))
        .toList();
  }

  Future<void> _loadDeviceNames() async {
    // print('Loading devices and groups...');
    final file = File(UiSettingsOption.deviceConfigFile);
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        final Map<String, dynamic> devices = jsonDecode(contents);
        setState(() {
          _deviceNames = devices.keys.toList();
          _deviceGroups = {}; // Clear existing groups

          // Load groups for each device
          devices.forEach((deviceName, deviceData) {
            if (deviceData is Map) {
              // Check for Groups within the device data
              if (deviceData.containsKey('Groups')) {
                _deviceGroups[deviceName] =
                    Map<String, dynamic>.from(deviceData['Groups']);
                // print(
                //     'Loaded groups for $deviceName: ${_deviceGroups[deviceName]?.keys.toList()}'); // Debug print
              }
            }
          });
        });
      } catch (e) {
        print('Error loading devices: $e');
      }
    }
  }

  Future<void> _loadSelectedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDevices = prefs.getStringList('selectedDevices');
    if (savedDevices != null) {
      setState(() {
        _selectedDevices.addAll(savedDevices);
      });
    }
  }

  Future<void> _saveSelectedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedDevices', _selectedDevices.toList());
  }

  void _onDeviceSelectionChanged(String deviceName, bool isSelected) async {
    if (isSelected) {
      final deviceDetails = await _loadDeviceDetails(deviceName);
      setState(() {
        _selectedDevices.add(deviceName);
        _currentFormData = deviceDetails;
        _isFormVisible = true;
        _isConnected = false;
        _connectionError = false;
      });
      _saveFormState();
    } else {
      if (_isConnected) {
        _disconnectFromPLC();
      }
      setState(() {
        _selectedDevices.remove(deviceName);
        _currentFormData = null;
        _isFormVisible = false;
      });
      _saveFormState();
    }
    _saveSelectedDevices();
  }

  void _showTagForm(String deviceName, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TagForm(
            deviceName: deviceName,
            groupName: groupName,
            onSave: () {
              Navigator.of(context).pop();
              // Add slight delay to ensure file write is complete
              Future.delayed(Duration(milliseconds: 100), () {
                _loadDeviceNames();
              });
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showAddGroupForm(String deviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: GroupForm(
            deviceName: deviceName,
            onSave: () {
              Navigator.of(context).pop();
              // Add slight delay to ensure file write is complete
              Future.delayed(Duration(milliseconds: 100), () {
                _loadDeviceNames();
              });
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  // Add connection state persistence
  Future<void> _saveConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConnected', _isConnected);
    await prefs.setBool('connectionError', _connectionError);
  }

  Future<void> _loadConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConnected = prefs.getBool('isConnected') ?? false;
      _connectionError = prefs.getBool('connectionError') ?? false;
    });

    // Reconnect if was connected before
    if (_isConnected && _selectedDevices.isNotEmpty) {
      widget.connectorStore.connectAndRead(_selectedDevices.first);
    }
  }
}
