import 'package:flutter/material.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/app-text-field.dart';

class EditGamePage extends StatefulWidget {
  EditGamePage({Key key, this.game }) : super(key: key);

  final Game game;

  @override
  _EditGameState createState() => _EditGameState(game);
}

class _EditGameState extends State<EditGamePage> {
  _EditGameState(this.game);

  String appBarTitle;
  bool isNewGame;
  Game game;

  @override
  void initState() {
    isNewGame = game == null;
    appBarTitle = isNewGame ? 'Add Game' : 'Edit Game';

    if (isNewGame) {
      game = Game();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color:defaultGray, fontSize: 26.0, fontWeight: FontWeight.w300);
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
              controller: TextEditingController(text: game.name),
              onChanged: (str) => setState(() => { game.name = str }),
              label: 'Game Title',
            ),
            Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Win Condition', style: textStyle),
                  Spacer(),
                  DropdownButton(                
                    hint: Text('Win Condition'),
                    value: game.condition,
                    items: [
                      DropdownMenuItem(
                        child: Text('Highest Score'),
                        value: WinConditions.score_highest,
                      ),
                      DropdownMenuItem(
                        child: Text('Lowest Score'),
                        value: WinConditions.score_lowest,
                      ),
                      DropdownMenuItem(
                        child: Text('Last Standing'),
                        value: WinConditions.last_standing,
                      )
                    ],
                    onChanged: (condition) => setState(() => { game.condition = condition }),
                  ),
                ]
              )
            ),
            Padding(
              padding:EdgeInsets.only(top: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Team Game', style: textStyle),
                  Spacer(),
                  Checkbox(
                    value: game.teamGame,
                    onChanged: (isTeamGame) => setState(() => { game.teamGame = isTeamGame }),
                    activeColor: Theme.of(context).accentColor,
                    checkColor: Colors.white,
                  )
                ]
              ),
            )
          ]
        ),
      )
    );
  }
}