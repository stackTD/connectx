import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package

class UIHeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Color.fromARGB(255, 131, 131, 131),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(0), // Adjust padding as needed
            child: SvgPicture.asset(
              'assets/icon.svg', // Path to your SVG asset
              height: 25, // Adjust height as needed
              width: 10, // Adjust width as needed
            ),
          ),
          Spacer(
            flex: 4,
          ),
          Text(
            'SCADA ConnectX',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }
}
