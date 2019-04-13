import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/data/player.dart';
// import 'package:game_log/data/game.dart';
// import 'package:game_log/data/gameplay.dart';

/// Just a convenient wrapper class for the current signed in user
class CurrentUser {
  static FirebaseUser auth;
  static DocumentReference ref;
  static String id = '';
  static String token = '';
  static String _name = '';
  static Color _color;

  static Future<void> setUser(FirebaseUser value) async {
    if (value != null) {
      id = value.uid;
      ref = Firestore.instance.collection('users').document(id);
      auth = value;
      ref.get().then((refSnapshot) {
        _name = refSnapshot.data['name'];
        _color = refSnapshot.data['color'] != null ? Color(refSnapshot.data['color']) : null;
        _getPlayerList();
      });
      token = await value.getIdToken();
      return;
    }
    print('SET USER ERROR: The given FirebaseUser was null');
  }

  static Future<void> setNewUser(FirebaseUser value, String name) async {
    if (value != null) {
      id = value.uid;
      _name = name == null || name == '' ? value.email : name;
      _color = null;
      Firestore.instance.collection('users').document(id).setData({
        'name': _name
      }).then((x) {
        ref = Firestore.instance.collection('users').document(id);
      });      
      auth = value;

      globalGameList.clear();
      globalGameplayList.clear();
      globalPlayerList.clear();
      globalPlayerList.add(Player(
        name: _name,
        color: _color,
        dbRef: ref
      ));

      token = await value.getIdToken();
      return;
    }
    print('SET USER ERROR: The given FirebaseUser was null');
  }

  static void _getPlayerList() {
    List<Player> dbPlayers = [];

    globalPlayerList.clear();
    dbPlayers.add(Player(
      name: _name,
      color: _color,
      dbRef: ref
    ));
    
    CurrentUser.ref
      .collection('players')
      .getDocuments()
      .then((snapshot) {
        snapshot.documents.forEach((doc) {
          dbPlayers.add(Player(
            name: doc.data['name'],
            color: Color(doc.data['color']),
            dbRef: doc.reference
          ));
        });
        globalPlayerList = dbPlayers;
      });
  }

  static void signOut() {
    auth = null;
    ref = null;
    id = '';
    token = '';
    _name = '';
    _color = null;
    FirebaseAuth.instance.signOut();
  }

  static String get name => _name != null && _name != '' ? _name :
    auth != null && auth.displayName != null && auth.displayName != '' ? auth.displayName : 'Myself';

  static Color get color => _color != null ? color : Colors.grey;
}