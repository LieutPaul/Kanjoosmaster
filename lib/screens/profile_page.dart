import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var currentUser = FirebaseAuth.instance.currentUser;
  // void _signOut() {
  //   FirebaseAuth.instance.signOut();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.80),
      body: body(),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        topBar(),
        Expanded(
          child: ListView(
            children: [
              const Icon(Icons.person, size: 162, color: Colors.white),
              getUserName(),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Expense Categories",
                    style: TextStyle(
                        color: Color.fromARGB(255, 115, 177, 117),
                        fontSize: 20)),
              ),
              getCategories(),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Large Purchases You want to Make",
                    style: TextStyle(
                        color: Color.fromARGB(255, 115, 177, 117),
                        fontSize: 20)),
              ),
              getLargeExpenses()
            ],
          ),
        ),
      ],
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
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              "Profile Details",
              style: TextStyle(fontSize: 25, color: Colors.white),
            )),
          ),
        ),
      ),
    );
  }

  Row getUserName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  return Text(
                    "${(snapshot.data!.data())?["Name"]} ",
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error ${snapshot.error}");
                }

                return Text("${currentUser!.email}");
              }
            }),
        const Icon(Icons.edit, color: Colors.white)
      ],
    );
  }

  Column getCategories() {
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
                        child: ElevatedButton(
                      onPressed: () => addCategory(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Add Category",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    )),
                  );
                  w.add(const SizedBox(height: 15));
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 25, right: 25, left: 25),
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

  Column getLargeExpenses() {
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text("${expense["Amount"]}",
                          style: const TextStyle(color: Colors.white)),
                    ));
                  }
                  w.add(const SizedBox(height: 10));
                  w.add(
                    Center(
                        child: ElevatedButton(
                      onPressed: () => addLargeExpense(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Add Large Expense",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    )),
                  );
                  w.add(const SizedBox(height: 15));
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 25, right: 25, left: 25),
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
}
