import 'package:flutter/material.dart';
import 'package:game_log/data/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_log/data/user.dart';

class SettingsPage extends StatelessWidget{
  SettingsPage({Key key}) : super(key: key);

  Widget build(BuildContext context) {
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
                  contentPadding: EdgeInsets.only(left: lrPadding*1.5),
                  onTap: () => Navigator.pushNamed(context, '/players-page'),
                  title: Text('Manage Players'),
                  leading: Icon(Icons.people_outline),                  
                ),
                ListTile(
                  contentPadding: EdgeInsets.only(left: lrPadding*1.5),
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