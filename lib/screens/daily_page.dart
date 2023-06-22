import 'package:kanjoosmaster/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/components/expense_component.dart';
import '../components/add_expense.dart';

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
              onPressed: () => addExpense(context),
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
                                date: data["Date"],
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
