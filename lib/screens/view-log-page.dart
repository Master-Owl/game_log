import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/screens/edit-log-page/edit-log-page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipedetector/swipedetector.dart';

class ViewLogPage extends StatefulWidget {
  ViewLogPage({Key key, this.gameplay}) : super(key:key);
  final GamePlay gameplay;

  @override
  _ViewLogState createState() => _ViewLogState(gameplay);
}

class _ViewLogState extends State<ViewLogPage> with SingleTickerProviderStateMixin {
  _ViewLogState(this.gameplay);

  GamePlay gameplay;
  List<Player> players;
  AnimationController animController;
  Animation<double> anim;

  @override
  void initState() {
    super.initState();
    players = [];
    animController = AnimationController(vsync: this, duration: animDuration);
    anim = Tween(begin: 0.0, end: 1.0).animate(animController);
    fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline =TextStyle(fontWeight: FontWeight.w300, fontSize: 42.0, color:defaultGray);
    TextStyle title = TextStyle(fontWeight: FontWeight.w300, fontSize: 28.0, color: defaultGray);
    TextStyle datetime = TextStyle(fontWeight: FontWeight.w500, fontSize: 22.0, color: defaultGray);
    String playersTitle = gameplay.game.type == GameType.team ? 'Teams' : 'Players';

    Widget playersWidget = players.length > 0 ? 
      ListView(
        padding: EdgeInsets.only(left: 10.0, top: 6.0),
        itemExtent: 45.0,
        shrinkWrap: true,
        children: buildPlayerList(),                
      ) :
      Center(child: CircularProgressIndicator(value: null)); 

    animController.forward();

    return Scaffold(
      body: SwipeDetector(
        child: Container(
          padding: EdgeInsets.only(left:lrPadding, right:lrPadding, top:headerPaddingTop),
          child: FadeTransition(
            opacity: anim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(gameplay.game.name, style: headline)
                ),
                Padding(
                  padding:EdgeInsets.only(top: 36.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Played On: ',
                      style: title,
                      children: [
                        TextSpan(
                          text: formatDate(gameplay.playDate),
                          style: datetime
                        )
                      ]
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Play Time: ',
                      style: title,
                      children: [
                        TextSpan(
                          text: formatTimeDuration(gameplay.playTime), 
                          style: datetime
                        ),
                      ],
                    ),
                  )
                ),
                Padding(
                  padding:EdgeInsets.only(top: 24.0),
                  child: Text(playersTitle, style: title)
                ),
                playersWidget,
                Padding(
                  padding:EdgeInsets.only(top: 26.0),
                  child: Center(
                    child: RaisedButton(
                      child: Text('Edit Log', style: Theme.of(context).textTheme.button),
                      padding:EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        GamePlay changed = await Navigator.push(
                          context, 
                          MaterialPageRoute<GamePlay>(builder: (context) => EditLogPage(gamePlay: gameplay), maintainState: false)
                        );
                        if (changed != null && changed != gameplay) {
                          print('changed');
                          setState(() => { gameplay = changed });
                        }
                        print('done');
                      },
                    )
                  )
                )
              ]
            )
          )
        ),
        onSwipeRight: () => { Navigator.pop(context, gameplay) },
      )
    );
  }

  List<Widget> buildPlayerList() {
    int playerOrTeamIdx = 0;
    List<Widget> tiles = [];
    List<Color> colors = [
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.blue,
      Colors.teal
    ];
    colors.shuffle();
    Map<String, Color> teamColors = {};

    for (Player player in players) {
      Color tileColor;
      Widget appendedWidget = Container();

      switch (gameplay.game.type) {
        case GameType.standard:          
          tileColor = player.color;
          Widget badge = Icon(Icons.whatshot, color: Colors.yellow);          
          Widget pointText = RichText(
            text: TextSpan(
              text: gameplay.scores[playerOrTeamIdx++].toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: ' Pts',
                  style:TextStyle(fontWeight: FontWeight.w400, color:defaultGray)
                )
              ]
            ),
          );

          if (gameplay.winners.contains(player)) {
            appendedWidget = ListTile(
              leading: badge,
              title: pointText,
            );
          } else {
            appendedWidget = pointText;
          }
          break;
        
        case GameType.cooperative:
          tileColor = Theme.of(context).accentColor;
          break;

        case GameType.team:
          String team = '';
          for (String teamName in gameplay.teams.keys) {            
            if (gameplay.teams[teamName].contains(player.dbRef)) {
              team = teamName;
              break;
            }
          }

          // debug
          assert(team != '');

          if (teamColors[team] != null) {
            tileColor = teamColors[team];
          }
          else {
            if (int.tryParse(team) != null) {
              tileColor = colors[int.parse(team)];
            } else {
              tileColor = colors[playerOrTeamIdx++];              
            }
            teamColors.putIfAbsent(team, () => tileColor);
          }

          if (gameplay.winners.contains(player)) {
            appendedWidget = Icon(Icons.whatshot, color: Colors.yellow);
          }
          break;
      }

      tiles.add(Row(
          children: [
            Container(
              color: tileColor,
              padding:EdgeInsets.all(2.0),
              margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
            ),
            Text(player.name),
            Spacer(),
            appendedWidget
          ]
        )
      );
    }
    
    return tiles;
  }

  void fetchPlayers() async {
    List<DocumentReference> pRefs = gameplay.playerRefs;
    List<Future> futures = [];
    List<Player> fetchedPlayers = [];

    pRefs.forEach((ref) {
      futures.add(
        ref.get().then((snapshot) => {
          fetchedPlayers.add(
            Player(
              dbRef: ref, 
              name: snapshot.data['name'], 
              color: Color(snapshot.data['color'])
            )
          )
        })
      );
    });

    await Future.wait(futures);

    setState(() {
      players = fetchedPlayers;
      gameplay.players = players;
    });
  }
}