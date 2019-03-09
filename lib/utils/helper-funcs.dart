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