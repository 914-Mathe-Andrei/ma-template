import 'package:flutter/material.dart';

Future<DateTime?> openDateTimePicker(BuildContext context) async {
  DateTime? dateTime = DateTime.now().copyWith(
    second: 0,
    microsecond: 0,
    millisecond: 0,
  );

  final date = await showDatePicker(
    context: context,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    initialDate: dateTime,
    firstDate: dateTime,
    lastDate: dateTime.add(const Duration(days: 365)),
  );

  if (date == null) {
    return null;
  }

  if (!context.mounted) {
    return null;
  }

  final time = await showTimePicker(
    context: context,
    initialEntryMode: TimePickerEntryMode.inputOnly,
    initialTime: TimeOfDay.fromDateTime(dateTime),
  );

  if (time == null) {
    return null;
  }

  dateTime = dateTime.copyWith(
    year: date.year,
    month: date.month,
    day: date.day,
    hour: time.hour,
    minute: time.minute,
  );

  return dateTime;
}