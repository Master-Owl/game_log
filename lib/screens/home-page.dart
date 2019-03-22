import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // Fields in a Widget subclass are
  // always marked "final".

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final String pageTitle = 'GameLog';

  AnimationController animController;
  bool _firstLoad;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this, duration: animDuration);
    _firstLoad = true;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    animController.fling();

    return FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(animController),
        child: Scaffold(
            body: Container(
                padding: const EdgeInsets.fromLTRB(
                    lrPadding, headerPaddingTop, lrPadding, 0),
                child: Column(
                  children: [
                    Center(
                        child:
                            Text(pageTitle, style: theme.textTheme.headline)),
                    Container(
                      padding: EdgeInsets.only(top: 50.0),
                      constraints: BoxConstraints.tightFor(height: 500.0),
                      child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          children: animateCards(Duration(milliseconds: 550),
                              Duration(milliseconds: 150))),
                    )
                  ],
                ))));
  }

  void _createLog() {
    Navigator.pushNamed(context, '/edit-log-page', arguments: {'gameplay': null});
  }

  void _addGame() {
    Navigator.pushNamed(context, '/edit-game-page', arguments: {'game': null});
  }

  void _addPlayer() {
    Navigator.pushNamed(context, '/edit-player-page', arguments: {'player': null});
  }

  void _goToSettings() {
    Navigator.pushNamed(context, '/settings-page');
  }

  List<Widget> animateCards(Duration animTime, Duration offset) {
    ThemeData theme = Theme.of(context);
    List<Widget> cards = [];
    cards.add(Card(
        color: theme.primaryColor,
        child: InkWell(
          child: Icon(Icons.playlist_add, color: Colors.white, size: 80.0),
          onTap: _createLog)));

    cards.add(Card(
        color: theme.accentColor,
        child: InkWell(
            child: Icon(Icons.developer_board, color: Colors.white, size: 80.0),
            onTap: _addGame)));

    cards.add(Card(
      color: theme.accentColor,
      child:InkWell(
        child: Icon(Icons.person_add, color: Colors.white, size: 80.0),
        onTap: _addPlayer)));

    cards.add(Card(
        color: theme.primaryColor,
        child: InkWell(
          child: Icon(Icons.settings, color: Colors.white, size: 80.0),
          onTap: _goToSettings)));

    if (_firstLoad) {
      _firstLoad = false;
      List<Widget> transitions = [];
      List<Animation<double>> anims = [];
      List<AnimationController> animControllers = [];

      for (int i = 0; i < 4; ++i) {
        AnimationController controller =
            AnimationController(vsync: this, duration: animTime);
        Animation<double> anim = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(curve: Curves.easeOutBack, parent: controller));
        anims.add(anim);
        animControllers.add(controller);
      }

      for (int i = 0; i < cards.length; ++i) {
        transitions.add(ScaleTransition(
          scale: anims[i],
          child: cards[i],
        ));
      }

      delayAnimations(animControllers, offset);
      return transitions;
    }

    return cards;
  }

  void delayAnimations(List<AnimationController> controllers, Duration offset) async {
    for (AnimationController ctrl in controllers) {
      ctrl.forward();
      await Future.delayed(offset);
    }
  }
}
