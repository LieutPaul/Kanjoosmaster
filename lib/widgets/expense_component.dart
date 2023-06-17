import 'package:flutter/material.dart';

class Expense extends StatelessWidget {
  final String title;
  final String category;
  final int amount;
  final bool expenditure; // true -> It is expenditure, not income
  const Expense(
      {super.key,
      required this.title,
      required this.category,
      required this.amount,
      required this.expenditure});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          expenditure == true ? Icons.arrow_upward : Icons.arrow_downward,
          color: expenditure == true ? Colors.red : Colors.green,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        category,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: Text(
        amount.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }
}
