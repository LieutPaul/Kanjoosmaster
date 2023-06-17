import 'package:flutter/material.dart';

class MyCheckbox extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const MyCheckbox({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  MyCheckboxState createState() => MyCheckboxState();
}

class MyCheckboxState extends State<MyCheckbox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
          widget.onChanged(isChecked);
        });
      },
    );
  }
}
