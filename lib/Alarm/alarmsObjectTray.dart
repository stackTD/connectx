import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import './add_alarm_form.dart';
import './alarmsDashboard.dart';

class AlarmObjectTray extends StatefulWidget {
  const AlarmObjectTray({Key? key}) : super(key: key);

  @override
  _AlarmObjectTrayState createState() => _AlarmObjectTrayState();
}

class _AlarmObjectTrayState extends State<AlarmObjectTray> {
  List<String> _alarmNames = [];
  List<String> _alarmHistory = [];
  bool _showAlarmHistory = false;
  bool _showAlarmForm = false;
  bool _showDashboard = false;

  // Add selected alarm state
  String? _selectedAlarm;
  Map<String, dynamic>? _selectedAlarmData;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      final file = File('alarm_conf.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> alarmsJson = json.decode(contents);

          // Extract tag names from JSON structure
          final List<String> alarmNames = alarmsJson.map((alarm) {
            // Each alarm is a map with a single key (the tag name)
            return alarm.keys.first.toString();
          }).toList();

          setState(() {
            _alarmNames = alarmNames;
          });
        }
      } else {
        setState(() {
          _alarmNames = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading alarms: $e');
      setState(() {
        _alarmNames = [];
      });
    }
  }

  Future<void> _deleteAlarm(String alarmName) async {
    try {
      final file = File('alarm_conf.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          List<dynamic> alarmsJson = json.decode(contents);
          // Remove alarm with matching key
          alarmsJson.removeWhere((alarm) => alarm.keys.first == alarmName);
          // Write back to file
          await file.writeAsString(json.encode(alarmsJson));
          // Refresh alarm list
          await _loadAlarms();
        }
      }
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
    }
  }

  // Add method to load alarm details
  Future<void> _loadAlarmDetails(String alarmName) async {
    try {
      final file = File('alarm_conf.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          List<dynamic> alarmsJson = json.decode(contents);
          final alarm = alarmsJson.firstWhere(
            (alarm) => alarm.keys.first == alarmName,
            orElse: () => null,
          );
          if (alarm != null) {
            setState(() {
              _selectedAlarmData = alarm[alarmName];
              _showAlarmForm = true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading alarm details: $e');
    }
  }

  void _showAddAlarmForm() {
    setState(() {
      _showAlarmForm = true;
    });
  }

  void _hideAddAlarmForm() {
    setState(() {
      _showAlarmForm = false;
    });
  }

  void _toggleDashboard() {
    setState(() {
      _showDashboard = !_showDashboard;
      _showAlarmForm = false; // Hide alarm form when dashboard is shown
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left panel (alarms list)
          Container(
            width: MediaQuery.of(context).size.width / 6,
            color: const Color.fromARGB(255, 131, 131, 131),
            child: Column(
              children: [
                // Add Dashboard button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: _showDashboard
                          ? Colors.green
                          : Colors.blue, // for Flutter 3.0+
                      foregroundColor: Colors.white, // This sets the text color
                    ),
                    onPressed: _toggleDashboard,
                    child: const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                _buildAlarmsExpansionTile(),
              ],
            ),
          ),

          // Add conditional dashboard display
          if (_showDashboard)
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3.2 / 4,
                child: const AlarmsDashboard(),
              ),
            )
          else if (_showAlarmForm)
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3.2 / 4,
                child: AddAlarmForm(
                  initialValues: _selectedAlarmData,
                  onSave: () {
                    _hideAddAlarmForm();
                    _loadAlarms();
                  },
                  onCancel: _hideAddAlarmForm,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlarmsExpansionTile() {
    return Column(
      children: [
        // Add Alarm Button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: const Color.fromARGB(255, 87, 151, 204),
            ),
            onPressed: () {
              setState(() {
                _selectedAlarm = null;
                _selectedAlarmData = null;
                _showAlarmForm = true;
              });
            },
            child: const Text(
              'Add Alarm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        // Existing ExpansionTile
        ExpansionTile(
          title: const Text('Active Alarms'),
          children: _alarmNames.map((alarmName) {
            return ListTile(
              leading: Checkbox(
                value: _selectedAlarm == alarmName,
                onChanged: (bool? value) async {
                  if (value == true) {
                    setState(() => _selectedAlarm = alarmName);
                    await _loadAlarmDetails(alarmName);
                  } else {
                    setState(() {
                      _selectedAlarm = null;
                      _selectedAlarmData = null;
                      _showAlarmForm = false;
                    });
                  }
                },
              ),
              title: Text(alarmName),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () async {
                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text('Delete alarm "$alarmName"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await _deleteAlarm(alarmName);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAlarmItem(String alarmName) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: ListTile(
        dense: true,
        title: Text(
          alarmName,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: Icon(Icons.warning, color: Colors.red),
      ),
    );
  }

  Widget _buildHistoryItem(String history) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: ListTile(
        dense: true,
        title: Text(
          history,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Icon(Icons.history, color: Colors.white70),
      ),
    );
  }
}
