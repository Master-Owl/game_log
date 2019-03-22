import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/slide-transition.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(vsync: this, duration: animDuration);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    animController.forward();

    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top:headerPaddingTop),
            child: Column(
              children: [
                SlideTransition(
                  position:slideAnimation(animController, SlideDirection.Right),
                  child: Center(child:Text("Settings", style: Theme.of(context).textTheme.headline))
                )
              ],
            )
        )
      );
  }
}