import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanjoosmaster/helper.dart';
import 'package:kanjoosmaster/widgets/date_picker.dart';
import '../components/add_budget.dart';
import '../components/budget_wheels.dart';

class BudgetsWidget extends StatefulWidget {
  const BudgetsWidget({super.key});

  @override
  State<BudgetsWidget> createState() => _BudgetsWidgetState();
}

class _BudgetsWidgetState extends State<BudgetsWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final firstDate = TextEditingController();
  final secondDate = TextEditingController();
  List<dynamic> eCategories = [];
  List<String> expenseCategories = [];
  Map<String, num> expenseSums = {};
  Map<String, List<dynamic>> listOfExpenses = {};

  Future<void> getSpentAmount() async {
    expenseSums = {};
    listOfExpenses = {};
    expenseCategories = [];
    eCategories = [];
    var doc = await FirebaseFirestore.instance.collection("Expenses").get();
    var e = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
    if (e.exists) {
      var data = e.data();
      eCategories = data?['ExpenseCategories'];
      for (String c in eCategories) {
        expenseCategories.add(c);
      }
    }
    for (var expense in doc.docs) {
      Map<String, dynamic> temp = expense.data();
      temp["Id"] = expense.id;
      String expenseDate = convertDateFormat(expense["Date"]);
      if (expense["Users"].contains(currentUser!.email) &&
          isFirstDateBeforeOrSame(firstDate.text, expenseDate) &&
          isFirstDateBeforeOrSame(expenseDate, secondDate.text)) {
        if (expenseSums.keys.contains(expense["Category"]) == false) {
          expenseSums[expense["Category"]] = expense["Amount"];
          listOfExpenses[expense["Category"]] = [temp];
        } else {
          expenseSums[expense["Category"]] =
              expenseSums[expense["Category"]]! + expense["Amount"];
          listOfExpenses[expense["Category"]]?.add(temp);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    firstDate.text = getFirstAndLastDatesOfMonth()[0];
    secondDate.text = getFirstAndLastDatesOfMonth()[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => addBudget(context),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.80),
      body: FutureBuilder<void>(
        future: getSpentAmount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 20),
                Center(
                    child: Text(
                  "Fetching Content",
                  style: TextStyle(color: Colors.white),
                )),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  getBudgetWheels(topBar(), firstDate.text, secondDate.text,
                      expenseSums, listOfExpenses, expenseCategories),
                ]);
          }
        },
      ),
    );
  }

  Container topBar() {
    return Container(
      color: Colors.black.withOpacity(0.80),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    textAlign: TextAlign.center,
                    "View All Expenses and Budgets between:",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  DatePicker(dateInput: firstDate, hintText: "First Date"),
                  const SizedBox(height: 15),
                  DatePicker(dateInput: secondDate, hintText: "Second Date"),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: () {
                        if (isFirstDateBeforeOrSame(
                            firstDate.text, secondDate.text)) {
                          setState(() {});
                        } else {
                          Fluttertoast.showToast(
                              msg: "Enter Valid Dates Please");
                        }
                      },
                      child: const Text("Confirm"))
                ],
              )),
        ),
      ),
    );
  }
}
