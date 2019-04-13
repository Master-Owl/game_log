import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/user.dart';

class PlayersPage extends StatefulWidget {
  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {

  List<Player> players;

  @override
  void initState() {
    super.initState();
    players = globalPlayerList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Players', style: Theme.of(context).textTheme.title),
      ),
      body: Container(
        padding: EdgeInsets.only(top:lrPadding),
        child: ListView(
          itemExtent: 50.0,
          shrinkWrap: true,
          children: buildPlayerList()
        )
      ),
    );
  }

  List<Widget> buildPlayerList() {
    List<Widget> tiles = [];

    for (Player p in players) {
      if (p.dbRef == CurrentUser.ref) continue;
      tiles.add(ListTile(
        contentPadding: EdgeInsets.only(left:lrPadding*1.5),
        leading: Icon(Icons.person, color: p.color),
        title: Text(p.name),
        onTap: () async {
          await Navigator.pushNamed(context, '/edit-player-page', arguments: {'player':p});
          setState(() {
            players = globalPlayerList;
          });
        }
      ));
    }
    return tiles;
  }
}

