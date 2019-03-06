import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(lrPadding,headerPaddingTop,lrPadding,16.0),
            child: Column(
              children: [
                Center(child:Text("Settings", style: Theme.of(context).textTheme.headline))
              ],
            )
        )    );
  }
}