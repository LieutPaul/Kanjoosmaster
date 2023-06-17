import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanjoosmaster/helper/helper.dart';
import 'package:kanjoosmaster/widgets/checkbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/widgets/expense_component.dart';
import '../widgets/custom_dropdown.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  DateFormat formatter = DateFormat('yyyy/MM/dd');
  String _selectedDate = "";
  List<DateTime> week = [];
  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  @override
  void initState() {
    super.initState();
    _selectedDate = formatter.format(DateTime.now()).substring(0, 10);
    week = getWeekFromLastSunday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedDate.substring(_selectedDate.length - 2) ==
              DateTime.now().day.toString()
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => addExpense(),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : null,
      backgroundColor: Colors.black.withOpacity(0.80),
      body: body(),
    );
  }

  Future<void> addExpense() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();

    List<dynamic>? eCategories = documentSnapshot.data()?["ExpenseCategories"];
    List<String> expenseCategories = [];
    for (String c in eCategories!) {
      expenseCategories.add(c);
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
        builder: (context) => AlertDialog(
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
                        decoration: const InputDecoration(
                            hintText: "Title of Expense",
                            hintStyle: TextStyle(color: Colors.grey)),
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
                      const Text("Expense Category:"),
                      const SizedBox(height: 10),
                      CustomDropdownButton2(
                          hint: 'Select Item',
                          dropdownItems: expenseCategories,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyCheckbox(
                            initialValue: earning,
                            onChanged: (value) {
                              earning = value;
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
            ));
    if (canAdd) {
      await FirebaseFirestore.instance.collection("Expenses").add({
        "Title": expenseTitle,
        "Date": formatter.format(DateTime.now()).substring(0, 10),
        "Description": expenseDescription,
        "Category": expenseCategory,
        "Amount": expenseAmount,
        "Earning": earning,
        "Users": [currentUser!.email]
      });
    }
  }

  Widget body() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          topBar(),
          Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Expenses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final List<Widget> expenseWidgets = [];
                    expenseWidgets.add(Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15),
                      child: Text(formatDate(_selectedDate),
                          style: const TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 180, 218, 255))),
                    ));
                    final documents = snapshot.data?.docs;
                    if (documents != null) {
                      for (var doc in documents) {
                        final data = doc.data();
                        final List<dynamic>? users = data['Users'];
                        if (users != null &&
                            users.contains(currentUser!.email) &&
                            data['Date'] != null &&
                            data['Date'] == _selectedDate) {
                          expenseWidgets.add(
                            Expense(
                                expenseId: doc.id,
                                title: data['Title'],
                                description: data["Description"],
                                category: data['Category'],
                                earning: data['Earning'],
                                amount: data['Amount']),
                          );
                        }
                      }
                    }

                    return ListView(children: expenseWidgets);
                  }
                },
              )),
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
    String date = formatter.format(week[index]).substring(0, 10);
    return Column(
      children: [
        Text(
          days[index],
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = formatter.format(week[index]).substring(0, 10);
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _selectedDate == date ? Colors.white : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                date.substring(date.length - 2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: _selectedDate == date ? Colors.blue : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
