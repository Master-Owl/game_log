library game_log.globals;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/widgets/slide-transition.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
const Duration animDuration = Duration(milliseconds: 400);

const IconData starsIcon = IconData(0xe980, fontFamily: 'icomoon');
const IconData spinnerIcon = IconData(0xe982, fontFamily: 'icomoon');
const IconData messageBubbleIcon = IconData(0xe96d, fontFamily: 'icomoon');
const IconData logoutIcon = IconData(0xe9e4, fontFamily: 'icomoon');
const IconData addGameIcon = IconData(0x0042, fontFamily: 'gamelog');
const IconData gameIcon = IconData(0x0043, fontFamily: 'gamelog');

Animation<Offset> slideAnimation(AnimationController animController, SlideDirection dir) {
  return Tween<Offset>(
    begin: dir == SlideDirection.Right ? 
      Offset(-1.0, 0.0) : 
      Offset(1.0, 0.0),
    end: Offset.zero).animate(CurvedAnimation(curve: Curves.ease, parent: animController));
}

/// The current user will always be at position 0 in this list
List<Player> globalPlayerList = [];
List<Game> globalGameList = [];
List<GamePlay> globalGameplayList = [];

Future<List<Player>> getPlayersFromRefs(List<DocumentReference> pRefs) async {
  List<Player> players = [];
  for (DocumentReference ref in pRefs) {
    bool found = false;
    for (Player p in globalPlayerList) {
      if (p.dbRef == ref) {
        players.add(p);
        found = true;
        break;
      }
    }

    if (!found) {
      DocumentSnapshot snapshot = await ref.get();
      Player newPlayer = Player(
        name:snapshot.data['name'],
        color: Color(snapshot.data['color']),
        dbRef: ref        
      );
      globalPlayerList.add(newPlayer);
      players.add(newPlayer);
    }
  }

  return players;
}