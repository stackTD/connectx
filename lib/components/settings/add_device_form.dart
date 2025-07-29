// This appears when the Add device button is pressed or when a device is selected.

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class AddDeviceForm extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Map<String, dynamic>? initialValues;

  const AddDeviceForm(
      {required this.onSave,
      required this.onCancel,
      this.initialValues,
      Key? key})
      : super(key: key);

  @override
  _AddDeviceFormState createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceDescriptionController = TextEditingController();
  final _hostIpController = TextEditingController();
  final _portNumberController = TextEditingController();
  final _stationNumberController = TextEditingController();
  bool isEditMode = false;
  String? editingDeviceName;

  String _make = 'General';
  String _comDriver = 'Modbus TCP';

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _deviceNameController.text = widget.initialValues!['device_name'] ?? '';
      _deviceDescriptionController.text =
          widget.initialValues!['device_description'] ?? '';
      _hostIpController.text = widget.initialValues!['host_ip'] ?? '';
      _portNumberController.text =
          widget.initialValues!['port_number']?.toString() ?? '';
      _stationNumberController.text =
          widget.initialValues!['station_number']?.toString() ?? '';
      _make = widget.initialValues!['make'] ?? 'General';
      isEditMode = true;
      editingDeviceName = widget.initialValues!['device_name'];
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final newDevice = {
        'device_name': _deviceNameController.text,
        'device_description': _deviceDescriptionController.text,
        'make': _make,
        'com_driver': _comDriver,
        'host_ip': _hostIpController.text,
        'port_number': int.tryParse(_portNumberController.text) ?? 0,
        'station_number': int.tryParse(_stationNumberController.text) ?? 0,
      };

      await _saveDeviceToJson(newDevice);
      await Future.delayed(const Duration(seconds: 1));

      print("Callback sent from add device form");
      widget.onSave();
    }
  }

  // Update _saveDeviceToJson method
  Future<void> _saveDeviceToJson(Map<String, dynamic> newDevice) async {
    final file = File('device_conf.json');
    Map<String, dynamic> devices = {};

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          devices = jsonDecode(contents) as Map<String, dynamic>;
        }
      } catch (e) {
        print('Error reading or parsing file: $e');
      }
    }

    final deviceName = newDevice['device_name'];
    if (deviceName != null) {
      // If in edit mode and device name changed, remove old entry
      if (isEditMode && editingDeviceName != deviceName) {
        devices.remove(editingDeviceName);
      }
      devices[deviceName] = newDevice;
    }

    try {
      await file.writeAsString(
        JsonEncoder.withIndent('  ').convert(devices),
        mode: FileMode.write,
      );
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  // Update the build method - modify the title
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Edit Device' : 'Add Device',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(_deviceNameController, 'Device Name',
                'Please enter a device name'),
            const SizedBox(height: 16),
            _buildTextField(_deviceDescriptionController, 'Device Description'),
            const SizedBox(height: 16),
            _buildDropdownField('Make', _make, ['General', 'Specific'],
                (value) {
              setState(() {
                _make = value!;
              });
            }),
            const SizedBox(height: 16),
            _buildDropdownField('Com. Driver', _comDriver,
                ['Modbus TCP', 'Mitsubishi Q or iQ-F'], (value) {
              setState(() {
                _comDriver = value!;
              });
            }),
            const SizedBox(height: 16),
            _buildTextField(
                _hostIpController, 'Host IP', 'Please enter the Host IP'),
            const SizedBox(height: 16),
            _buildNumberField(_portNumberController, 'Port Number'),
            const SizedBox(height: 16),
            _buildNumberField(_stationNumberController, 'Station Number'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [String? validatorMessage]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validatorMessage != null
          ? (value) {
              if (value == null || value.isEmpty) {
                return validatorMessage;
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}
