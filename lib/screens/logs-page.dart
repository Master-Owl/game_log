import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/log-list.dart';
import 'package:game_log/screens/edit-log-page/edit-log-page.dart';

class LogsPage extends StatefulWidget {
  LogsPage({Key key, this.subpages}) : super(key: key);

  final List<Widget> subpages;

  @override
  _LogsPageState createState() => _LogsPageState(subpages);
}

class _LogsPageState extends State<LogsPage> with SingleTickerProviderStateMixin {
  _LogsPageState(this.subpages);

  List<Widget> subpages;
  int _currentSubpageIdx;

  AnimationController animController;
  Animation<double> anim;

  @override
  void initState() {
    super.initState();

    _currentSubpageIdx = 0;
    animController = AnimationController(vsync: this, duration: animDuration);
    anim = Tween(begin: 0.0, end: 1.0).animate(animController);
  }

  @override
  Widget build(BuildContext context) {
    subpages = [              
      LogList()
    ];
    animController.forward();
    
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.only(top: headerPaddingTop),
            child: Column(
              children: [
                FadeTransition(
                  opacity: anim,
                  child: subpages[_currentSubpageIdx]
                )
              ],
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditLogPage()))
          },
        ),
      );
  }
}