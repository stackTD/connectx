import 'package:flutter/material.dart';

class UIMasterSideMenu extends StatefulWidget {
  final Function(String) onButtonPressed;

  UIMasterSideMenu({required this.onButtonPressed});

  @override
  _UIMasterSideMenuState createState() => _UIMasterSideMenuState();
}

class _UIMasterSideMenuState extends State<UIMasterSideMenu> {
  String _selectedButton = 'Simulation';

  void _handleButtonPress(String buttonName) {
    setState(() {
      _selectedButton = buttonName;
    });
    widget.onButtonPressed(buttonName);
  }

  Widget _buildMenuButton(String buttonName, IconData icon) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleButtonPress(buttonName),
        child: Icon(icon, size: 30),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedButton == buttonName
              ? Color.fromARGB(255, 31, 194, 235)
              : Color.fromARGB(255, 174, 174, 174),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      color: Color.fromARGB(255, 131, 131, 131),
      child: Column(
        children: [
          Tooltip(
            message: 'Workspace',
            child: _buildMenuButton('Simulation', Icons.factory_outlined),
          ),
          SizedBox(height: 10),
          Tooltip(
            message: 'Alarms',
            child: _buildMenuButton('Alarms', Icons.notification_important),
          ),
          Spacer(),
          Tooltip(
            message: 'Settings',
            child: _buildMenuButton('Settings', Icons.settings),
          ),
        ],
      ),
    );
  }
}
