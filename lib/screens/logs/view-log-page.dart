import 'package:flutter/material.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

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

    Widget wonIndicator = gameplay.game.condition == WinConditions.all_or_nothing ?
      Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Text('Won: ', style: title),
            Icon(
              gameplay.wonGame ? Icons.check : Icons.close, 
              color: gameplay.wonGame ? Theme.of(context).primaryColor : Theme.of(context).errorColor,
              size: 32.0,
            )
          ])) :
      Container(height: 0);

    Widget playersWidget = players.length > 0
        ? ListView(
            padding: EdgeInsets.only(left: 10.0, top: 6.0),
            itemExtent: 45.0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: gameplay.game.type == GameType.team ?
              buildTeamList() :
              buildPlayerList(),
          )
        : Center(child: CircularProgressIndicator(value: null));

    animController.forward();

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
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
                        Container(
                          width: screenWidth-(screenWidth/2.5),
                          child: AutoSizeText(gameplay.game.name, style: headline, maxLines: 2, textAlign: TextAlign.center),
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
                                    text: DateFormat.yMMMMd('en_US').format(gameplay.playDate),
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
                      wonIndicator,
                      Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Text('Players', style: title)),
                      Divider(
                        indent: 0,
                        height: 0.5,
                        color: defaultBlack,
                      ),
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
                                List<Player> changedPlayers = await changed.getPlayers();
                                setState(() {
                                  players = changedPlayers;
                                  gameplay = changed;
                                });
                              }
                            },
                          )))
                    ])))));
  }

  List<Widget> buildPlayerList() {
    List<Widget> tiles = [];

    for (Player player in players) {
      Color tileColor = player.color;
      Widget appendedWidget = Container();

      switch(gameplay.game.condition) {
        case WinConditions.score_highest:
        case WinConditions.score_lowest:
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
        case WinConditions.single_loser:
        case WinConditions.single_winner:
          if (gameplay.winners.contains(player.dbRef.documentID)) {
            appendedWidget = winnerIcon;
          }
          break;
        default: break;
      }

      tiles.add(InkWell(
        onTap: () => _goToPlayerPage(player),
        child: Row(
          children: [
            Container(
              color: tileColor,
              padding: EdgeInsets.all(2.0),
              margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
            ),
            Text(player.name),
            Spacer(),
            appendedWidget
      ])));
    }

    return tiles;
  }

  void _goToPlayerPage(Player p) async {
    Player changedPlayer = await Navigator.pushNamed<Player>(context, '/edit-player-page',
        arguments: {'player': p});
    if (changedPlayer != null && changedPlayer != p) {
      setState(() {
        players.remove(p);
        players.add(changedPlayer);
      });
    }
  }

  List<Widget> buildTeamList() {
    List<Widget> tiles = [];

    for (String teamName in gameplay.teams.keys) {
      List<DocumentReference> pRefs = gameplay.teams[teamName];
      bool teamWon = gameplay.winners.contains(teamName);
      tiles.add(Row(children: [
        Text(teamName, style: TextStyle(fontSize: 24.0)),
        Spacer(),
        teamWon ? winnerIcon : Container()
      ]));

      for (DocumentReference pRef in pRefs) {
        Player p = getPlayerFromRef(pRef);
        if (p != null) {
          tiles.add(Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: 
            InkWell(
              onTap: () => _goToPlayerPage(p),
              child: Row(children: [
                Container(
                  color: p.color,
                  padding: EdgeInsets.all(2.0),
                  margin: EdgeInsets.fromLTRB(0, 2.0, 8.0, 2.0),
                ),
                Text(p.name),
            ])))
          );
        }
      }
    }

    return tiles;
  }

  Player getPlayerFromRef(DocumentReference ref) {
    for (Player p in globalPlayerList) {
      if (p.dbRef == ref) return p;
    }
    return null;
  }
}
