import 'package:flutter/material.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:game_log/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    List<DropdownMenuItem> winConditionItems = winConditions();
    List<DropdownMenuItem> gameTypeItems = gameTypes();
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: Theme.of(context).textTheme.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: saveGame
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
                    items: winConditionItems,
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
                  Text('Game Type', style: textStyle),
                  Spacer(),
                  DropdownButton(                
                    hint: Text('Game Type'),
                    value: game.type,
                    items: gameTypeItems,
                    onChanged: (type) => setState(() => { game.type = type }),
                  ),
                ]
              ),
            )
          ]
        ),
      )
    );
  }

  List<DropdownMenuItem> winConditions() {
    List<DropdownMenuItem> items = [];
    for (WinConditions condition in WinConditions.values) {
      items.add(DropdownMenuItem(
        child: Text(winConditionString(condition)),
        value: condition
      ));
    }
    return items;
  }

  List<DropdownMenuItem> gameTypes() {
    List<DropdownMenuItem> items = [];
    for (GameType type in GameType.values) {
      items.add(DropdownMenuItem(
        child: Text(gameTypeString(type)),
        value: type
      ));
    }
    return items;
  }

  void saveGame() async {
    if (game.name != '') {
      Map<String, dynamic> obj = { 
        'bggid': game.bggId,
        'name': game.name,
        'type': game.gameTypeEnumString(),
        'wincondition': game.winConditionEnumString(),
      };

      if (game.dbRef == null) {
        game.dbRef = await CurrentUser.ref.collection('games').add(obj);     
      }
      else {
        game.dbRef.updateData(obj);
      }
      
      Navigator.pop(context, game);
    } else {
      showDialog(
        context: context,        
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Oh Dear...'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('You need to fill out the game name field!'),
                ],
              ),
            ),
            actions: [
              FlatButton(
                padding: EdgeInsets.only(right: 18.0),
                child: Text(
                  'Oops!',
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0
                  )
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );    
    }
  }
  
}