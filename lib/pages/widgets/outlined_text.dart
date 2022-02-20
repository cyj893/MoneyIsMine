import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color outlineColor;

  const OutlinedText({
    Key? key,
    required this.text,
    required this.textColor,
    required this.outlineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = outlineColor,
          ),),
        Text(text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),)
      ],
    );
  }
}