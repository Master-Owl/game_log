import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';

Color determineTextColor(Color background) {
  int r = background.red;
  int g = background.green;
  int b = background.blue;
  if ((r*0.299 + g*0.587 + b*0.114) > 186) {
    return defaultBlack;
  }
  return defaultWhite;
}

String formatDate(DateTime date) {
  int day = date.day;
  int month = date.month;
  int yr = date.year;
  return '$month/$day/$yr';
}

String formatTimeOfDay(TimeOfDay time) {
  int hr = time.hour;
  String mn = time.minute < 10 ? '0${time.minute}' : time.minute.toString();
  String half = hr < 12 ? 'AM' : 'PM';
  if (half == 'PM') hr -= 12;
  return '$hr:$mn $half';
}

String formatTimeDuration(Duration time) {
  int hr = time.inHours;
  int min = time.inMinutes % 60;
  String minStr = min == 0 ? '00' : min < 10 ? '0$min' : min.toString();
  return '${hr}h ${minStr}m';
}