import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
                      if (expenseTitle != "" &&
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
      "Title": expenseTitle,
      "Date": formatter.format(DateTime.now()).substring(0, 10),
      "Description": expenseDescription,
      "Category": expenseCategory,
      "Amount": expenseAmount,
      "Earning": earning,
      "Users": [currentUser.email]
    });
  }
}
