import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:game_log/data/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/widgets/slide-transition.dart';

class LogsPage extends StatefulWidget {
  LogsPage({Key key}) : super(key: key);

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage>
    with SingleTickerProviderStateMixin {
  _LogsPageState();

  AnimationController animController;
  SortBy sortBy;
  List<DropdownMenuItem> sortTypes;
  List<GamePlay> gameplays;

  @override
  void initState() {
    sortBy = SortBy.alphabetical;
    sortTypes = [];
    gameplays = globalGameplayList;
    for (SortBy type in SortBy.values) {
      sortTypes
          .add(DropdownMenuItem(child: Text(sortByString(type)), value: type));
    }

    animController = AnimationController(vsync: this, duration: animDuration);

    if (gameplays.length == 0)
      Firestore.instance
          .collection('gameplays')
          .getDocuments()
          .then(fetchGameplayData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    animController.forward();
    sortGameplays();

    return SlideTransition(
        position: slideAnimation(animController, SlideDirection.Left),
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.only(top: headerPaddingTop),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: lrPadding, right: lrPadding * 2),
                  child: Row(
                    children: [
                      Text('Log List',
                          style: Theme.of(context).textTheme.headline),
                      Spacer(),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sort By',
                                style: Theme.of(context).textTheme.subtitle),
                            DropdownButton(
                              value: sortBy,
                              items: sortTypes,
                              onChanged: (type) =>
                                  setState(() => {sortBy = type}),
                            )
                          ]
                      )
                  ])
                ),
                gameplays.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 125.0),
                      child: SizedBox(
                          height: 100.0,
                          width: 100.0,
                          child: CircularProgressIndicator(value: null))
                    )
                  : Expanded(
                      child: ListView(
                          children: getLogList(),
                          shrinkWrap: true,
                          itemExtent: 70.0)
                    )
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              GamePlay newPlay = await Navigator.pushNamed(
                  context, '/edit-log-page',
                  arguments: {'gameplay': null});
              if (newPlay != null) {
                setState(() => {gameplays.add(newPlay)});
              }
            },
          ),
        ));
  }

  void sortGameplays() {
    gameplays =globalGameplayList;
    switch (sortBy) {
      case SortBy.alphabetical:
        gameplays.sort((a, b) => a.game.name.compareTo(b.game.name));
        break;
      case SortBy.most_recent:
        gameplays.sort((a, b) => a.playDate.compareTo(b.playDate));
        break;
      case SortBy.play_time_shortest:
        gameplays.sort((a, b) => a.playTime.compareTo(b.playTime));
        break;
      case SortBy.play_time_longest:
        gameplays.sort((a, b) => b.playTime.compareTo(a.playTime));
        break;
      default:
        break;
    }
  }

  List<Widget> getLogList() {
    List<Widget> list = [];
    for (GamePlay play in gameplays) {
      list.add(makeListTile(
          Text(play.game.name), Text(formatDate(play.playDate)), 
          () async {
            GamePlay changedPlay = await Navigator.pushNamed(
                context, '/view-log-page',
                arguments: {'gameplay': play});

            if (changedPlay != null && changedPlay != play) {
              setState(() {
                int idx = gameplays.indexOf(play);
                gameplays.removeAt(idx);
                gameplays.insert(idx, changedPlay);
              });
            }
          },
        () async {
          bool deleteLog = await showConfirmDialog(
            context, 'Delete this log?', 'Yes', 'No');

          if (deleteLog != null && deleteLog) {
            await play.dbRef.delete();
            setState(() {
              gameplays.remove(play); 
            });
          }
        }
      ));
    }
    return list;
  }

  Container makeListTile(title, subtitle, onTap, onLongPress) {
    return Container(
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: .5, color: Colors.black12))),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: lrPadding),
          title: title,
          subtitle: subtitle,
          onTap: onTap,
          onLongPress: onLongPress,
        ));
  }

  void fetchGameplayData(QuerySnapshot snapshot) async {
    gameplays.clear();
    globalGameplayList.clear();

    for (DocumentSnapshot doc in snapshot.documents) {
      DocumentReference gameRef = doc.data['game'];
      List playerRefs = doc.data['players'];
      playerRefs = List<DocumentReference>.from(playerRefs);

      Game game = await gameRef.get().then((snapshot) {
        return Game(
            name: snapshot.data['name'],
            type: gameTypeFromString(snapshot.data['type']),
            condition: winConditionFromString(snapshot.data['wincondition']),
            bggId: snapshot.data['bggid'],
            dbRef: snapshot.reference);
      });

      // Optional data
      List<String> winners;
      Map<String, List<DocumentReference>> teams;
      Map<String, int> scores;

      if (doc.data['winners'] != null) {
        winners = [];
        for (String winner in doc.data['winners']) {
          winners.add(winner);
        }
      }

      if (doc.data['teams'] != null) {
        teams = {};
        for (String teamName in doc.data['teams'].keys) {
          List pRefs = doc.data['teams'][teamName];
          List<DocumentReference> team = [];
          for (DocumentReference pRef in pRefs) {
            for (DocumentReference p in playerRefs) {
              if (p == pRef) {
                team.add(p);
                break;
              }
            }
          }
          teams.putIfAbsent(teamName, () => team);
        }
      }

      if (doc.data['scores'] != null) {
        scores = {};
        for (String pRefId in doc.data['scores'].keys) {
          for (DocumentReference p in playerRefs) {
            if (p.documentID == pRefId) {
              scores.putIfAbsent(
                  p.documentID, () => doc.data['scores'][pRefId]);
              break;
            }
          }
        }
      }

      globalGameplayList.add(GamePlay(game, playerRefs,
          playTime: Duration(minutes: doc.data['playtime']),
          playDate: doc.data['playdate'],
          teams: teams,
          scores: scores,
          winners: winners,
          dbRef: doc.reference));
    }

    setState(() {
      gameplays = globalGameplayList;
    });
  }
}

enum SortBy { alphabetical, most_recent, play_time_shortest, play_time_longest }
String sortByString(SortBy sort) {
  switch (sort) {
    case SortBy.most_recent:
      return 'Most Recent';
    case SortBy.play_time_shortest:
      return 'Play Time - Shortest';
    case SortBy.play_time_longest:
      return 'Play Time - Longest';
    case SortBy.alphabetical:
      return 'Alphabetically';
    default:
      return '';
  }
}
