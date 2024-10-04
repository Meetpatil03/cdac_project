import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final String? value;
  final String? Function(String?)? validator;
  const CustomDropDown({
    super.key,
    this.validator,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.value,
  });

  DropdownMenuItem<String> buildItemList(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 5,
          color: Colors.blue,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 50,
          ),
          items: items.map(buildItemList).toList(),
          validator: validator,
          onChanged: onChanged,
          
        ),
      ),
    );
  }
}
