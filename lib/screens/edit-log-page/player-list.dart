import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/utils/helper-funcs.dart';

class PlayerList extends StatefulWidget {
  PlayerList({ Key key, this.gameplay, this.onPlayerListChange }) : super(key: key);
  final GamePlay gameplay;
  final Function(GamePlay) onPlayerListChange;
  @override
  _PlayerListState createState() => _PlayerListState(gameplay, onPlayerListChange);
}

class _PlayerListState extends State<PlayerList> {
  _PlayerListState(this.gameplay, this.onPlayerListChange);

  GamePlay gameplay;
  List<Player> players;
  List<Player> allSavedPlayers;
  List<List<Player>> teams;
  List<Color> teamColors;
  GameType gameType;
  GameType prevGameType;
  Function(GamePlay) onPlayerListChange;

  @override
  void initState() {
    if (gameplay == null) gameplay = GamePlay(Game(), null);
    players = gameplay.players;
    allSavedPlayers = [];
    teams = [];
    teamColors = [];
    for (List<DocumentReference> teamList in gameplay.teams.values) {
      List<Player> team = [];
      for (DocumentReference pRef in teamList) {
        for (Player player in players) {
          if (player.dbRef == pRef) {
            team.add(player);
            break;
          }
        }
      }
      teams.add(team);
    }

    for (int i = 0; i < teams.length; ++i) {
      teamColors.add(getRandomColor());
    }

    Firestore.instance.collection('players')
      .getDocuments()
      .then((snapshot) {
        List<Player> dbPlayers = [];
        snapshot.documents.forEach((doc) {
          dbPlayers.add(Player(
            name: doc.data['name'],
            color: Color(doc.data['color']),
            dbRef: doc.reference
          ));
        });
        setState(() {
          allSavedPlayers = dbPlayers; 
        });
      });
      
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double listTileHeight = 50.0;
    double minHeight = 200.0;
    Color accent = Theme.of(context).accentColor;

    if (gameplay.game == null) {
      gameType = GameType.standard;
    } else {
      gameType = gameplay.game.type;

      switch (gameType) {
        case GameType.standard:
        case GameType.cooperative:          
          teams.clear();
          break;
        case GameType.team:
          if (prevGameType !=GameType.team) {
            players.clear();
          }
          break;
      }
    }
    prevGameType = gameType;

    // Layout the list
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                gameType == GameType.team ? 'Teams' : 'Players',
                style: TextStyle(
                  color: defaultGray,
                  fontSize: 24.0
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(gameType == GameType.team ? 
                  Icons.group_add : 
                  Icons.add, 
                  color: accent),                
                onPressed: onPlusPressed()
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
            child: ListView(
              shrinkWrap: true,
              itemExtent: listTileHeight,
              children: gameType == GameType.team ? 
                buildTeamTiles() : 
                buildListTiles(players)
            )
          )
        ]
      );
  }

  Function onPlusPressed() {
    if (gameType == GameType.team) return addTeam;   
    return allSavedPlayers.length > 0 ? () async {
      Player player = await addPerson();
      if (player != null) setState(() {
        players.add(player);
        gameplay.players = players;
        onPlayerListChange(gameplay);
      });
    } : null;
  }

  List<Widget> buildTeamTiles() {
    List<Widget> tiles = [];

    for (int i = 0; i < teams.length; ++i) {
      List<Player> team = teams[i];
      tiles.add(
        Row(
          children: [
            Text('Team ${i + 1}', style: Theme.of(context).textTheme.title),
            Spacer(),
            IconButton(
              icon: Icon(Icons.person_add),
              color: Theme.of(context).accentColor,
              tooltip: 'Add Player to Team',
              onPressed: () async {
                Player player = await addPerson();
                if (player != null) setState(() {
                  teams[i].add(player);
                  players.add(player);
                });
              }
            ),
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.red,
              tooltip: 'Delete Team',
              onPressed: () => setState(() {
                for (Player p in team) { players.remove(p); }
                teams.removeAt(i);
                gameplay.players = players;
                gameplay.teams = getTeams(teams);
                onPlayerListChange(gameplay);
              }),
            ),
          ],
        )
      );

      Color teamColor = teamColors[i];
      for (int j = 0; j < team.length; ++j) {
        Player player = team[j];
        tiles.add(
          Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Row(
              children: [
                Container(
                  color: teamColor,
                  padding: EdgeInsets.all(2.0),
                  margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
                ),
                Text(player.name),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.red,
                  onPressed: () => setState(() {
                    teams[i].removeAt(j);
                    players.remove(player);
                    gameplay.players = players;
                    gameplay.teams =getTeams(teams);
                    onPlayerListChange(gameplay);
                  }),
                ),
              ]
            )
          )
        );
      }
    }

    return tiles;
  }

  Map<String, List<DocumentReference>> getTeams(List<List<Player>> teams) {
    Map<String, List<DocumentReference>> gameplayTeams = {};
    for (int i = 0; i < teams.length; ++i) {
      String teamName = 'Team $i';
      List<DocumentReference> players = [];
      for (Player p in teams[i]) {
        players.add(p.dbRef);
      }
      gameplayTeams.putIfAbsent(teamName, () => players);
    }
    return gameplayTeams;
  }

  List<Widget> buildListTiles(List<Player> playerList) {
    List<Widget> tiles = [];
    Widget appendedWidget = Container();
    Color color = getRandomColor();


    for (Player player in playerList) {
      switch(gameType) {
        case GameType.standard:
          String score = '0';
          for (String pRef in gameplay.scores.keys) {
            if (pRef == player.dbRef.documentID) {
              score = gameplay.scores[pRef].toString();
              break;
            } 
          }
          appendedWidget = Container(
            width: 35.0,
            child: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                text: score,
                selection: TextSelection.collapsed(offset: score.length)
                )
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
              onTap: () => setState((){ score = ''; }),
              onChanged: (newVal) => setState(() {
                if (newVal == '') newVal = '0';
                gameplay.scores[player.dbRef.documentID] = int.tryParse(newVal);
              }),
            )
          );
          color = player.color;
          break;
        default: break;
      }

      tiles.add(
        InkWell(
          child: Row(
            children: [
              Container(
                color: color,
                padding:EdgeInsets.all(2.0),
                margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
              ),
              Text(player.name),
              Spacer(),
              appendedWidget,
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.red,
                onPressed: () => setState(() {
                  players.remove(player);
                  gameplay.players = players;
                  onPlayerListChange(gameplay);
                }),
              ),
            ]
          )
        )
      );
    }
    
    return tiles;
  }

  Future<Player> addPerson() async {
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
  
  void addTeam() {
    setState(() {
      teams.add([]);
      if (teams.length > teamColors.length) 
        teamColors.add(getRandomColor());
    });
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
            Navigator.pop(context, player);
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
          Player newPlayer = await Navigator.pushNamed(
            context, 
            '/edit-player-page',
            arguments: {
              'player': null
            }
          );          
          Navigator.pop(context, newPlayer); // remove popup
        }
      )
    );

    return options;
  }
}