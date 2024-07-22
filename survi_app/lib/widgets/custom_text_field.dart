import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Widget suffixIcons;
  final bool obscureText;
  final TextInputType textInputType;
  final VoidCallback function;
  final VoidCallback function2;
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.label,
      required this.suffixIcons,
      required this.obscureText,
      required this.textInputType,
      required this.function,
      required this.function2});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: textInputType,
      onChanged: (value) {
        function();
      },
      onSubmitted: (value) {
        function2();
      },
      obscuringCharacter: '*',
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 5, color: Colors.blue),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.purple),
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: suffixIcons,
        label: Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }
}
