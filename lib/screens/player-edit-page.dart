import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_log/data/player.dart';
import 'package:game_log/data/globals.dart';
import 'package:game_log/widgets/app-text-field.dart';
import 'package:flutter_colorpicker/block_picker.dart';

class PlayerEditPage extends StatefulWidget {
  PlayerEditPage({Key key, this.player}) : super(key: key);

  final Player player;

  _PlayerEditPageState createState() => _PlayerEditPageState(player);
}

class _PlayerEditPageState extends State<PlayerEditPage> {
  _PlayerEditPageState(this.player);

  Player player;
  String name;
  Color color;
  bool newPlayer;
  String appBarTitle;

  @override
  void initState() {
    newPlayer = player == null;
    if (newPlayer) player = Player(name: 'Anonymous', color: Colors.black12);

    name = player.name;
    color = player.color;
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
                onPressed: () {
                  player.name = name == '' ? 'Anonymous' : name;
                  player.color = color == null ? Colors.black : color;
                  Navigator.pop(context, player);

                  // Also save to db
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
                    name.substring(0, 1),
                    style: TextStyle(fontSize: 75.0, color: defaultGray),
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
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    onPressed: pickColor,
                  ),
                ])
              ),
            ],
          ),
        )
      );
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
            child: Text('Cancel'),
            textColor: Theme.of(context).errorColor,
            onPressed: () {
              setState(() => { color = oldColor });
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Done'),
            textColor: Theme.of(context).accentColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
