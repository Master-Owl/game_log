import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/widgets/autocomplete-textfield.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/data/game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePickerWidget extends StatefulWidget {
  GamePickerWidget({Key key, this.selectedGame, @required this.onItemSelected})
      : super(key: key);

  final Game selectedGame;
  final Function(Game) onItemSelected;

  @override
  _GamePickerState createState() =>
      _GamePickerState(selectedGame, onItemSelected);
}

class _GamePickerState extends State<GamePickerWidget> {
  _GamePickerState(this.selectedGame, this.onItemSelected);

  GlobalKey _key = GlobalKey<AutoCompleteTextFieldState<Game>>();
  Game selectedGame;
  List<Game> gameList;
  Function(Game) onItemSelected;
  InputDecoration decoration;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    gameList = globalGameList;
    if (gameList.length == 0) {
      getGames();
    }
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    decoration = InputDecoration(
      labelText: 'Game Title',
      suffixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          borderSide: BorderSide(color: Theme.of(context).accentColor)),
      contentPadding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
    );

    return selectedGame == null
        ? AutoCompleteTextField<Game>(
            key: _key,
            focusNode: focusNode,
            submitOnSuggestionTap: true,
            suggestions: gameList,
            itemFilter: (game, query) =>
                game.name.toLowerCase().contains(query.toLowerCase()),
            decoration: decoration,
            itemSubmitted: (game) {
              setState(() {
                selectedGame = game;
              });
              onItemSelected(game);
            },
            itemSorter: (a, b) => a.name.compareTo(b.name),
            itemBuilder: (context, game) {
              return Padding(
                  padding: EdgeInsets.all(6.0),
                  child: ListTile(title: Text(game.name)));
            },
          )
        : TextField(
            decoration: decoration,
            controller: TextEditingController(text: selectedGame.name),
            onTap: () => setState(() {
              selectedGame = null;
              Future.delayed(Duration(milliseconds: 50)).then((x) {
                FocusScope.of(context).requestFocus(focusNode);                  
              });
            }),
          );
  }

  void getGames() async {
    QuerySnapshot qs =
        await Firestore.instance.collection('games').getDocuments();
    globalGameList.clear();
    for (DocumentSnapshot doc in qs.documents) {
      globalGameList.add(Game(
          bggId: doc.data['bggid'],
          name: doc.data['name'],
          condition: winConditionFromString(doc.data['wincondition']),
          type: gameTypeFromString(doc.data['type']),
          dbRef: doc.reference));
    }
    setState(() => {gameList = globalGameList});
  }
}
