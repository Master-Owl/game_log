import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Color determineTextColor(Color background) {
  int r = background.red;
  int g = background.green;
  int b = background.blue;
  if ((r*0.299 + g*0.587 + b*0.114) > 186) {
    return defaultBlack;
  }
  return defaultWhite;
}

Color getRandomColor() {
  List<Color> colors = [
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.blue,
    Colors.teal
  ];
  colors.shuffle();
  return colors[0];
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
  String minStr = min == 0 ? hr == 0 ? '0' : '00' : min < 10 ? '0$min' : min.toString();
  if (hr == 0) return '${minStr}m';
  return '${hr}h ${minStr}m';
}

DateTime readTimestamp(Timestamp stamp) {
  return DateTime.fromMillisecondsSinceEpoch(stamp.millisecondsSinceEpoch);
}

Future<dynamic> showConfirmDialog(BuildContext context, String title, String affirmativeText, String negativeText) {
  return showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) {
      ThemeData theme = Theme.of(context);
      TextStyle nopeStyle = TextStyle(color: theme.accentColor, fontSize: 22.0, fontWeight: FontWeight.w400);
      TextStyle yesStyle = TextStyle(color: theme.errorColor, fontSize: 22.0, fontWeight: FontWeight.w400);
      
      return SimpleDialog(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(title, style: theme.textTheme.title),
        children: [
          Row(
            children: [
              Spacer(),
              FlatButton(
                child: Text(negativeText, style: nopeStyle),
                textColor: theme.primaryColor,
                onPressed: () => { Navigator.pop(context, false) },
              ),
              FlatButton(
                child: Text(affirmativeText, style: yesStyle),
                textColor: theme.errorColor,
                onPressed: () => { Navigator.pop(context, true) },
              )
            ]
          )
        ]
      );
    }
  );
}