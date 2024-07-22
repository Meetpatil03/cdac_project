import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final double fontSize;
  final String text;
  const CustomText({super.key, required this.fontSize, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: Colors.white,
        shadows: const [
          BoxShadow(color: Colors.blue, blurRadius: 80, spreadRadius: 0),
        ],
      ),
    );
  }
}
