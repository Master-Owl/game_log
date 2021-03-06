import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

class SettingsPage extends StatelessWidget{
  SettingsPage({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    EdgeInsets tilePadding = EdgeInsets.only(left: lrPadding*1.5);
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: Theme.of(context).textTheme.title),
        ),
        body: Container(
            padding: EdgeInsets.only(top:lrPadding),
            child: ListView(
              itemExtent: 50.0,
              shrinkWrap: true,
              children: [
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () => Navigator.pushNamed(context, '/players-page'),
                  title: Text('Manage Players'),
                  leading: Icon(Icons.people_outline),                  
                ),
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () => Navigator.pushNamed(context, '/edit-player-page', arguments: { 'player': globalPlayerList[0], 'isUser': true }),
                  title: Text('My Player Page'),
                  leading: Icon(Icons.person_outline),
                ),
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () => _signUserOut(context),
                  title: Text('Sign Out'),
                  leading: Icon(logoutIcon),                  
                ),
              ],
            )
        )
      );
  }

  void _signUserOut(BuildContext context) {
    CurrentUser.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }
}