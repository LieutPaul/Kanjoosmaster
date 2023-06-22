import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanjoosmaster/widgets/my_text_button.dart';

Column getLargeExpenses(BuildContext context) {
  var currentUser = FirebaseAuth.instance.currentUser;
  Future<void> addLargeExpense() async {
    String expenseTitle = "";
    int expenseAmount = 0;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("New Large Expense",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Enter Name of expense",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          expenseTitle = value;
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Expense Amount",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            expenseAmount = parsedValue;
                          }
                        },
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
                      if (expenseTitle != "" && expenseAmount > 0) {
                        Navigator.of(context)
                            .pop([expenseTitle, expenseAmount]);
                      } else {
                        Fluttertoast.showToast(msg: "Invalid Inputs");
                      }
                    },
                    child: const Text(
                      "Add Expense",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ));

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      "LargeExpenses": FieldValue.arrayUnion([
        {"Title": expenseTitle, "Amount": expenseAmount}
      ])
    });
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              if (snapshot.hasData) {
                List<dynamic> lExpenses =
                    snapshot.data!.data()?["LargeExpenses"];
                List<Widget> w = [const SizedBox(height: 5)];
                for (var expense in lExpenses) {
                  w.add(ListTile(
                    title: Text(
                      expense["Title"],
                      style: const TextStyle(fontSize: 19, color: Colors.white),
                    ),
                    trailing: Text("${expense["Amount"]}",
                        style: const TextStyle(
                            fontSize: 17.5, color: Colors.white)),
                  ));
                }
                w.add(const SizedBox(height: 10));
                w.add(
                  Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: MyTextButton(
                          bgColor: Colors.green,
                          buttonName: "Add Large Expense",
                          onTap: () => addLargeExpense(),
                          textColor: Colors.white,
                        )),
                  ),
                );
                w.add(const SizedBox(height: 15));
                return Padding(
                  padding: const EdgeInsets.only(top: 25, right: 25, left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: w,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("Error ${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }
          }),
    ],
  );
}
