import 'package:flutter/material.dart';

enum SlideDirection { Right, Left }

class SlideRouteTransition<T> extends PageRouteBuilder<T> {
  SlideRouteTransition({ this.widget, this.direction }) : super(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: direction == SlideDirection.Right ? 
              Offset(-1.0, 0.0) : 
              Offset(1.0, 0.0),
            end: Offset.zero
          ).animate(CurvedAnimation(curve: Curves.ease, parent: animation)),
          child: child,
        );
      });

  final Widget widget;
  final SlideDirection direction;
}
