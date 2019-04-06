import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

class AuthenticationWidget extends StatelessWidget {
  AuthenticationWidget({this.waitingScreen, this.authenticatedScreen, this.unauthenticatedScreen, Key key}) :
    super(key: key);

  final Widget waitingScreen;
  final Widget authenticatedScreen;
  final Widget unauthenticatedScreen;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitingScreen;
        } else {
          if (snapshot.hasData) {
            CurrentUser.setUser(snapshot.data);
            return authenticatedScreen;
          }
          return unauthenticatedScreen;
        }
      }
    );
  }

  static Future<dynamic> tryLogin(String email, String password) async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return user;
    } catch (err) {    
      // https://docs.google.com/spreadsheets/d/1FDn0rRRYjgXMwc_FIAxO7_cQh69q5VXgQt7Hmvyb1Sg/edit#gid=0
      print('LOGIN ERROR: ' + err.message);
      return err;
    }
  }

  static Future<dynamic> trySignup(String email, String password) async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return user;
    } catch (err) {
      print('SIGNUP ERROR: ' + err.message);
      return err;
    }
  }
}

