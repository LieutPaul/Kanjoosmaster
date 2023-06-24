import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kanjoosmaster/helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpendingAnalysis extends StatefulWidget {
  final String selectedMonth;
  const SpendingAnalysis({super.key, required this.selectedMonth});

  @override
  State<SpendingAnalysis> createState() => _SpendingAnalysisState();
}

class _SpendingAnalysisState extends State<SpendingAnalysis> {
  var currentUser = FirebaseAuth.instance.currentUser;
  List<int> cumExp = []; // Cumulative Expenses
  List<int> exp = [];
  List<int> ear = [];
  Future<void> getLineSeries() async {
    Map<String, int> expenses = {};
    Map<String, int> earnings = {};
    cumExp = []; // Cumulative Expenses
    exp = [];
    ear = [];
    var doc = await FirebaseFirestore.instance.collection("Expenses").get();
    for (var expense in doc.docs) {
      if (expense["Users"].contains(currentUser!.email) &&
          widget.selectedMonth.substring(4) ==
              expense["Date"].substring(0, 7)) {
        if (expense["Earning"] == false) {
          if (expenses.keys.contains(expense["Date"].substring(8)) == false) {
            expenses[expense["Date"].substring(8)] = expense["Amount"]!;
          } else {
            expenses[expense["Date"].substring(8)] =
                expenses[expense["Date"].substring(8)]! +
                    (expense["Amount"] as int);
          }
        } else {
          if (earnings.keys.contains(expense["Date"].substring(8)) == false) {
            earnings[expense["Date"].substring(8)] = expense["Amount"]!;
          } else {
            earnings[expense["Date"].substring(8)] =
                earnings[expense["Date"].substring(8)]! +
                    (expense["Amount"] as int);
          }
        }
      }
    }
    int days = getNumberOfDaysInMonth(widget.selectedMonth);
    int currExp = 0, currEarn = 0;
    for (int day = 1; day <= days; day++) {
      exp.add(expenses[day.toString()] ?? 0);
      currExp += expenses[day.toString()] ?? 0;
      cumExp.add(currExp);
    }
    for (int day = 1; day <= days; day++) {
      currEarn += earnings[day.toString()] ?? 0;
      ear.add(currEarn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: FutureBuilder(
          future: getLineSeries(),
          builder: (context, snapshot) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 15, top: 15),
                  child: Text(
                      "Spending Analysis for ${widget.selectedMonth.substring(0, 3)}",
                      style: const TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 180, 218, 255))),
                ),
                const Text(
                  "Long Press and hold anywhere on the chart and drag your finger to view the coordinates of the point",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                SfCartesianChart(
                  title: ChartTitle(text: "Cumulative Transaction Values"),
                  backgroundColor: Colors.white,
                  primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Days')),
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    tooltipSettings: const InteractiveTooltip(
                      enable: true,
                      format: 'point.x : point.y',
                    ),
                  ),
                  series: <ChartSeries>[
                    LineSeries<int, int>(
                        dataSource: cumExp,
                        xValueMapper: (int value, int index) => index + 1,
                        yValueMapper: (int value, _) => value,
                        name: 'Cumulative Expenses',
                        color: Colors.red),
                    LineSeries<int, int>(
                        dataSource: ear,
                        xValueMapper: (int value, int index) => index + 1,
                        yValueMapper: (int value, _) => value,
                        name: 'Cumulative Earnings',
                        color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 10),
                SfCartesianChart(
                  title: ChartTitle(text: "Day-To-Day Expenses"),
                  backgroundColor: Colors.white,
                  primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Days')),
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    tooltipSettings: const InteractiveTooltip(
                      enable: true,
                      format: 'point.x : point.y',
                    ),
                  ),
                  series: <ChartSeries>[
                    LineSeries<int, int>(
                        dataSource: exp,
                        xValueMapper: (int value, int index) => index + 1,
                        yValueMapper: (int value, _) => value,
                        name: 'Expenses',
                        color: Colors.red),
                  ],
                ),
                const SizedBox(height: 50)
              ],
            );
          }),
    );
  }
}
