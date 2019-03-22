import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/screens/edit-log-page/edit-log-page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final String pageTitle = 'GameLog';

  AnimationController animController;

  @override
  void initState() {
    super.initState();
    animController =AnimationController(vsync: this, duration: animDuration);
  }

  @override
  Widget build(BuildContext context) {
    animController.fling();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(lrPadding,headerPaddingTop,lrPadding,0),
        child: FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(animController),
          child: Column(
            children: [
              Center(
                  child: Text(
                    pageTitle,
                    style: Theme.of(context).textTheme.headline
                  )
              ),
              Padding(
                padding:EdgeInsets.only(top: 200.0),
                child: RaisedButton(
                  onPressed: _createLog,
                  padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
                  child: Text('Create Log', style: Theme.of(context).textTheme.button),
                  color: Theme.of(context).primaryColor,
                )
              ),
              Padding(
                padding:EdgeInsets.only(top: 24.0),
                child: RaisedButton(
                  onPressed: _addGame,
                  padding:  EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
                  child: Text('Add Game', style: Theme.of(context).textTheme.button),
                  color: Theme.of(context).primaryColor,
                )
              ),
            ],
          )
        )
      )
    );
  }

  void _createLog() {
    Navigator.pushNamed(context, '/edit-log-page', arguments: { 'gameplay': null });
  }

  void _addGame() {
    Navigator.pushNamed(context, '/edit-game-page', arguments: { 'game': null });
  }
}
