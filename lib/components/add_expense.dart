import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/helper.dart';

import '../widgets/checkbox.dart';
import '../widgets/custom_dropdown.dart';

Future<void> addExpense(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  DateFormat formatter = DateFormat('yyyy/MM/dd');
  var documentSnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .get();

  List<dynamic>? eCategories = documentSnapshot.data()?["ExpenseCategories"];
  List<String> expenseCategories = [];
  List<String> earningCategories = [];
  for (String c in eCategories!) {
    expenseCategories.add(c);
  }
  eCategories = documentSnapshot.data()?["EarningCategories"];
  for (String c in eCategories!) {
    earningCategories.add(c);
  }
  String expenseTitle = "",
      expenseDescription = "No Description",
      expenseCategory = "Food";
  int expenseAmount = 0;
  bool earning = false;
  bool canAdd = false;
  // ignore: use_build_context_synchronously
  await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Add a New Expense",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: earning == false
                                ? "Title of Expense"
                                : "Title of Earning",
                            hintStyle: const TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          expenseTitle = value;
                        },
                      ),
                      TextField(
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Description (Can be empty)",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          expenseDescription = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(earning == false
                          ? "Expense Category"
                          : "Earning Category"),
                      const SizedBox(height: 10),
                      CustomDropdownButton2(
                          hint: 'Select Item',
                          dropdownItems: (earning == false)
                              ? expenseCategories
                              : earningCategories,
                          value: expenseCategory,
                          onChanged: (value) {
                            setState(() {
                              expenseCategory = value!;
                            });
                          }),
                      TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: earning == false
                                ? "Expense Amount"
                                : "Earning Amount",
                            hintStyle: const TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            expenseAmount = parsedValue;
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyCheckbox(
                            initialValue: earning,
                            onChanged: (value) {
                              setState(() {
                                if (value == false) {
                                  expenseCategory = "Food";
                                } else {
                                  expenseCategory = "Pocket Money";
                                }
                                earning = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Amount is an earning',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                      if (expenseTitle.trim() != "" &&
                          expenseCategory != "" &&
                          expenseAmount > 0) {
                        Navigator.of(context).pop([
                          expenseTitle,
                          expenseDescription,
                          expenseCategory,
                          expenseAmount
                        ]);
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
            );
          }));
  if (canAdd) {
    await FirebaseFirestore.instance.collection("Expenses").add({
      "Title": expenseTitle.trim(),
      "Date": formatter.format(DateTime.now()).substring(0, 10),
      "Description": expenseDescription.trim(),
      "Category": expenseCategory,
      "Amount": expenseAmount,
      "Earning": earning,
      "Users": [currentUser.email]
    });
    // Checking for exceeding of any budgets :
    if (earning == false) {
      var todayDate = convertDateFormat(formatter.format(DateTime.now()));
      var b = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.email)
          .get();

      if (b.exists) {
        var budgets = b.data()!["Budgets"];
        for (var budget in budgets) {
          // Today falls under the budget and it is of the correct category
          if (budget["Category"] == expenseCategory &&
              isFirstDateBeforeOrSame(budget["FirstDate"], todayDate) &&
              isFirstDateBeforeOrSame(todayDate, budget["SecondDate"])) {
            num expenseSum = 0;
            var doc =
                await FirebaseFirestore.instance.collection("Expenses").get();
            for (var d in doc.docs) {
              var expense = d.data();
              if (expense["Users"].contains(currentUser.email) &&
                  expense["Category"] == expenseCategory &&
                  isFirstDateBeforeOrSame(budget["FirstDate"],
                      convertDateFormat(expense["Date"])) &&
                  isFirstDateBeforeOrSame(convertDateFormat(expense["Date"]),
                      budget["SecondDate"])) {
                expenseSum += expense["Amount"];
              }
            }
            if (expenseSum >= budget["Budget"]) {
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Budget Exceeded!!',
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 5),
                          Text("Budget : $expenseCategory"),
                          const SizedBox(height: 5),
                          Text(
                              'Dates : ${budget["FirstDate"]} - ${budget["SecondDate"]}'),
                          const SizedBox(height: 5),
                          Text('Budget Amount : ${budget["Budget"]}'),
                          const SizedBox(height: 5),
                          Text('Spent Amount : $expenseSum'),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        }
      }
    }
  }
}
