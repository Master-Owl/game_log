import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/widgets/game-picker-widget.dart';
import 'package:game_log/data/user.dart';
import 'package:game_log/screens/logs/edit-log-page/player-list.dart';

class EditLogPage extends StatefulWidget {
  EditLogPage({Key key, this.gameplay}) : super(key: key);

  final GamePlay gameplay;

  @override
  _EditLogState createState() => _EditLogState(gameplay);
}

class _EditLogState extends State<EditLogPage> {
  _EditLogState(this.gameplay);

  GamePlay gameplay;
  GamePlay modifiedGameplay;
  DateTime playDate;
  Duration playTime;
  bool isNewLog = false;
  Game game;
  Widget appendedWidget;
  TextStyle textStyle = TextStyle(
    color: defaultGray,
    fontSize: 26.0,
    fontWeight: FontWeight.w300);

  @override
  void initState() {
    super.initState();

    isNewLog = gameplay == null;
    if (isNewLog) gameplay = new GamePlay(Game(), []);
    modifiedGameplay = GamePlay.clone(gameplay);

    playDate = gameplay.playDate;
    playTime = gameplay.playTime;
    game = isNewLog ? null : gameplay.game;
  }

  @override
  Widget build(BuildContext context) {
    switch (modifiedGameplay.game.condition) {
      case WinConditions.all_or_nothing:
        appendedWidget = Padding(
          padding: EdgeInsets.only(top: 24.0),
          child: Row(
            children: [
              Text('Won', style: textStyle),
              Spacer(),
              Checkbox(
                value: modifiedGameplay.wonGame,
                onChanged: (won) {
                  modifiedGameplay.wonGame = won;
                  if (won) {
                    setState(() {                      
                      modifiedGameplay.winners.clear();
                      for (DocumentReference pRef in modifiedGameplay.playerRefs) {
                        modifiedGameplay.winners.add(pRef.documentID);
                      }
                    });
                  } else {
                    setState(() {
                      modifiedGameplay.winners.clear(); 
                    });
                  }
                },
              )
            ],
          ),
        );
        break;
      default:
        appendedWidget = Container();
        break;
    }

    List<Widget> actions = [];
    if (!isNewLog) {
      actions.add(IconButton(
        icon: Icon(Icons.delete, color: defaultBlack),
        tooltip: 'Delete',
        onPressed: deleteLogDialog,
      ));
    }
    actions.add(IconButton(
        icon: Icon(Icons.save, color: defaultBlack),
        tooltip: 'Save',
        disabledColor: defaultGray,
        onPressed:  modifiedGameplay.game.dbRef != null &&
                    modifiedGameplay.playerRefs.length >= 1 ? 
                  saveLog : 
                  null
          )
        );

    return Scaffold(
        appBar: AppBar(            
            title: Text(isNewLog ? 'New Log' : 'Edit Log',
                style: Theme.of(context).textTheme.title),
            actions: actions),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.fromLTRB(lrPadding, 24.0, lrPadding, 16.0),
                child: Column(
                  children: [
                    GamePickerWidget(
                      selectedGame: game,
                      onItemSelected: (selectedGame) => setState(() {
                            game = selectedGame;
                            modifiedGameplay.game = selectedGame;
                          })),
                    Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: PlayerList(
                          gameplay: modifiedGameplay,
                          onPlayerListChange: (changedGameplay) => {
                            modifiedGameplay = changedGameplay
                          })
                    ),
                    appendedWidget,
                    Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Date Played', style: textStyle),
                              Spacer(),
                              Container(
                                  margin: EdgeInsets.only(left: 24.0),
                                  constraints: BoxConstraints(
                                      maxHeight: 50.0, maxWidth: 180.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(Icons.date_range,
                                        size: 30.0,
                                        color: Theme.of(context).accentColor),
                                    title: Text(
                                      formatDate(playDate.toLocal()),
                                      style: TextStyle(
                                          color: defaultBlack,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    onTap: openDatePicker,
                                  ))
                            ])),
                    Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Play Time', style: textStyle),
                              Spacer(),
                              Container(
                                  margin: EdgeInsets.only(left: 24.0),
                                  constraints: BoxConstraints(
                                      maxHeight: 50.0, maxWidth: 180.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(Icons.timer,
                                        size: 30.0,
                                        color: Theme.of(context).accentColor),
                                    title: Text(
                                      formatTimeDuration(playTime),
                                      style: TextStyle(
                                          color: defaultBlack,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    onTap: openDurationPicker,
                                  ))
                            ])),
                  ],
                ))));
  }

  void openDatePicker() async {
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: playDate,
      firstDate: DateTime(1956),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Theme.of(context).accentColor,
              accentColor: Theme.of(context).accentColor),
          child: child,
        );
      },
    );

    if (newDate != null) setState(() => {playDate = newDate});
  }

  bool fieldsValidated(){   
    return modifiedGameplay.game != null &&
      modifiedGameplay.playerRefs.length >= 1;  
  }

  void openDurationPicker() async {
    Duration newDuration = await showDurationPicker(
        context: context, initialTime: playTime, snapToMins: 1.0);

    if (newDuration != null) setState(() => {playTime = newDuration});    
  }

  void saveLog() {
    if (!isNewLog){
      globalGameplayList.remove(gameplay);
      globalGameplayList.remove(modifiedGameplay);
    }

    gameplay = modifiedGameplay;
    gameplay.game = game;
    gameplay.playTime = playTime;
    gameplay.playDate = playDate;

    if (gameplay.dbRef == null) {
      CurrentUser.ref
          .collection('gameplays')
          .document()
          .setData(gameplay.serialize());
    } else {
      gameplay.dbRef.updateData(gameplay.serialize());
    }

    globalGameplayList.add(gameplay);
    Navigator.pop(context, gameplay);
  }

  void deleteLogDialog() async {
    bool deleteLog =
        await showConfirmDialog(context, 'Delete this log?', 'Yes', 'No');

    if (deleteLog != null && deleteLog) {
      await gameplay.dbRef.delete();
      setState(() {
        globalGameplayList.remove(gameplay);
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/')
          .then((x) => { tabIdxController.sink.add(tabs['logs']) });        
      });
    }
  }
}
