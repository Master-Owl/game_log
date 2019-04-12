import 'dart:async';
import 'package:flutter/material.dart';

const int splashScreenDuration = 1500;

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key, this.animate: true}) : super(key: key);
  final bool animate;
  @override
  _SplashScreenState createState() => _SplashScreenState(animate);
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  _SplashScreenState(this.animate) : super();

  AnimationController _controller; 
  bool animate;
  int time;
  int pause;

  @override
  void initState() {
    super.initState();

    pause = 100;
    time = (splashScreenDuration/2).round() - (pause/2).round();
    _controller = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: time),      
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height;
    _controller.forward().then((x) =>
      Future.delayed(Duration(milliseconds: pause)).then((x) =>
        _controller.animateBack(0, curve: Curves.easeIn)
      )
    );
    return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        color: Colors.white,
        child: Column(
          children: [
            Spacer(),
            FadeTransition(
              opacity: Tween<double>(begin: animate? 0 : 1.0, end: 1.0).animate(_controller),
              child: Image.asset('assets/pawn-and-dice.png')
            ),
            Spacer()
          ]
        ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}