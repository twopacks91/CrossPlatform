// ignore_for_file: prefer_const_constructors

import 'BottomBarWidgets/SearchPage.dart';
import 'BottomBarWidgets/GoalsPage.dart';
import 'BottomBarWidgets/FavouritesPage.dart';
import 'BottomBarWidgets/SettingsPage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 235, 221, 255),
        unselectedWidgetColor: const Color.fromARGB(255, 215, 191, 248),
        highlightColor: Colors.deepPurple,
        canvasColor: const Color.fromARGB(96, 81, 58, 183),
        useMaterial3: true,
      ),
      home: const BottomNavBar(),
    );
  }
}

// https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
class BottomNavBar extends StatefulWidget
{
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState()=> _BottomBarNavState();
}

class _BottomBarNavState extends State<BottomNavBar>
{
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    SearchPage(),
    GoalsPage(),
    FavouritesPage(),
    SettingsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Color _selectedIconColour = const Color.fromARGB(255, 71, 74, 255);
  final Color _inactiveIconColour = const Color.fromARGB(255, 116, 116, 116);
  final Color _backgroundColour = const Color.fromARGB(192, 235, 221, 255);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: _backgroundColour,
          shadowColor: Colors.amber
        ), 
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: 
                (_selectedIndex==0) ? (_selectedIconColour) : (_inactiveIconColour)),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.golf_course, color: 
                (_selectedIndex==1) ? (_selectedIconColour) : (_inactiveIconColour)),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star, color: 
                (_selectedIndex==2) ? (_selectedIconColour) : (_inactiveIconColour)),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: 
                (_selectedIndex==3) ? (_selectedIconColour) : (_inactiveIconColour)),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: _selectedIconColour,
          onTap: _onItemTapped,
        ),
      )
    );
  }
}








