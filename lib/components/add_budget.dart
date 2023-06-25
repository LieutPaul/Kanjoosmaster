import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanjoosmaster/helper.dart';
import 'package:kanjoosmaster/widgets/date_picker.dart';
import 'package:uuid/uuid.dart';
import '../widgets/custom_dropdown.dart';

Future<void> addBudget(BuildContext context) async {
  final firstDate = TextEditingController();
  final secondDate = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

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
      builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Add a Budget",
                style: TextStyle(color: Colors.black)),
            content: SingleChildScrollView(
                child: Column(
              children: [
                CustomDropdownButton2(
                    hint: 'Select Item',
                    dropdownItems: expenseCategories,
                    value: budgetCategory,
                    onChanged: (value) {
                      budgetCategory = value!;
                    }),
                const SizedBox(height: 15),
                DatePicker(dateInput: firstDate, hintText: "First Date"),
                const SizedBox(height: 10),
                DatePicker(dateInput: secondDate, hintText: "Second Date"),
                const SizedBox(height: 10),
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
            )),
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
                    if (budgetAmount > 0 &&
                        firstDate.text != "" &&
                        secondDate.text != "" &&
                        isFirstDateBeforeOrSame(
                            firstDate.text, secondDate.text)) {
                      Navigator.of(context).pop([budgetCategory, budgetAmount]);
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
        .doc(currentUser.email)
        .update({
      "Budgets": FieldValue.arrayUnion([
        {
          "Id": const Uuid().v4(),
          "Category": budgetCategory.trim(),
          "Budget": budgetAmount,
          "FirstDate": firstDate.text,
          "SecondDate": secondDate.text
        }
      ])
    });
  }
}
