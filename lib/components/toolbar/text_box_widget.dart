import 'package:flutter/material.dart';

class TextBoxWidget extends StatefulWidget {
  final String initialText;
  final bool isSelected;
  final Function(String) onTextChanged;

  const TextBoxWidget({
    Key? key,
    this.initialText = '',
    this.isSelected = false,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  _TextBoxWidgetState createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showMenu() async {
    final selectedColor = await showMenu<Color>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: Colors.white,
          child: Text('White Background'),
        ),
        PopupMenuItem(
          value: Colors.black,
          child: Text('Black Background'),
        ),
        PopupMenuItem(
          value: Colors.purple,
          child: Text('Purple Background'),
        ),
      ],
    );

    if (selectedColor != null) {
      setState(() {
        _backgroundColor = selectedColor;
        _textColor =
            selectedColor == Colors.white || selectedColor == Colors.purple
                ? Colors.black
                : Colors.white;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              border: Border.all(
                color: widget.isSelected ? Colors.blue : Colors.grey,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(8),
                border: InputBorder.none,
              ),
              onChanged: widget.onTextChanged,
              style: TextStyle(
                  fontSize: 14, color: _textColor, fontWeight: FontWeight.bold),
            ),
          ),
          if (_isHovered)
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: _showMenu,
              ),
            ),
        ],
      ),
    );
  }
}
