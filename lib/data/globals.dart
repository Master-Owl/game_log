library game_log.globals;
import 'dart:async';
import 'package:flutter/material.dart';

// https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248
StreamController<int> tabIdxController = StreamController<int>.broadcast();

const tabs = {
  'settings': 0,
  'home': 1,
  'logs': 2
};

const Color defaultGray = Colors.black54;
const double lrPadding = 16.0;
const double headerPaddingTop = 48.0;