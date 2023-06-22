import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/helper/helper.dart';
import '../helper/add_budget.dart';
import '../helper/budget_wheels.dart';

class BudgetsWidget extends StatefulWidget {
  const BudgetsWidget({super.key});

  @override
  State<BudgetsWidget> createState() => _BudgetsWidgetState();
}

class _BudgetsWidgetState extends State<BudgetsWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool expensesFetched = false;
  Map<String, num> expenseSums = {};
  Map<String, List<dynamic>> listOfExpenses = {};
  DateFormat formatter = DateFormat('MMM yyyy/MM');
  String _selectedMonth = "";
  List<String> months = [];

  Future<void> getSpentAmount() async {
    expenseSums = {};
    listOfExpenses = {};
    var doc = await FirebaseFirestore.instance.collection("Expenses").get();
    for (var expense in doc.docs) {
      Map<String, dynamic> temp = expense.data();
      temp["Id"] = expense.id;
      if (expense["Users"].contains(currentUser!.email) &&
          _selectedMonth.substring(4) == expense["Date"].substring(0, 7)) {
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
    _selectedMonth = formatter.format(DateTime.now());
    getMonthsBeforeAndAfter(months);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: int.parse(_selectedMonth.substring(9)) >=
              int.parse(formatter.format(DateTime.now()).substring(9))
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => addBudget(context, _selectedMonth),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : null,
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
            return body();
          }
        },
      ),
    );
  }

  Widget body() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          topBar(),
          getBudgetWheels(_selectedMonth, expenseSums, listOfExpenses),
        ]);
  }

  Container topBar() {
    return Container(
      margin: const EdgeInsets.all(0),
      color: Colors.black,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    return calendarCircle(index);
                  }))),
        ),
      ),
    );
  }

  Column calendarCircle(int index) {
    return Column(
      children: [
        Text(
          months[index].substring(0, 3),
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = months[index];
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color:
                  _selectedMonth == months[index] ? Colors.white : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                months[index].substring(9),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: _selectedMonth == months[index]
                      ? Colors.blue
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
