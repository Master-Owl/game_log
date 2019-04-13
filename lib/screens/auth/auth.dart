import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';
import 'package:game_log/screens/other/splashscreen.dart';

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
  bool hasNavigated;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      authStateController.add(user == null ? 1 : 3);
      if (user != null) CurrentUser.setUser(user);
    });
    hasNavigated = false;
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
              Future.delayed(Duration(milliseconds: splashScreenDuration + 100)).then(
                (x) { 
                  if (!hasNavigated) {
                    hasNavigated = true;
                    Navigator.pushReplacementNamed(context, '/home'); 
                  }
                }
              );              
              return waitingScreen;
          }
        }
        return waitingScreen;
      },
    );
  }
}