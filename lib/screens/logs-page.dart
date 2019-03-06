import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  LogsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(16.0,30.0,16.0,16.0),
            child: Column(
              children: [
                Center(child:Text("Logs", style: Theme.of(context).textTheme.title))
              ],
            )
        )    );
  }
}