import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';

class LogsPage extends StatelessWidget {
  LogsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(lrPadding,headerPaddingTop,lrPadding,16.0),
            child: Column(
              children: [
                Center(child:Text("Logs", style: Theme.of(context).textTheme.headline))
              ],
            )
        )    );
  }
}