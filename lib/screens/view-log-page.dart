import 'package:flutter/material.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/screens/edit-log-page.dart';

class ViewLogPage extends StatefulWidget {
  ViewLogPage({Key key, this.gameplay}) : super(key:key);
  final GamePlay gameplay;

  @override
  _ViewLogState createState() => _ViewLogState(gameplay);
}

class _ViewLogState extends State<ViewLogPage> with SingleTickerProviderStateMixin {
  _ViewLogState(this.gamePlay);

  GamePlay gamePlay;
  AnimationController animController;
  Animation<double> anim;

  @override
  void initState() {
    super.initState();    
    animController = AnimationController(vsync: this, duration: animDuration);
    anim = Tween(begin: 0.0, end: 1.0).animate(animController);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline =TextStyle(fontWeight: FontWeight.w300, fontSize: 42.0, color:defaultGray);
    TextStyle title = TextStyle(fontWeight: FontWeight.w300, fontSize: 28.0, color: defaultGray);
    TextStyle datetime = TextStyle(fontWeight: FontWeight.w500, fontSize: 22.0, color: defaultGray);
    String playersTitle = gamePlay.game.type == GameType.team ? 'Teams' : 'Players';

    animController.forward();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left:lrPadding, right:lrPadding, top:headerPaddingTop),
        child: FadeTransition(
          opacity: anim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(gamePlay.game.name, style: headline)
              ),
              Padding(
                padding:EdgeInsets.only(top: 36.0),
                child: RichText(
                  text: TextSpan(
                    text: 'Played On: ',
                    style: title,
                    children: [
                      TextSpan(
                        text: formatDate(gamePlay.playDate),
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
                        text: formatTimeDuration(gamePlay.playTime), 
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
              ListView(
                padding: EdgeInsets.only(left: 10.0, top: 6.0),
                itemExtent: 45.0,
                shrinkWrap: true,
                children: buildPlayerList(),                
              ),
              Padding(
                padding:EdgeInsets.only(top: 26.0),
                child: Center(
                  child: RaisedButton(
                    child: Text('Edit Log', style: Theme.of(context).textTheme.button),
                    padding:EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      GamePlay changed = await Navigator.push(context, 
                        MaterialPageRoute<GamePlay>(builder: (context) => EditLogPage(gamePlay: gamePlay)));
                      if (changed != null && changed != gamePlay) {
                        setState(() => { gamePlay = changed });
                      }
                    },
                  )
                )
              )
            ]
          )
        )
      ),
    );
  }

  List<Widget> buildPlayerList() {
    int playerOrTeamIdx = 0;
    List<Widget> tiles = [];
    List<Color> colors = [
      Colors.green,
      Colors.indigo,
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
    ];
    colors.shuffle();
    Map<String, Color> teamColors = {};

    for (Player player in gamePlay.players) {
      Color tileColor;
      Widget appendedWidget = Container();

      switch (gamePlay.game.type) {
        case GameType.standard:          
          tileColor = player.color;
          Widget badge = Icon(Icons.whatshot, color: Colors.yellow);          
          Widget pointText = RichText(
            text: TextSpan(
              text: gamePlay.scores[playerOrTeamIdx++].toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: ' Pts',
                  style:TextStyle(fontWeight: FontWeight.w400, color:defaultGray)
                )
              ]
            ),
          );

          if (gamePlay.winners.contains(player)) {
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
          for (String teamName in gamePlay.teams.keys) {            
            if (gamePlay.teams[teamName].contains(player)) {
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

          if (gamePlay.winners.contains(player)) {
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
}