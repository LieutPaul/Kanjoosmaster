import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/helper/helper.dart';
import 'package:kanjoosmaster/widgets/expense_component.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../widgets/custom_dropdown.dart';

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
              onPressed: () => _addBudget(),
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
          getBudgetWheels(),
        ]);
  }

  Expanded getBudgetWheels() {
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
                child: Text("Budgets for $_selectedMonth",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 180, 218, 255))),
              ));

              for (final budget in budgets!) {
                final category = budget['Category'];
                final budgetAmount = budget['Budget'];
                final date = budget['Date'];
                if (date == _selectedMonth) {
                  expenseWidgets.add(const SizedBox(height: 20));
                  if (expenseSums.keys.contains(category)) {
                    expenseWidgets.add(circularBudgetChart(category,
                        expenseSums[category]!.toInt(), budgetAmount));
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

  Future<void> _addBudget() async {
    bool canAdd = false;
    var documentSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();

    List<dynamic>? eCategories = documentSnapshot.data()?["ExpenseCategories"];
    List<String> expenseCategories = [];
    for (String c in eCategories!) {
      expenseCategories.add(c);
    }
    String budgetCategory = "Food";
    int budgetAmount = 0;
    // ignore: use_build_context_synchronously
    await showDialog(
        context: context,
        builder: (contex) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Add a Budget",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      CustomDropdownButton2(
                          hint: 'Select Item',
                          dropdownItems: expenseCategories,
                          value: budgetCategory,
                          onChanged: (value) {
                            setState(() {
                              budgetCategory = value!;
                            });
                          }),
                      const SizedBox(height: 15),
                      TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Budget Amount",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            budgetAmount = parsedValue;
                          }
                        },
                      ),
                    ],
                  ))),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {
                      if (budgetAmount > 0) {
                        Navigator.of(context)
                            .pop([budgetCategory, budgetAmount]);
                        canAdd = true;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Enter Valid Inputs",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 20.0);
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ));
    if (canAdd) {
      (FirebaseFirestore.instance.collection("Users"))
          .doc(currentUser!.email)
          .update({
        "Budgets": FieldValue.arrayUnion([
          {
            "Category": budgetCategory,
            "Budget": budgetAmount,
            "Date": _selectedMonth
          }
        ])
      });
    }
  }
}
