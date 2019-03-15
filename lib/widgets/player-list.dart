import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/screens/player-edit-page.dart';
import 'package:game_log/data/game.dart';

class PlayerList extends StatefulWidget {
  PlayerList({ Key key, this.gameplay }) : super(key: key);
  final GamePlay gameplay;

  @override
  _PlayerListState createState() => _PlayerListState(gameplay);
}

class _PlayerListState extends State<PlayerList> {
  _PlayerListState(this.gameplay);

  GamePlay gameplay;
  List<Player> players;
  List<Player> allSavedPlayers;
  bool fetchDB = true;

  @override
  void initState() {
    if (gameplay == null) gameplay = GamePlay(Game(), []);

    players = List<Player>.from(gameplay.players); // create copy of players until saved
    allSavedPlayers = new List<Player>();
    super.initState();
  }

  // https://pub.dartlang.org/packages/cloud_firestore#-readme-tab-
  @override
  Widget build(BuildContext context) {
    if (fetchDB) {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('players').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return mainView(context, false, null, 'Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return mainView(context, true, null, '');
            default: return mainView(context, false, snapshot, '');
          }
        },
      );
    }
    return mainView(context, false, null, '');
  }

  Widget mainView(BuildContext context, bool waiting, AsyncSnapshot<QuerySnapshot> snapshot, String err) {
    fetchDB = false;
    double listTileHeight = 50.0;
    double minHeight = 200.0;
    Color accent = Theme.of(context).accentColor;

    // Set all players
    if (snapshot != null) {
      allSavedPlayers.clear();
      snapshot.data.documents.forEach((doc) {
        Player p = Player(
          name: doc.data['name'],
          color: Color(doc.data['color']),
          dbRef: doc.reference
        );
        allSavedPlayers.add(p);
      });
    }

    // Build player list
    Widget content = players.length > 0 && !waiting ? 
      ListView(
        shrinkWrap: true,
        itemExtent: listTileHeight,
        children: buildListTiles()
      ) :
      Center(
        child: Text(
          err == '' ? 
            waiting ? 
              'Loading...' : 
              'No Players Added Yet' :
            err,
          style: TextStyle(
            color: defaultGray,
            fontSize: 20.0,
            letterSpacing: 0.5
          )
        )
      );

    // Layout the list
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Players',
                style: TextStyle(
                  color: defaultGray,
                  fontSize: 24.0
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.add, color: accent),
                tooltip: 'Add Player',
                onPressed: waiting && err != null ? null : addPerson, // add player
              )
            ]
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: defaultGray),
                bottom: BorderSide(color: defaultGray),
              ),
            ),
            height: minHeight,
            child: content
          )
        ]
      );
  }

  List<Widget> buildListTiles() {
    List<Widget> tiles = [];

    for (Player player in players) {
      tiles.add(
        InkWell(
          child: Row(
            children: [
              Container(
                color: player.color,
                padding:EdgeInsets.all(2.0),
                margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
              ),
              Text(player.name),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.red,
                onPressed: () => setState(() {
                  players.remove(player);
                }),
              ),
            ]
          ),
          onTap: () async {           
            Player changedPlayer = await Navigator.push(
              context, 
              MaterialPageRoute<Player>(
                builder: (context) => PlayerEditPage(player: player)
              )
            );
            
            if (changedPlayer != null && changedPlayer != player) {
              setState(() {
                players[players.indexOf(player)] = changedPlayer;
                fetchDB = true;
              });
            }
          }   
        )
      );
    }
    
    return tiles;
  }

  Future<void> addPerson() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Player'),
          children: buildDialogPlayerOptions(),          
        );
      }
    );
  }

  List<Widget> buildDialogPlayerOptions() {
    List<Widget> options = [];

    for (Player player in allSavedPlayers) {
      if (players.contains(player)) continue;
      options.add(
        SimpleDialogOption(
          child: Row(
            children: [
              Icon(Icons.person, color: player.color),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(player.name),
              )
            ]
          ),
          onPressed: () {
            setState(() {
              players.add(player);
            });
            Navigator.pop(context);
          }
        )
      );
    }
    
    options.add(
      SimpleDialogOption(
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Theme.of(context).accentColor),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('Create New Player'),
            )
          ]
        ),
        onPressed: () async {
          Navigator.pop(context); // remove popup

          // wait for new player created
          Player newPlayer = await Navigator.push(
            context, 
            MaterialPageRoute<Player>(
              builder: (context) => PlayerEditPage()
            )
          );
          
          if (newPlayer != null) setState(() {
            players.add(newPlayer);
            fetchDB = true;
          });          
        }
      )
    );

    return options;
  }
}