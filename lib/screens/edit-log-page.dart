import 'package:flutter/material.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/player-list.dart';

class EditLogPage extends StatefulWidget {
  EditLogPage({Key key, this.gamePlay }) : super(key: key);

  final GamePlay gamePlay;

  @override
  _EditLogState createState() => _EditLogState(gamePlay);
}

class _EditLogState extends State<EditLogPage> {
  _EditLogState(this.gamePlay);

  GamePlay gamePlay;
  bool isNewLog = false;
  String appBarTitle = '';

  @override
  void initState() {
    isNewLog = gamePlay == null;
    appBarTitle = isNewLog ? 'New Log' : 'Edit Log';

    if (isNewLog) gamePlay = new GamePlay();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // gamePlay = GamePlay(players: mockPlayerData);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: Theme.of(context).textTheme.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () => { Navigator.pop(context) }
          )
        ]
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(lrPadding, 24.0, lrPadding, 16.0),
        child: Column(
          children: [
            AppTextField(
              controller: TextEditingController(text: gamePlay.game.name),
              onChanged: (str) => { gamePlay.game.name = str },
              label: 'Game Title',
            ),
            PlayerList(gameplay: gamePlay)
          ],
        )
      )
    );
  }

  void saveLog() {}
}