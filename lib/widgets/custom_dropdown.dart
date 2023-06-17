import 'package:flutter/material.dart';

class CustomDropdownButton2 extends StatelessWidget {
  final String hint;
  final List<String> dropdownItems;
  final String value;
  final Function(String?) onChanged;

  const CustomDropdownButton2({
    super.key,
    required this.hint,
    required this.dropdownItems,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey<String?>(value), // Add a ValueKey with the current value
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
      ),
      value: value,
      onChanged: onChanged,
      items: dropdownItems.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
