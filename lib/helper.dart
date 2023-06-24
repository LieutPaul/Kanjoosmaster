import 'package:intl/intl.dart';

List<DateTime> getWeekFromLastSunday() {
  DateTime today = DateTime.now();

  if (today.weekday == DateTime.sunday) {
    List<DateTime> week = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));
      week.add(day);
    }
    return week;
  } else {
    DateTime lastSunday = today.subtract(Duration(days: today.weekday));

    List<DateTime> week = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = lastSunday.add(Duration(days: i));
      week.add(day);
    }
    return week;
  }
}

String formatDate(String dateString) {
  DateTime date = DateFormat('yyyy/MM/dd').parse(dateString);
  DateFormat formatter = DateFormat('EEEE, d MMMM yyyy');
  String formattedDate = formatter.format(date);
  return formattedDate;
}

List<String> getMonthsBeforeAndAfter(List<String> monthsList) {
  final currentDate = DateTime.now();
  final formatter = DateFormat('MMM yyyy/MM');

  // Add four months before the current date
  for (int i = 4; i >= 0; i--) {
    final month = currentDate.subtract(Duration(days: 30 * i));
    final formattedMonth = formatter.format(month);
    monthsList.add(formattedMonth);
  }

  // Add two months after the current date
  for (int i = 0; i < 2; i++) {
    final month = currentDate.add(Duration(days: 30 * (i + 1)));
    final formattedMonth = formatter.format(month);
    monthsList.add(formattedMonth);
  }

  return monthsList;
}

int getNumberOfDaysInMonth(String dateString) {
  dateString = dateString.substring(4);
  List<String> parts = dateString.split('/');
  int year = int.parse(parts[0]);
  int month = int.parse(parts[1]);

  DateTime date = DateTime(year, month + 1, 0);
  int numberOfDays = date.day;

  return numberOfDays;
}

List<String> getFirstAndLastDatesOfMonth() {
  DateTime now = DateTime.now();
  DateTime firstDate = DateTime(now.year, now.month, 1);
  DateTime lastDate = DateTime(now.year, now.month + 1, 0);

  DateFormat formatter = DateFormat('dd/MM/yyyy');
  String formattedFirstDate = formatter.format(firstDate);
  String formattedLastDate = formatter.format(lastDate);

  return [formattedFirstDate, formattedLastDate];
}

bool isFirstDateBeforeOrSame(String firstDateStr, String secondDateStr) {
  DateTime firstDate = DateTime.parse(
      "${firstDateStr.substring(6, 10)}-${firstDateStr.substring(3, 5)}-${firstDateStr.substring(0, 2)}");
  DateTime secondDate = DateTime.parse(
      "${secondDateStr.substring(6, 10)}-${secondDateStr.substring(3, 5)}-${secondDateStr.substring(0, 2)}");

  return !secondDate.isBefore(firstDate);
}

String convertDateFormat(String dateString) {
  List<String> dateComponents = dateString.split('/');
  String year = dateComponents[0];
  String month = dateComponents[1];
  String day = dateComponents[2];

  return "$day/$month/$year";
}
