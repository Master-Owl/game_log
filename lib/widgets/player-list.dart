import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';

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

  @override
  void initState() {
    if (gameplay == null) gameplay = GamePlay();

    players = gameplay.players;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double listTileHeight = 50.0;
    double minHeight = 200.0;
    Color primary = Theme.of(context).primaryColor;
    Color accent = Theme.of(context).accentColor;

    Widget content = players.length > 0 ? 
      ListView(
        shrinkWrap: true,
        itemExtent: listTileHeight,
        children: buildListTiles()
      ) :
      Center(
        child: Text(
          'No Players Added Yet',
          style: TextStyle(
            color: defaultGray,
            fontSize: 20.0,
            letterSpacing: 0.5
          )
        )
      );

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
              onPressed: () => {}, // add player
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
          onTap: () => {}, // go to player page
        )
      );
    }
    
    return tiles;
  }


  // https://pub.dartlang.org/packages/cloud_firestore#-readme-tab-
  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: Firestore.instance.collection('players').snapshots(),
  //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasError)
  //         return new Text('Error: ${snapshot.error}');
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.waiting: return new Text('Loading...');
  //         default:
  //           return new ListView(
  //             children: snapshot.data.documents.map((DocumentSnapshot document) {
  //               return new ListTile(
  //                 title: new Text(document['title']),
  //                 subtitle: new Text(document['author']),
  //               );
  //             }).toList(),
  //           );
  //       }
  //     },
  //   );
  // }
}