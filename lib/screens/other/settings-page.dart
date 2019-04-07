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
            padding: EdgeInsets.only(left:lrPadding, top: 16.0, right:lrPadding),
            child: ListView(
              itemExtent: 75.0,
              shrinkWrap: true,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  onTap: () => _signUserOut(context),
                  title: Text('Sign Out'),
                  leading: Icon(logoutIcon),                  
                )
              ],
            )
        )
      );
  }

  void _signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    CurrentUser.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }
}