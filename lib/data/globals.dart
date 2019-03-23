library game_log.globals;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/widgets/slide-transition.dart';

// https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248
StreamController<int> tabIdxController = StreamController<int>.broadcast();

const tabs = {
  'games': 0,
  'home': 1,
  'logs': 2
};

const Color defaultGray = Colors.black54;
const Color defaultBlack = Colors.black87;
const Color defaultWhite = Colors.white;
const double lrPadding = 16.0;
const double headerPaddingTop = 48.0;
const Duration animDuration =Duration(milliseconds: 400);


Animation<Offset> slideAnimation(AnimationController animController, SlideDirection dir) {
  return Tween<Offset>(
    begin: dir == SlideDirection.Right ? 
      Offset(-1.0, 0.0) : 
      Offset(1.0, 0.0),
    end: Offset.zero).animate(CurvedAnimation(curve: Curves.ease, parent: animController));
}

List<Game> globalGameList = [];
