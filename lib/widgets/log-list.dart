import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/screens/view-log-page.dart';

class LogList extends StatefulWidget {

  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogList> {

  SortBy sortBy;
  List<DropdownMenuItem> sortTypes;
  List<GamePlay> gameplays;
  bool fetchDB;

  @override
  void initState() {
    sortBy = SortBy.alphabetical;
    sortTypes = [];
    gameplays = [];
    fetchDB = true;
    for (SortBy type in SortBy.values) {
      sortTypes.add(
        DropdownMenuItem(
          child: Text(sortByString(type)),
          value: type
        )
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (fetchDB) {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('gameplays').snapshots(),
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

  Widget mainView(BuildContext context, bool isWaiting, AsyncSnapshot<QuerySnapshot> snapshot, String err) {
    fetchDB = false;
    if (snapshot != null) {
      fetchGameplayData(snapshot);
    }
    return Column(
      children: [
        Padding (
          padding: EdgeInsets.only(left: lrPadding, right: lrPadding*2),
          child: Row(
            children: [
              Text('Log List', style: Theme.of(context).textTheme.headline),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sort By', style: Theme.of(context).textTheme.subtitle),
                  DropdownButton(
                    value: sortBy,
                    items: sortTypes,
                    onChanged: (type) => setState(() => { sortBy = type }),
                  )
                ]
              )
            ]
          )
        ),
        isWaiting ? 
          Padding(
            padding: EdgeInsets.only(top: 125.0),
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: CircularProgressIndicator(value: null) 
            )
          ) :
        err != '' ?
          Text(err, style: Theme.of(context).textTheme.title) :
          ListView(
            shrinkWrap: true,
            itemExtent: 70.0,
            children: getLogList()
          )
      ]
    );
  }

  List<Widget> getLogList() {
    List<Widget> list = [];
    switch(sortBy) {
      case SortBy.alphabetical:
        gameplays.sort((a,b) => a.game.name.compareTo(b.game.name));
        break;
      case SortBy.most_recent:
        gameplays.sort((a,b) => a.playDate.compareTo(b.playDate));
        break;
      case SortBy.play_time:
        gameplays.sort((a,b) => a.playTime.compareTo(b.playTime));
        break;
      // case SortBy.most_played:
        // break;
      default:
        break;
    }
    for (GamePlay play in gameplays) {
      list.add(
        makeListTile(
          Text(play.game.name),
          Text(formatDate(play.playDate)),
          () async {
            GamePlay changedPlay = await Navigator.push(
              context, 
              MaterialPageRoute<GamePlay>(
                builder: (context) => ViewLogPage(gameplay: play),
                maintainState: true                
              )
            );

            if (changedPlay != null && changedPlay != play) {
              setState(() {
                int idx = gameplays.indexOf(play);
                gameplays.removeAt(idx);
                gameplays.insert(idx, changedPlay);
              });
              // also update the db
            }
          }
        )
      );
    }
    return list;
  }

  Container makeListTile(title, subtitle, onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: .5, color: Colors.black12))
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: lrPadding),
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      )
    );
  }


  void fetchGameplayData(AsyncSnapshot<QuerySnapshot> snapshot) {
    gameplays.clear();
    snapshot.data.documents.forEach((doc) async {
      List<Future> futures = [];
      DocumentReference gameRef = doc.data['game'];
      List playerRefs = doc.data['players'];

      futures.add(
        gameRef.get().then((snapshot) {
          return Game(
            name: snapshot.data['name'],
            type: gameTypeFromString(snapshot.data['type']),
            condition: winConditionFromString(snapshot.data['wincondition']),
            bggId: snapshot.data['bggid']
          );
        })
      );

      for (DocumentReference ref in playerRefs) {
        futures.add(
          ref.get().then((snapshot) {         
            return snapshot.data != null ? Player(
              name: snapshot.data['name'],
              color: Color(snapshot.data['color']),
              dbId: snapshot.documentID
            ) : Player();
          })
        );
      }
      
      List responses = await Future.wait(futures);

      List<Player> players = [];
      for (int i = 1; i < responses.length; ++i) {
        players.add(responses[i]);
      }

      // Optional data
      List<Player> winners = [];
      Map<String, List<Player>> teams = {};
      Map<Player, int> scores = {};
      if (doc.data['winners'] != null) {
        for (DocumentReference pRef in doc.data['winners']) {          
          for (Player p in players) {
            if (p.dbId == pRef.documentID) {
              winners.add(p);
              break;
            }
          }
        }
      }
      if (doc.data['teams'] != null) {
        for (String teamName in doc.data['teams'].keys) {          
          List pRefs = doc.data['teams'][teamName];
          List<Player> team = [];          
          for (DocumentReference pRef in pRefs) {
            for (Player p in players) {
              if (p.dbId == pRef.documentID) {
                team.add(p);
                break;
              }
            }
          }
          teams.putIfAbsent(teamName, () => team);
        }
      }
      if (doc.data['scores'] != null) {
        for (String pRefId in doc.data['scores'].keys) {          
          for (Player p in players) {
            if (p.dbId == pRefId) {
              scores.putIfAbsent(p, () => doc.data['scores'][pRefId]);
              break;
            }
          }
        }        
      }

      setState(() {
        gameplays.add(GamePlay(
          responses[0],
          players,
          playTime: Duration(minutes: doc.data['playtime']),
          playDate: doc.data['playdate'],
          teams: teams,
          scores: scores,
          winners: winners
        ));
      });
    });
  }
}

enum SortBy { alphabetical, most_recent, /*most_played,*/ play_time }
String sortByString(SortBy sort) {
  switch (sort) {
    case SortBy.most_recent: return 'Most Recent';
    // case SortBy.most_played: return 'Most Played';
    case SortBy.play_time: return 'Play Time';
    case SortBy.alphabetical: return 'Alphabetically';            
    default: return '';
  }
}