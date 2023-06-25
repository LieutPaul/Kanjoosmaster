import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/expense_component.dart';

class ExpandedBudget extends StatefulWidget {
  final int spentAmount;
  final int budgetAmount;
  final List<dynamic> expS;
  final String startDate;
  final String endDate;
  final String budgetId;
  final String category;
  final double percentage;
  final Color progressColor;
  const ExpandedBudget(
      {super.key,
      required this.expS,
      required this.startDate,
      required this.endDate,
      required this.budgetId,
      required this.category,
      required this.spentAmount,
      required this.budgetAmount,
      required this.progressColor,
      required this.percentage});

  @override
  State<ExpandedBudget> createState() => _ExpandedBudgetState();
}

class _ExpandedBudgetState extends State<ExpandedBudget> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body(), backgroundColor: Colors.black);
  }

  Widget body() {
    return Container(
      color: Colors.grey[900],
      child: ListView(children: [
        topBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Text(
            "Budget For ${widget.category} between ${widget.startDate} and ${widget.endDate}",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, color: Color.fromARGB(255, 168, 216, 255)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20),
          child: Center(
            child: Text(
              "Budget Amount - ${widget.budgetAmount}",
              style: const TextStyle(
                  color: Color.fromARGB(255, 172, 255, 207),
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            "Expenses:-",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        for (var expense in widget.expS)
          Expense(
              canDelete: false,
              title: expense["Title"],
              category: expense["Category"],
              amount: expense["Amount"],
              earning: expense["Earning"],
              expenseId: expense["Id"],
              description: expense["Description"],
              date: expense["Date"]),
        Center(
          child: Text(
            "Spent Amount - ${widget.spentAmount}",
            style: const TextStyle(
                color: Color.fromARGB(255, 172, 255, 207),
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Set the color of the border
                  width: 2.0, // Set the width of the border
                ),
                borderRadius:
                    BorderRadius.circular(8.0), // Set the border radius
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    8.0), // Add some padding within the box
                child: Text(
                  " ${(widget.percentage * 100).toStringAsFixed(2)}% Consumed ",
                  style: TextStyle(
                    color: widget.progressColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () => deleteBudget(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            child: const Text("Delete Budget"),
          ),
        )
      ]),
    );
  }

  Container topBar() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: Text(
                            "Budget Details",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future<void> deleteBudget() async {
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
                Text('Deleting Budget...'),
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
          await documentRef.get() as DocumentSnapshot<Map<String, dynamic>>;

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;

        List<dynamic> budgets = List.from(data['Budgets']);

        budgets.removeWhere((budget) {
          return budget["Id"] == widget.budgetId;
        });

        await documentRef.update({'Budgets': budgets});
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      // ignore: avoid_print
      print('Error deleting document: $error');
      Navigator.pop(context);
    }
  }
}
