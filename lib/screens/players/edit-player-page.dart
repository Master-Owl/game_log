import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/utils/helper-funcs.dart';
import 'package:game_log/data/user.dart';

class EditPlayerPage extends StatefulWidget {
  EditPlayerPage({Key key, this.player, this.isUser = false}) : super(key: key);

  final Player player;
  final bool isUser;

  _EditPlayerPageState createState() => _EditPlayerPageState(player, isUser);
}

class _EditPlayerPageState extends State<EditPlayerPage> {
  _EditPlayerPageState(this.player, this.isUser);

  Player player;
  String name = '';
  Color color;
  bool isUser;
  bool newPlayer;
  String appBarTitle;

  @override
  void initState() {
    newPlayer = player == null;
    if (isUser == null) isUser = false;
    
    if (newPlayer) {
      player = Player(name: 'Anonymous', color: Colors.black12); 
    }
    
    name = player.name == null ? '' : player.name;
    color = player.color == null ? defaultGray : player.color;
    
    appBarTitle = newPlayer ? 'Create New Player' : 'Edit Player';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle, style: Theme.of(context).textTheme.title),
          actions: [
            IconButton(
                icon: Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () async {
                  player.name = name == '' ? 'Anonymous' : name;
                  player.color = color;
                  // TODO: find a way to handle anonymous player entries in db
                  if (player.name != 'Anonymous' && !isUser) {
                    int pIdx = globalPlayerList.indexOf(player);
                    player = await updatePlayerDB(player);
                    globalPlayerList.removeAt(pIdx);
                    globalPlayerList.add(player);
                  } else if (isUser) {
                    await CurrentUser.ref.updateData({
                      'name': player.name,
                      'color': player.color.value
                    });

                    UserUpdateInfo uui = UserUpdateInfo();
                    uui.displayName = player.name;                    
                    CurrentUser.auth.updateProfile(uui);

                    globalPlayerList[0] = player;
                  }

                  Navigator.pop(context, player);
                })
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(lrPadding, 24.0, lrPadding, 16.0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  child: Text(
                    getPlayerInitials(),
                    style: TextStyle(fontSize: 75.0, color: determineTextColor(color)),
                  ),
                  backgroundColor: color,
                  maxRadius: 75.0,
                ),
                title: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: EdgeInsets.only(top: 45.0),
                    child: AppTextField(
                      label: 'Player Name',
                      controller: TextEditingController(text: name),
                      onChanged: (newName) => setState(() {
                            name = newName;
                          }),
                    )),
                  RaisedButton(
                    color: color,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(16.0))),
                    child: Text('Change Player Color',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: determineTextColor(color)
                        )
                      ),
                    onPressed: pickColor,
                  ),
                ])
              ),
            ],
          ),
        )
      );
  }

  String getPlayerInitials() {
    if (name == '') return '';
    List<String> names = name.split(' ');
    String initials = '';
    names.forEach((namePart) {
      if (namePart.length > 0)
        initials += namePart.substring(0,1).toUpperCase();
    });
    return initials;
  }

  Future<void> pickColor() async {
    Color oldColor = color;
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: color,
            onColorChanged: (newColor) => setState(() => { color = newColor }),
          ),
        ),
        actions: [
          FlatButton(
            padding: EdgeInsets.only(right: 16.0),
            child: Text('Cancel', style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 24.0
            )),
            textColor: Theme.of(context).errorColor,
            onPressed: () {
              setState(() => { color = oldColor });
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            padding:EdgeInsets.only(right: 26.0),
            child: Text('Done', style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 24.0
            )),
            textColor: Theme.of(context).accentColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<Player> updatePlayerDB(Player p) async {
    if (p.dbRef == null) {
      p.dbRef = await CurrentUser.ref.collection('players').add({ 'name': p.name, 'color': p.color.value });
    } else {
      await p.dbRef.updateData({ 'name': p.name, 'color': p.color.value });        
    }
    return p;
  }
}
