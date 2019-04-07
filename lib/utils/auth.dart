import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

class AuthenticationWidget extends StatefulWidget {
  AuthenticationWidget({this.waitingScreen, this.unauthenticatedScreen, Key key}) :
    super(key: key);

  final Widget waitingScreen;
  final Widget unauthenticatedScreen;

  @override
  _AuthenticationWidgetState createState() => _AuthenticationWidgetState(waitingScreen, unauthenticatedScreen);
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  _AuthenticationWidgetState(this.waitingScreen, this.unauthenticatedScreen) : super();

  Widget waitingScreen;
  Widget unauthenticatedScreen;
  int authStatus; // 0 == false, 1 == true, -1 == undetermined

  @override
  void initState() {
    super.initState();
    authStatus = -1;
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        authStatus = user != null ? 1 : 0;
        if (user != null) CurrentUser.setUser(user);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(authStatus) {
      case -1: return waitingScreen;
      case 0: return unauthenticatedScreen;
      default:
        Navigator.pushReplacementNamed(context, '/home');
        return unauthenticatedScreen;
    }
  }
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