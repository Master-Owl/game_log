import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/game.dart';

class ViewLogPage extends StatefulWidget {
  ViewLogPage({Key key, this.gameplay}) : super(key: key);
  final GamePlay gameplay;

  @override
  _ViewLogState createState() => _ViewLogState(gameplay);
}

class _ViewLogState extends State<ViewLogPage>
    with SingleTickerProviderStateMixin {
  _ViewLogState(this.gameplay);

  GamePlay gameplay;
  List<Player> players;
  AnimationController animController;
  Animation<double> anim;
  Icon winnerIcon = Icon(starsIcon, size: 38.0, color: Colors.yellow);

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this, duration: animDuration);
    anim = Tween(begin: 0.0, end: 1.0).animate(animController);

    players = [];
    gameplay.getPlayers().then((playerList) => setState((){ players = playerList; }));
  }

  @override
  Widget build(BuildContext context) {    
    TextStyle headline = TextStyle(
        fontWeight: FontWeight.w300, fontSize: 42.0, color: defaultGray);
    TextStyle title = TextStyle(
        fontWeight: FontWeight.w300, fontSize: 28.0, color: defaultGray);
    TextStyle datetime = TextStyle(
        fontWeight: FontWeight.w500, fontSize: 22.0, color: defaultGray);
    String playersTitle =
        gameplay.game.type == GameType.team ? 'Teams' : 'Players';

    Widget playersWidget = players.length > 0
        ? ListView(
            padding: EdgeInsets.only(left: 10.0, top: 6.0),
            itemExtent: 45.0,
            shrinkWrap: true,
            children: buildPlayerList(),
          )
        : Center(child: CircularProgressIndicator(value: null));

    animController.forward();

    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(
                left: lrPadding, right: lrPadding, top: headerPaddingTop),
            child: FadeTransition(
                opacity: anim,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: headline.color,
                                ),
                                iconSize: headline.fontSize - 10.0,
                                onPressed: () =>
                                    {Navigator.pop(context, gameplay)},
                              ),
                            ),
                            flex: 2),
                        Spacer(flex: 1),
                        Center(
                          child: Text(gameplay.game.name, style: headline),
                        ),
                        Spacer(flex: 3)
                      ]),
                      Padding(
                          padding: EdgeInsets.only(top: 36.0),
                          child: RichText(
                              text: TextSpan(
                                  text: 'Played On: ',
                                  style: title,
                                  children: [
                                TextSpan(
                                    text: formatDate(gameplay.playDate),
                                    style: datetime)
                              ]))),
                      Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Play Time: ',
                              style: title,
                              children: [
                                TextSpan(
                                    text: formatTimeDuration(gameplay.playTime),
                                    style: datetime),
                              ],
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 24.0),
                          child: Text(playersTitle, style: title)),
                      playersWidget,
                      Padding(
                          padding: EdgeInsets.only(top: 26.0),
                          child: Center(
                              child: RaisedButton(
                            child: Text('Edit Log',
                                style: Theme.of(context).textTheme.button),
                            padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              GamePlay changed = await Navigator.pushNamed(
                                  context, '/edit-log-page',
                                  arguments: {'gameplay': gameplay});
                              if (changed != null && changed != gameplay) {
                                setState(() async {
                                  players = await changed.getPlayers();
                                  gameplay = changed;
                                });
                              }
                            },
                          )))
                    ]))));
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
          Widget pointText = RichText(
            text: TextSpan(
                text: gameplay.scores[player.dbRef.documentID].toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color:defaultGray, fontSize: 16.0),
                children: [
                  TextSpan(
                      text: ' Pts',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: defaultGray))
                ]),
          );

          if (gameplay.winners.contains(player.dbRef.documentID)) {
            appendedWidget = Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [winnerIcon,pointText]
              ),
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
          } else {
            if (int.tryParse(team) != null) {
              tileColor = colors[int.parse(team)];
            } else {
              tileColor = colors[playerOrTeamIdx++];
            }
            teamColors.putIfAbsent(team, () => tileColor);
          }

          if (gameplay.winners.contains(team)) {
            appendedWidget = winnerIcon;
          }
          break;
      }

      tiles.add(Row(children: [
        Container(
          color: tileColor,
          padding: EdgeInsets.all(2.0),
          margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
        ),
        Text(player.name),
        Spacer(),
        appendedWidget
      ]));
    }

    return tiles;
  }
}
