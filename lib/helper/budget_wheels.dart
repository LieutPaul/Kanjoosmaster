import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../widgets/expense_component.dart';

Widget circularBudgetChart(String category, int spentAmount, int budget) {
  double percentage = spentAmount / budget;
  Color progressColor = Colors.green;

  if (percentage <= .5) {
    progressColor = Colors.green;
  } else if (percentage <= .75) {
    progressColor = Colors.orange;
  } else {
    progressColor = Colors.red;
  }
  return Center(
    child: CircularPercentIndicator(
      radius: 90.0,
      lineWidth: 13.0,
      animation: true,
      percent: percentage >= 1 ? 1 : percentage,
      center: Text(
        "${(percentage * 100).toStringAsFixed(2)}%",
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
      ),
      footer: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              "Budget for $category",
              style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Spent - $spentAmount",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Budget - $budget",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: Colors.white),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: progressColor,
    ),
  );
}

Expanded getBudgetWheels(String selectedMonth, Map<String, num> expenseSums,
    Map<String, List<dynamic>> listOfExpenses) {
  final currentUser = FirebaseAuth.instance.currentUser;
  return Expanded(
      flex: 1,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data?.data();
            final budgets = data?['Budgets'] as List<dynamic>?;
            final List<Widget> expenseWidgets = [];
            expenseWidgets.add(Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
              child: Text("Budgets for $selectedMonth",
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 180, 218, 255))),
            ));

            for (final budget in budgets!) {
              final category = budget['Category'];
              final budgetAmount = budget['Budget'];
              final date = budget['Date'];
              if (date == selectedMonth) {
                expenseWidgets.add(const SizedBox(height: 20));
                if (expenseSums.keys.contains(category)) {
                  expenseWidgets.add(circularBudgetChart(
                      category, expenseSums[category]!.toInt(), budgetAmount));
                } else {
                  expenseWidgets
                      .add(circularBudgetChart(category, 0, budgetAmount));
                }
              }
            }
            for (var entry in listOfExpenses.entries) {
              String category = entry.key;
              List<dynamic> expenses = entry.value;
              expenseWidgets.add(Padding(
                padding: const EdgeInsets.all(15),
                child: Text(category,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ));
              for (var expense in expenses) {
                expenseWidgets.add(Expense(
                    title: expense["Title"],
                    category: expense["Category"],
                    amount: expense["Amount"],
                    earning: expense["Earning"],
                    expenseId: expense["Id"],
                    description: expense["Description"],
                    date: expense["Date"]));
                expenseWidgets.add(const SizedBox(height: 10));
              }
            }
            return ListView(children: expenseWidgets);
          }
        },
      ));
}
