// ignore_for_file: prefer_const_constructors

import 'BottomBarWidgets/SearchPage.dart';
import 'BottomBarWidgets/GoalsPage.dart';
import 'BottomBarWidgets/FavouritesPage.dart';
import 'BottomBarWidgets/SettingsPage.dart';
import 'BottomBarWidgets/BarcodeScanner.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //theme: ThemeData(
      //  primaryColor: const Color.fromARGB(255, 235, 220, 255),
      //  unselectedWidgetColor: const Color.fromARGB(255, 215, 190, 250),
      //  highlightColor: Colors.deepPurple,
      //  canvasColor: const Color.fromARGB(255, 190, 180, 230),
      //  useMaterial3: true,
      //  textTheme: TextTheme(
      //    bodyLarge: TextStyle(color: Colors.black),
      //    bodyMedium: TextStyle(color: Colors.black),
      //  )
      //),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 50, 40, 80),
        unselectedWidgetColor: const Color.fromARGB(255, 100, 80, 150),
        highlightColor: Colors.deepPurpleAccent,
        canvasColor: const Color.fromARGB(255, 30, 25, 50),
        scaffoldBackgroundColor: const Color.fromARGB(255, 20, 18, 40),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        )
      ),
      home: const BottomNavBar(),
    );
  }
}

// https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState()=> _BottomBarNavState();
}

class _BottomBarNavState extends State<BottomNavBar> {

  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    GoalsPage(),
    SearchPage(),
    Barcodescanner(),
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
        child: _pages.elementAt(_selectedIndex),
      ),
      //https://www.geeksforgeeks.org/flutter-convex-bottombar/
      bottomNavigationBar: ConvexAppBar(
          style: TabStyle.fixedCircle,
          color: _inactiveIconColour,
          activeColor: _selectedIconColour,
          backgroundColor: _backgroundColour,
          items: const [
            TabItem(
              icon: Icons.golf_course, 
              title: 'Goals',
            ),
            TabItem(
              icon: Icons.search, 
              title: 'Search'
            ),
            TabItem(
              icon: Icons.qr_code_scanner, 
              title: 'Scan'
            ),
            TabItem(
              icon: Icons.star, 
              title: 'Favourites'
            ),
            TabItem(
              icon: Icons.settings, 
              title: 'Settings'
            ),
          ],
          initialActiveIndex: _selectedIndex,
          onTap: (index) => _onItemTapped(index),
        )
    );
  }
}








