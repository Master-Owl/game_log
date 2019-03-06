import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_log/screens/home-page.dart';
import 'package:game_log/screens/logs-page.dart';
import 'package:game_log/screens/settings-page.dart';

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
      home: MainApp()
    );
  }
}

class MainApp extends StatefulWidget {
  MainApp({Key key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _pageIdx;
  Widget _currentPage;
  List<Widget> _mainPages;
  List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('Settings'),),
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
    BottomNavigationBarItem(icon: Icon(Icons.view_list), title: Text('Logs'))
  ];

  @override
  void initState() {
    _mainPages = [
      SettingsPage(),
      HomePage(),
      LogsPage()
    ];

    _pageIdx = 1;
    _currentPage = _mainPages[_pageIdx];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _pageIdx,
        onTap: _onTap,
      )
    );
  }

  void _onTap(int idx) {
    setState(() {
      _pageIdx = idx;
      _currentPage = _mainPages[idx];
    });
  }
}