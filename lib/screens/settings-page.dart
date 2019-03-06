import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(16.0,30.0,16.0,16.0),
            child: Column(
              children: [
                Center(child:Text("Settings", style: Theme.of(context).textTheme.title))
              ],
            )
        )    );
  }
}