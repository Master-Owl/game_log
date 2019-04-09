import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

StreamController<int> authStateController = StreamController<int>.broadcast();

class AuthenticationWidget extends StatefulWidget {
  AuthenticationWidget({this.waitingScreen, this.loginScreen, this.signupScreen,  key}) :
    super(key: key);

  final Widget waitingScreen;
  final Widget loginScreen;
  final Widget signupScreen;

  @override
  _AuthenticationWidgetState createState() => _AuthenticationWidgetState(waitingScreen, loginScreen, signupScreen);
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  _AuthenticationWidgetState(this.waitingScreen, this.loginScreen, this.signupScreen) : super();

  Widget waitingScreen;
  Widget loginScreen;
  Widget signupScreen;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        authStateController.add(user == null ? 1 : 3);
        if (user != null) CurrentUser.setUser(user);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: 0,
      stream: authStateController.stream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          switch(snapshot.data) {
            case 0: return waitingScreen;
            case 1: return loginScreen;
            case 2: return signupScreen;
            default:
              Navigator.pushReplacementNamed(context, '/home');
              return waitingScreen;
          }
        }
        return waitingScreen;
      },
    );
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