import 'package:flutter/material.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/globals.dart';

class PlayerEditPage extends StatefulWidget {
  PlayerEditPage({ Key key, this.player }) : super(key: key);

  final Player player;

  _PlayerEditPageState createState() => _PlayerEditPageState(player);
}

class _PlayerEditPageState extends State<PlayerEditPage> {
  _PlayerEditPageState(this.player);

  Player player;
  String name;
  Color color;
  bool newPlayer;
  String appBarTitle;

  @override
  void initState() {
    newPlayer = player == null;
    if (newPlayer) player = Player(name: '');

    name = player.name;
    color = player.color;
    appBarTitle = newPlayer ? 'Create New Player' : 'Edit Player';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: Theme.of(context).textTheme.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              player.name = name == '' ? 'Anonymous' : name;
              player.color = color == null ? Colors.black : color;
              Navigator.pop(context, player);

              // Also save to db
            }
          )
        ],
      ),
    );
  }  
}