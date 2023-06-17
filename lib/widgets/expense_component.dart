import 'package:flutter/material.dart';

class Expense extends StatelessWidget {
  final String expenseId;
  final String title;
  final String description;
  final String category;
  final int amount;
  final bool earning; // true -> It is earning, not income
  const Expense(
      {super.key,
      required this.title,
      required this.category,
      required this.amount,
      required this.earning,
      required this.expenseId,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.money_sharp,
          color: earning == false ? Colors.red : Colors.green,
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
