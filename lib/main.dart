import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Color(0x00FFFFFF)
    ));
    return new MaterialApp(
      title: 'GameLog',
      theme: new ThemeData(
        primarySwatch: MaterialColor(0xFF6FCF97,
            {
              50: Color(0xFFCFF6DF),
              100: Color(0xFFCFF6DF),
              200: Color(0xFFCFF6DF),
              300: Color(0xFF9DE5BA),
              400: Color(0xFF9DE5BA),
              500: Color(0xFF6FCF97),
              600: Color(0xFF6FCF97),
              700: Color(0xFF49B675),
              800: Color(0xFF49B675),
              900: Color(0xFF2D9E5B)
            }),
        accentColor: MaterialAccentColor(0xFF6BA6C0,
            {
              50: Color(0xFFCEE8F3),
              100: Color(0xFFCEE8F3),
              200: Color(0xFFCEE8F3),
              300: Color(0xFF9AC9DD),
              400: Color(0xFF9AC9DD),
              500: Color(0xFF6BA6C0),
              600: Color(0xFF6BA6C0),
              700: Color(0xFF45849F),
              800: Color(0xFF45849F),
              900: Color(0xFF2C6E8B)
            }),
        fontFamily: 'Robotto',
        textTheme: TextTheme(
            headline: TextStyle(fontSize: 64.0, color: Colors.black87),
            title: TextStyle(fontSize: 36.0, color: Colors.black54, fontWeight: FontWeight.w300)
        )
      ),
      home: new MyHomePage(title: 'GameLog'),
    );
  }
}