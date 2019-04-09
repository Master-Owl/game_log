import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:game_log/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/screens/auth/auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  String email;
  String password;
  String passwordVerify;
  bool makingNetworkCall;
  Widget errorMessageWidget;

  AnimationController animController;
  Animation<double> anim;

  @override
  void initState() {
    super.initState();
    makingNetworkCall = false;
    errorMessageWidget = Container(height:0);

    animController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 1500),      
    );

    anim = CurveTween(curve: Curves.easeInOutExpo).animate(animController);
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height;
    double sidePadding = 38.0;
    double spacing = 18.0;
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: sidePadding, right: sidePadding),
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),              
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 55.0),
                    child: Text('Game Log', style: TextStyle(fontSize: 62.0, color: defaultGray, fontWeight: FontWeight.w300)),  
                  ),
                  Row(
                    children: [
                      Spacer(flex: 3),
                      GestureDetector(
                        child: Text('Sign In', style: TextStyle(fontSize: 32.0, color: Colors.lightBlue, fontWeight: FontWeight.w300)),
                        onTap: () => authStateController.add(1) // go to login page
                      ),
                      Spacer(),
                      Text('Sign Up', style: TextStyle(fontSize: 32.0, color: defaultGray, fontWeight: FontWeight.w300)),          
                      Spacer(flex: 3)
                    ]
                  ),
                  Spacer(flex: 1),
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: AppTextField(
                      inputType: TextInputType.emailAddress,
                      label: 'Email',
                      controller: TextEditingController(text: email),
                      onChanged: _updateEmailField,           
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: AppTextField(
                      label: 'Password',
                      controller: TextEditingController(text: password),
                      onChanged: _updatePasswordField,
                      onSubmitted: _checkPasswords,
                      hiddenField: true,
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing + 8.0),
                    child: AppTextField(
                      label: 'Verify Password',
                      controller: TextEditingController(text: passwordVerify),
                      onChanged: _updatePasswordVerifyField,
                      onSubmitted: _checkPasswords,
                      hiddenField: true,
                    )
                  ),
                  RaisedButton(
                    onPressed: makingNetworkCall ? null : _signUp,
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(lrPadding, 8.0, lrPadding, 8.0),
                      child: Text('Create Account'),
                    ),
                  ),
                  errorMessageWidget,
                  Container(
                    height: 200.0,
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

  void _signUp() async {
    TextStyle errorTextStyle = TextStyle(color: Theme.of(context).errorColor);
    if (email == '') {
      setState(() {        
        errorMessageWidget = Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Email must be provided.', style: errorTextStyle)
        );
      });
      return;
    }
    if (password == '') {
      setState(() {        
        errorMessageWidget = Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Password cannot be blank.', style: errorTextStyle)
        );
      });
      return;
    }
    if (passwordVerify == '') {
      setState(() {        
        errorMessageWidget = Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Please verify your password.', style: errorTextStyle)
        );
      });
      return;
    }

    setState(() {
      makingNetworkCall = true;
    });       
    animController.repeat();

    dynamic response = await trySignup(email, password);
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
          child: Text(errText, style: errorTextStyle));
      });
    } 

    setState(() {
      makingNetworkCall = false;
    });
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

  void _updatePasswordVerifyField(String str) {
    setState(() {
      if (str == null) passwordVerify = '';
      else passwordVerify = str;
    });
  }

  void _checkPasswords(String str) {
    if (password == '' || passwordVerify == '') return;
    setState(() {
      if (password != passwordVerify) {
        errorMessageWidget = Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Passwords don\'t match!', style: TextStyle(color: Theme.of(context).errorColor))
        );
      } else {
        errorMessageWidget = Container(height:0);
      }
    });
  }

  double getRotation() {
    double progress = anim.value;
    double offset = sin(progress * pi * 6);
    return offset/6;
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}