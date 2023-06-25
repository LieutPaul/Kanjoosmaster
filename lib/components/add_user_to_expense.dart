import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> doesUserExist(String email) async {
  try {
    List<String> signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return signInMethods.isNotEmpty;
  } catch (e) {
    return false;
  }
}

Future<void> addUser(BuildContext context, String expenseId) async {
  var doc = FirebaseFirestore.instance.collection("Expenses").doc(expenseId);
  DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();
  Map<String, dynamic> data = {};
  if (snapshot.exists) {
    data = snapshot.data()!;
  }
  String user = "";
  int amount = 0;
  // ignore: use_build_context_synchronously
  await showDialog(
      context: context,
      builder: (builder) => AlertDialog(
              title: const Text("Add a User",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      const SizedBox(height: 15),
                      TextField(
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "User's Email",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          user = value;
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Amount",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            amount = parsedValue;
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
                      "Close",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () async {
                      if (amount >= data['Amount'] ||
                          user == "" ||
                          amount <= 0 ||
                          await doesUserExist(user) == false) {
                        Fluttertoast.showToast(msg: "Enter valid Details");
                      } else {
                        // ignore: use_build_context_synchronously
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
                                    Text('Adding User...'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        user = user.trim();
                        data["Amount"] -= amount;
                        await FirebaseFirestore.instance
                            .collection("Expenses")
                            .doc(expenseId)
                            .update(data);
                        data["Users"] = [user];
                        data["Amount"] = amount;
                        // Adding the category to the new user if it isn't already there.
                        var userDocRef = FirebaseFirestore.instance
                            .collection("Users")
                            .doc(user);
                        var userDoc = await userDocRef.get();

                        if (userDoc.exists) {
                          var expenseCategories =
                              userDoc.data()?["ExpenseCategories"];

                          expenseCategories =
                              FieldValue.arrayUnion([data["Category"]]);

                          await userDocRef
                              .update({"ExpenseCategories": expenseCategories});
                        }
                        await FirebaseFirestore.instance
                            .collection("Expenses")
                            .add(data);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.black),
                    )),
              ]));
}
