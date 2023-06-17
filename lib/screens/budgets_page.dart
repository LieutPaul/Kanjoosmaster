import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanjoosmaster/helper/helper.dart';

class BudgetsWidget extends StatefulWidget {
  const BudgetsWidget({super.key});

  @override
  State<BudgetsWidget> createState() => _BudgetsWidgetState();
}

class _BudgetsWidgetState extends State<BudgetsWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;
  DateFormat formatter = DateFormat('MMM yyyy/MM');
  String _selectedMonth = "";
  List<String> months = [];

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
      body: body(),
    );
  }

  Widget body() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          topBar(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Text(_selectedMonth,
                style: const TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 180, 218, 255))),
          )
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

  Future<void> _addBudget() async {
    await showDialog(context: context, builder: (contex) => AlertDialog());
  }
}
