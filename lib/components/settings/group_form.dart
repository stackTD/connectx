import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class GroupForm extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String deviceName; // Add deviceName parameter

  GroupForm({
    required this.onSave,
    required this.onCancel,
    required this.deviceName, // Include deviceName in the constructor
  });

  @override
  _GroupFormState createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newGroup = _groupNameController.text;

      _saveGroupToJson(newGroup);
      widget.onSave(); // Call the callback to close the form
    }
  }

  Future<void> _saveGroupToJson(String groupName) async {
    final file = File('device_conf.json');
    Map<String, dynamic> devices = {};

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        devices = jsonDecode(contents) as Map<String, dynamic>;

        if (devices.containsKey(widget.deviceName)) {
          // Preserve existing device data
          final deviceData = devices[widget.deviceName] as Map<String, dynamic>;

          // Ensure Groups structure exists
          if (!deviceData.containsKey('Groups')) {
            deviceData['Groups'] = {};
          }

          // Add new group
          deviceData['Groups'][groupName] = {};
          devices[widget.deviceName] = deviceData;

          // Write with proper formatting
          await file.writeAsString(
            JsonEncoder.withIndent('  ').convert(devices),
            mode: FileMode.write,
          );
          // print(
          //     'Group $groupName added to ${widget.deviceName}'); // Debug print
        }
      } catch (e) {
        print('Error saving group: $e');
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
              'Add Group to ${widget.deviceName}', // Display deviceName
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group name';
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
