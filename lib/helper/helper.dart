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
