import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget authenticationWidget(
  Widget waitingScreen, 
  Widget Function(FirebaseUser) authenticatedScreen, 
  Widget unauthenticatedScreen) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitingScreen;
        } else {
          if (snapshot.hasData) {
            return authenticatedScreen(snapshot.data);
          }
          return unauthenticatedScreen;
        }
      }
    );
}

Future<dynamic> tryLogin(String email, String password) async {
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

Future<dynamic> trySignup(String email, String password) async {
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