import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/auth.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

class LoginPage extends StatefulWidget {
  LoginPage({ Key key }) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  String email;
  String password;

  AnimationController animController;
  Animation<double> anim;
  bool loggingIn;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    loggingIn = false;

    animController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 1500),      
    );

    anim = CurveTween(curve: Curves.easeInOutExpo).animate(animController);
  }

  // TODO: Add error field beneath text fields
  // TODO: Create signup page

  @override
  Widget build(BuildContext context) {
    double sidePadding = 38.0;
    double spacing = 18.0;
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: sidePadding, right: sidePadding),
            child: Container(
              constraints: BoxConstraints(maxHeight: 650),              
              child: Column(
                children: [
                  Spacer(flex:2),
                  Text('Game Log', style: TextStyle(fontSize: 62.0, color: defaultGray, fontWeight: FontWeight.w300)),            
                  Spacer(flex: 1),
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: AppTextField(
                      // autofocus: true,
                      inputType: TextInputType.emailAddress,
                      label: 'Email',
                      controller: TextEditingController(text: email),
                      onChanged: _updateEmailField,           
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing + 16.0),
                    child: AppTextField(
                      label: 'Password',
                      controller: TextEditingController(text: password),
                      onChanged: _updatePasswordField,
                      hiddenField: true,
                    )
                  ),
                  RaisedButton(
                    onPressed: loggingIn ? null : _signIn,
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(lrPadding, 8.0, lrPadding, 8.0),
                      child: Text('Sign In'),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(lrPadding, headerPaddingTop, lrPadding, lrPadding),
                      child: AnimatedBuilder(
                        animation: animController,
                        builder: (context, widget) {
                          return Transform(
                            transform: Matrix4.rotationZ(getRotation()),
                            alignment: Alignment.center,
                            child: DecoratedBox(
                              child: Container(),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/pawn-and-dice.png')
                                ) 
                              ) 
                            )
                          );
                        },
                      ) 
                    ),      
                  ),
                ]              
              )
            )
          )
        )
      ),
    );
  }


  double getRotation() {
    double progress = anim.value;
    double offset = sin(progress * pi * 6);
    return offset/6;
  }

  void _updateEmailField(String str) {
    setState(() {
      if (str == null) email = '';
      else email = str;
    });
  }

  void _updatePasswordField(String str) {
    setState(() {
      if (str == null) password = '';
      else password = str;
    });
  }

  void _signIn() async {   
    setState(() {
      loggingIn = true;
    });       
    animController.repeat();

    dynamic response = await tryLogin(email, password);
    animController.animateTo(1.0);

    if (response is FirebaseUser) {
      CurrentUser.setUser(response);
      Navigator.pushReplacementNamed(context, '/home');
    } 
    else {
      switch (response.code) {
        case 'ERROR_WRONG_PASSWORD': 
          print('wrong password');
          break;
        default:
          print('Unknown error');
          break;
      }
    } 

    setState(() {
      loggingIn = false;
    });
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}