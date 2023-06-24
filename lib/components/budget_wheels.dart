import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../helper.dart';
import 'expense_component.dart';

Widget circularBudgetChart(String id, String category, int spentAmount,
    int budget, BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;
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
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16.0),
                            Text('Deleting...'),
                          ],
                        ),
                      ),
                    );
                  },
                );
                try {
                  CollectionReference expensesCollection =
                      FirebaseFirestore.instance.collection('Users');

                  DocumentReference documentRef =
                      expensesCollection.doc(currentUser!.email);

                  DocumentSnapshot<Map<String, dynamic>> snapshot =
                      await documentRef.get()
                          as DocumentSnapshot<Map<String, dynamic>>;

                  if (snapshot.exists) {
                    Map<String, dynamic> data = snapshot.data()!;

                    List<dynamic> budgets = List.from(data['Budgets']);

                    budgets.removeWhere((budget) {
                      return budget["Id"] == id;
                    });

                    await documentRef.update({'Budgets': budgets});
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } catch (error) {
                  // ignore: avoid_print
                  print('Error deleting document: $error');
                  Navigator.pop(context);
                }
              },
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
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

Expanded getBudgetWheels(String firstDate, String secondDate,
    Map<String, num> expenseSums, Map<String, List<dynamic>> listOfExpenses) {
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
              child: Text("Budgets for $firstDate - $secondDate",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 180, 218, 255))),
            ));

            for (final budget in budgets!) {
              final category = budget['Category'];
              final budgetAmount = budget['Budget'];
              final budgetFirstdate = budget['FirstDate'];
              final budgetSeconddate = budget['SecondDate'];
              final id = budget["Id"];
              if (isFirstDateBeforeOrSame(firstDate, budgetFirstdate) &&
                  isFirstDateBeforeOrSame(budgetSeconddate, secondDate)) {
                expenseWidgets.add(const SizedBox(height: 20));
                if (expenseSums.keys.contains(category)) {
                  expenseWidgets.add(circularBudgetChart(id, category,
                      expenseSums[category]!.toInt(), budgetAmount, context));
                } else {
                  expenseWidgets.add(circularBudgetChart(
                      id, category, 0, budgetAmount, context));
                }
              }
            }
            for (var entry in listOfExpenses.entries) {
              String category = entry.key;
              List<dynamic> expenses = entry.value;
              int total = 0;
              for (var expense in expenses) {
                total += expense["Amount"] as int;
              }
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
              expenseWidgets.add(Center(
                child: Text(
                  "Total - $total",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 172, 255, 207),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ));
            }
            expenseWidgets.add(const SizedBox(height: 20));
            return ListView(children: expenseWidgets);
          }
        },
      ));
}
