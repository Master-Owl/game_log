import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: Theme.of(context).textTheme.title),
        ),
        body: Container(
            padding: EdgeInsets.only(top:headerPaddingTop),
            child: Column(
            )
        )
      );
  }
}