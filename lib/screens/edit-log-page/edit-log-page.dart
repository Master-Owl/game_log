import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:game_log/data/gameplay.dart';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/widgets/game-picker-widget.dart';
import './player-list.dart';

class EditLogPage extends StatefulWidget {
  EditLogPage({Key key, this.gameplay }) : super(key: key);

  final GamePlay gameplay;

  @override
  _EditLogState createState() => _EditLogState(gameplay);
}

class _EditLogState extends State<EditLogPage> {
  _EditLogState(this.gameplay);

  GamePlay gameplay;
  DateTime playDate;
  Duration playTime;
  bool isNewLog = false;
  Game game;

  @override
  void initState() {
    super.initState();

    isNewLog = gameplay == null;
    if (isNewLog) gameplay = new GamePlay(Game(), []);

    playDate = gameplay.playDate;
    playTime = gameplay.playTime;
    game = isNewLog ? null : gameplay.game;
  }

  @override
  Widget build(BuildContext context) {     
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewLog ? 'New Log' : 'Edit Log', style: Theme.of(context).textTheme.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black87),
            tooltip: 'Save',
            onPressed: saveLog
          )
        ]
      ),
      body: SingleChildScrollView(        
        child: Padding(
          padding: EdgeInsets.fromLTRB(lrPadding, 24.0, lrPadding, 16.0),
          child: Column(
            children: [
              GamePickerWidget(onItemSelected: (selectedGame) => setState(() { 
                game = selectedGame;
                gameplay.game = selectedGame;
              })),
              Padding(
                padding:  EdgeInsets.only(top: 24.0),
                child: PlayerList(
                  gameplay: gameplay,
                  onPlayerListChange: (changedGameplay) => setState((){
                    gameplay = changedGameplay;
                  })),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Date Played',
                      style: TextStyle(color:defaultGray, fontSize: 26.0, fontWeight: FontWeight.w300),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.only(left: 24.0),                  
                      constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 175.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.date_range, size: 30.0,color: Theme.of(context).accentColor),
                        title: Text(
                          formatDate(playDate.toLocal()),
                          style: TextStyle(color: defaultBlack, fontSize: 16.0, fontWeight: FontWeight.w400),
                        ),
                        onTap: openDatePicker,
                      )
                    )
                  ]
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Play Time',
                      style: TextStyle(color:defaultGray, fontSize: 26.0, fontWeight: FontWeight.w300),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.only(left: 24.0),                  
                      constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 175.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.timer, size: 30.0,color: Theme.of(context).accentColor),
                        title: Text(
                          formatTimeDuration(playTime),
                          style: TextStyle(color: defaultBlack, fontSize: 16.0, fontWeight: FontWeight.w400),
                        ),
                        onTap: openDurationPicker,
                      )
                    )
                  ]
                )
              ),
            ],
          )
        )
      )
    );
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
            accentColor: Theme.of(context).accentColor
          ),          
          child: child,
        );
      },
    );

    if (newDate != null)
      setState(() => { playDate = newDate });
  }

  void openDurationPicker() async {
    Duration newDuration = await showDurationPicker(
      context: context,
      initialTime: playTime,
      snapToMins: 1.0
    );

    if (newDuration != null) {
      setState(() {
        playTime = newDuration;
      });
    }
  }
  
  void saveLog() {
    gameplay.game = game;
    gameplay.playTime = playTime;
    gameplay.playDate = playDate;
    
    if (gameplay.dbRef == null) {      
      Firestore.instance.collection('gameplays').document()
        .setData(gameplay.serialize());
    } else {
      gameplay.dbRef.updateData(gameplay.serialize());
    }

    Navigator.pop(context, gameplay);
  }
}