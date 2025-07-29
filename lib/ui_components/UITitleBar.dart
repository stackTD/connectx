/**
 This code file deals with the title bar shown on the top of the application
 Currently it only display the text "Title bar".
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package

class UITitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Color.fromARGB(255, 59, 58, 58),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Title Bar',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
