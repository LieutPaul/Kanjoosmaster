import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanjoosmaster/widgets/my_text_button.dart';

Column getExpenseCategories(BuildContext context) {
  var currentUser = FirebaseAuth.instance.currentUser;
  Future<void> addCategory() async {
    String newCategory = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Enter New Category",
                  style: TextStyle(color: Colors.black)),
              content: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    hintText: "Enter new Category",
                    hintStyle: TextStyle(color: Colors.grey)),
                onChanged: (value) {
                  newCategory = value;
                },
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
                      if (newCategory != "") {
                        Navigator.of(context).pop(newCategory);
                      } else {
                        Fluttertoast.showToast(msg: "Invalid Input");
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ));
    if (newCategory.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .update({
        "ExpenseCategories": FieldValue.arrayUnion(
            [newCategory[0].toUpperCase() + newCategory.substring(1)])
      });
    }
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
                var point = 1;
                List<dynamic> c = snapshot.data!.data()?["ExpenseCategories"];
                List<Widget> w = [const SizedBox(height: 5)];
                for (var category in c) {
                  w.add(Text(
                    "$point. $category",
                    style: const TextStyle(color: Colors.white),
                  ));
                  w.add(const SizedBox(height: 10));
                  point++;
                }
                w.add(const SizedBox(height: 15));
                w.add(
                  Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: MyTextButton(
                          bgColor: Colors.green,
                          buttonName: "Add Category",
                          onTap: () => addCategory(),
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
