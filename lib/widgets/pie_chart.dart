import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

Widget customPieChart(
    BuildContext context, Map<String, double> data, String title) {
  return Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20))),
    margin: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 30),
    padding: const EdgeInsets.only(top: 20, bottom: 40),
    child: Column(children: [
      Text("Pie Chart of $title",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.w800)),
      const SizedBox(height: 40),
      PieChart(
        dataMap: data,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: title,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: false,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
      ),
    ]),
  );
}
