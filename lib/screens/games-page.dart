import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:game_log/data/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/widgets/slide-transition.dart';

class GamesPage extends StatefulWidget {
  GamesPage({Key key}) : super(key: key);

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage>
    with SingleTickerProviderStateMixin {
  _GamesPageState();

  AnimationController animController;
  SortGamesBy sortBy;
  List<DropdownMenuItem> sortTypes;
  List<Game> games;
  bool fetchDB;

  @override
  void initState() {
    sortBy = SortGamesBy.alphabetical_ascending;
    sortTypes = [];
    games = globalGameList;
    fetchDB = games.length == 0;
    for (SortGamesBy type in SortGamesBy.values) {
      sortTypes
          .add(DropdownMenuItem(child: Text(sortByString(type)), value: type));
    }

    animController = AnimationController(vsync: this, duration: animDuration);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    animController.forward();

    return SlideTransition(
        position: slideAnimation(animController, SlideDirection.Right),
        child: Scaffold(
          body: Container(
              padding: const EdgeInsets.only(top: headerPaddingTop),
              child: buildLogList(context),
            ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              Game newGame = await Navigator.pushNamed(
                  context, '/edit-game-page',
                  arguments: {'game': null});
              if (newGame != null) {
                setState(() {
                 games.add(newGame);
                });
              }
            },
          ),
        ));
  }

  // https://pub.dartlang.org/packages/cloud_firestore#-readme-tab-
  Widget buildLogList(BuildContext context) {
    if (fetchDB) {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('games').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return mainView(context, null, 'Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return mainView(context, null, '');
            default:
              return mainView(context, snapshot, '');
          }
        },
      );
    }
    return mainView(context, null, '');
  }

  Widget mainView(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, String err) {
    fetchDB = false;
    if (snapshot != null) {
      fetchGameData(snapshot);
    }
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(left: lrPadding, right: lrPadding * 2),
        child: Row(children: [
          Text('Game List', style: Theme.of(context).textTheme.headline),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text('Sort By', style: Theme.of(context).textTheme.subtitle),
              DropdownButton(
                value: sortBy,
                items: sortTypes,
                onChanged: (type) => setState(() => {sortBy = type}),
              )
            ]
          )
        ])
      ),
      games.length == 0
          ? Padding(
              padding: EdgeInsets.only(top: 125.0),
              child: SizedBox(
                height: 100.0,
                width: 100.0,
                child: CircularProgressIndicator(value: null)
              )
            )
          : err != ''
              ? Text(err, style: Theme.of(context).textTheme.title)
              : ListView(
                  shrinkWrap: true, 
                  itemExtent: 50.0, 
                  children: getLogList()
                )
      ]
    );
  }

  List<Widget> getLogList() {
    List<Widget> list = [];
    switch (sortBy) {
      case SortGamesBy.alphabetical_ascending:
        games.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortGamesBy.alphabetical_descending:
        games.sort((a, b) => b.name.compareTo(a.name));
        break;
      default:
        break;
    }
    for (Game game in games) {
      list.add(makeListTile(
        Text(game.name),
        () async {
          Game modifiedGame = await Navigator.pushNamed(
            context, '/edit-game-page',
            arguments: {'game': game}
          );

          if (modifiedGame != null && modifiedGame != game) {
            setState(() {
              int idx = games.indexOf(game);
              games.removeAt(idx);
              games.insert(idx, modifiedGame);

              idx =globalGameList.indexOf(game);
              globalGameList.removeAt(idx);
              globalGameList.insert(idx, modifiedGame);
              // fetchDB = true;
            });            
          }
      }));
    }
    return list;
  }

  Container makeListTile(Text title, Function onTap) {
    return Container(
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: .5, color: Colors.black12))),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: lrPadding),
          title: title,
          onTap: onTap,
        ));
  }

  void fetchGameData(AsyncSnapshot<QuerySnapshot> snapshot) async {
    games.clear();
    globalGameList.clear();

    // List<Future> 
    for (DocumentSnapshot gameRef in snapshot.data.documents) {      
      String name = gameRef.data['name'];
      GameType type =gameTypeFromString(gameRef.data['type']);
      WinConditions condition =winConditionFromString(gameRef.data['wincondition']);
      int bggId = gameRef.data['bggid'];
      DocumentReference dbRef = gameRef.reference;
            
      globalGameList.add(Game(
        name: name,
        bggId: bggId,
        condition: condition,
        type: type,
        dbRef: dbRef
      ));      
    }
    setState(() {
     games = globalGameList; 
    });
  }
}

enum SortGamesBy { alphabetical_ascending, alphabetical_descending,/* most_played, most_won */}
String sortByString(SortGamesBy sort) {
  switch (sort) {
    case SortGamesBy.alphabetical_ascending:
      return 'Alphabetically A-Z';
    case SortGamesBy.alphabetical_descending:
      return 'Alphabetically Z-A';
    // case SortGamesBy.most_played:
    //   return 'Most Played';
    // case SortGamesBy.most_won:
    //   return 'Most Won';
    default:
      return '';
  }
}
