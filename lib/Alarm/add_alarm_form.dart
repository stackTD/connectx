import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AddAlarmForm extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Map<String, dynamic>? initialValues;

  const AddAlarmForm({
    Key? key,
    required this.onSave,
    required this.onCancel,
    this.initialValues,
  }) : super(key: key);

  @override
  State<AddAlarmForm> createState() => _AddAlarmFormState();
}

class _AddAlarmFormState extends State<AddAlarmForm> {
  bool isEditMode = false;
  String? editingDeviceName;

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _tagNameController.text = widget.initialValues!['tag_name'] ?? '';
      _dataType = widget.initialValues!['data_type'] ?? 'Int';
      _alarmMessageController.text =
          widget.initialValues!['alarm_message'] ?? '';
      _alarmDescriptionController.text =
          widget.initialValues!['alarm_description'] ?? '';
      _alarmGuidanceController.text =
          widget.initialValues!['alarm_guidance'] ?? '';
      _conditionController.text = widget.initialValues!['condition'] ?? '';
      _numberOfTerms = widget.initialValues!['number_of_terms'] ?? '1';
      _priority = widget.initialValues!['priority'] ?? '';
      _priorityColor = widget.initialValues!['priority_color'] ?? '';
      isEditMode = true;
      editingDeviceName = widget.initialValues!['tag_name'];
    }
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _tagNameController = TextEditingController();
  final _alarmMessageController = TextEditingController();
  final _alarmDescriptionController = TextEditingController();
  final _alarmGuidanceController = TextEditingController();
  final _conditionController = TextEditingController();

  // Dropdown values
  String _dataType = 'Int';
  String _priority = 'High';
  String _priorityColor = 'Green';
  String _numberOfTerms = '1';

  @override
  void dispose() {
    _tagNameController.dispose();
    _alarmMessageController.dispose();
    _alarmDescriptionController.dispose();
    _alarmGuidanceController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveAlarmToJson(Map<String, dynamic> alarmData) async {
    try {
      final file = File('alarm_conf.json');
      List<dynamic> alarms = [];

      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          alarms = json.decode(contents);
        }
      }

      final String tagName = alarmData['tag_name'];
      final Map<String, dynamic> wrappedAlarm = {tagName: alarmData};

      if (isEditMode) {
        // Update existing alarm
        final index =
            alarms.indexWhere((alarm) => alarm.keys.first == editingDeviceName);
        if (index != -1) {
          alarms[index] = wrappedAlarm;
        }
      } else {
        // Add new alarm
        alarms.add(wrappedAlarm);
      }

      await file.writeAsString(json.encode(alarms));
    } catch (e) {
      throw Exception('Failed to save alarm: $e');
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newAlarm = {
          'tag_name': _tagNameController.text,
          'data_type': _dataType,
          'priority': _priority,
          'priority_color': _priorityColor,
          'alarm_message': _alarmMessageController.text,
          'alarm_description': _alarmDescriptionController.text,
          'alarm_guidance': _alarmGuidanceController.text,
          'condition': _conditionController.text,
          'number_of_terms': _numberOfTerms,
        };

        await _saveAlarmToJson(newAlarm);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alarm created successfully')),
          );
        }
        widget.onSave();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving alarm: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Alarms',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField(_tagNameController, 'Tag Name', 'Enter tag name'),
              const SizedBox(height: 16),
              _buildDropdownField(
                  'Data Type', _dataType, ['Int', 'Float', 'Bool'], (value) {
                setState(() {
                  _dataType = value!;
                });
              }),
              const SizedBox(height: 16),
              _buildDropdownField(
                  'Priority', _priority, ['High', 'Medium', 'Low'], (value) {
                setState(() {
                  _priority = value!;
                });
              }),
              const SizedBox(height: 16),
              _buildDropdownField('Priority Color', _priorityColor,
                  ['Green', 'Blue', 'Yellow', 'Red'], (value) {
                setState(() {
                  _priorityColor = value!;
                });
              }),
              const SizedBox(height: 16),
              _buildTextField(_alarmMessageController, 'Alarm Message',
                  'Enter alarm message'),
              const SizedBox(height: 16),
              _buildTextField(_alarmDescriptionController, 'Alarm Description',
                  'Enter alarm description'),
              const SizedBox(height: 16),
              _buildTextField(_alarmGuidanceController, 'Alarm Guidance',
                  'Enter alarm guidance'),
              const SizedBox(height: 16),
              _buildDropdownField(
                  'Number of Terms', _numberOfTerms, ['1', '2', '3'], (value) {
                setState(() {
                  _numberOfTerms = value!;
                });
              }),
              const SizedBox(height: 16),
              _buildTextField(
                  _conditionController, 'Condition', 'Enter condition'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
