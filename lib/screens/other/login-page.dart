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
  Widget errorMessageWidget;
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
    errorMessageWidget = Container(height: 0);
  }

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
                  errorMessageWidget,
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
      String errText = '';
      switch (response.code) {
        case 'ERROR_WRONG_PASSWORD': 
          errText = 'That password is incorrect.';
          break;
        case 'ERROR_USER_NOT_FOUND':
          errText = 'That username isn\'t registered.';
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
        case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
          errText = 'That email has already been registered.';
          break;
        case 'ERROR_INVALID_EMAIL':
          errText = 'The email provided is invalid.';
          break;
        case 'ERROR_OPERATION_NOT_ALLOWED':
          errText = 'That operation isn\'t allowed. What did you even do?';
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          errText = 'There was a network error. Please try again shortly.';
          break;
        default:
          errText = response.message;
          break;
      }
      setState(() {
        errorMessageWidget = Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(errText, style: TextStyle(color: Theme.of(context).errorColor)));
      });
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