import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class TagForm extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String deviceName;
  final String groupName; // Add groupName parameter

  TagForm({
    required this.onSave,
    required this.onCancel,
    required this.deviceName,
    required this.groupName, // Include groupName in the constructor
  });

  @override
  _TagFormState createState() => _TagFormState();
}

class _TagFormState extends State<TagForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registerAddressController = TextEditingController();
  String _dataType = 'Integer'; // Default value for dropdown menu

  @override
  void dispose() {
    _nameController.dispose();
    _registerAddressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final tagName = _nameController.text;
      final registerAddress = _registerAddressController.text;

      _saveTagToJson(tagName, _dataType, registerAddress);
      widget.onSave(); // Call the callback to close the form
    }
  }

  Future<void> _saveTagToJson(
      String tagName, String dataType, String registerAddress) async {
    final file = File('device_conf.json');
    Map<String, dynamic> devices = {};

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        devices = jsonDecode(contents) as Map<String, dynamic>;

        if (devices.containsKey(widget.deviceName)) {
          var deviceData = devices[widget.deviceName];

          // Ensure Groups exists
          if (!deviceData.containsKey('Groups')) {
            deviceData['Groups'] = {};
          }

          // Ensure specific group exists
          if (!deviceData['Groups'].containsKey(widget.groupName)) {
            deviceData['Groups'][widget.groupName] = {};
          }

          // Ensure Tags exists in group
          if (!deviceData['Groups'][widget.groupName].containsKey('Tags')) {
            deviceData['Groups'][widget.groupName]['Tags'] = {};
          }

          // Add new tag
          deviceData['Groups'][widget.groupName]['Tags'][tagName] = {
            'Name': tagName,
            'DataType': dataType,
            'R_address': registerAddress,
          };

          // Write with proper formatting
          await file.writeAsString(
            JsonEncoder.withIndent('  ').convert(devices),
            mode: FileMode.write,
          );
          print(
              'Tag $tagName added to ${widget.deviceName}/${widget.groupName}'); // Debug print
        }
      } catch (e) {
        print('Error saving tag: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a Tag =  \nDevice: ${widget.deviceName} \nGroup: ${widget.groupName}', // Display deviceName and groupName
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _dataType,
              onChanged: (String? newValue) {
                setState(() {
                  _dataType = newValue!;
                });
              },
              items: <String>['Integer', 'String', 'Boolean', 'Others']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Data Type'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _registerAddressController,
              decoration: InputDecoration(labelText: 'Register Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a register address';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: Text('Save'),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
