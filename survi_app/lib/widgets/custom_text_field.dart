import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Widget suffixIcons;
  final bool obscureText;
  final TextInputType textInputType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.validator,
    required this.controller,
    required this.label,
    required this.suffixIcons,
    required this.obscureText,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: textInputType,
      validator : validator,
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
