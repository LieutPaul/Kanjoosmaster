import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  final TextEditingController dateInput;
  final String hintText;

  const DatePicker({
    super.key,
    required this.dateInput,
    required this.hintText,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.dateInput,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => value == "" ? "Cannot be empty" : null,
      decoration: InputDecoration(
          icon: const Icon(Icons.calendar_today), labelText: widget.hintText),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1990),
            lastDate: DateTime(2100),
            currentDate: DateTime.now());

        if (pickedDate != null) {
          String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
          setState(() {
            widget.dateInput.text = formattedDate;
          });
        } else {}
      },
    );
  }
}
