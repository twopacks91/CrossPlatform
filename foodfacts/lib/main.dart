// ignore_for_file: prefer_const_constructors

import 'BottomBarWidgets/SearchPage.dart';
import 'BottomBarWidgets/GoalsPage.dart';
import 'BottomBarWidgets/FavouritesPage.dart';
import 'BottomBarWidgets/SettingsPage.dart';
import 'BottomBarWidgets/BarcodeScanner.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'DatabaseManager.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// Whole app rebuild for theme changing
// Modified code from this website
// https://hillel.dev/2018/08/15/flutter-how-to-rebuild-the-entire-app-to-change-the-theme-or-locale/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  
  static _MyAppState of(BuildContext context){
    return context.findAncestorStateOfType<_MyAppState>()!;
  }

  @override
  State<MyApp> createState()=> _MyAppState(); 
}

class _MyAppState extends State<MyApp>{
  bool _useDarkMode = false;

  // Rebuild the entire app widget tree 
  void rebuild(){
    _getDarkMode();
    setState(() {});
  }

  Future<void> _getDarkMode() async {
    final bool dm = await DatabaseManager.isDarkMode();
    setState(() {
      _useDarkMode = dm;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDarkMode();
  }

  ThemeData darkTheme = ThemeData(
        primaryColor: const Color.fromARGB(255, 50, 40, 80),
        unselectedWidgetColor: const Color.fromARGB(255, 100, 80, 150),
        highlightColor: Colors.deepPurpleAccent,
        canvasColor: const Color.fromARGB(255, 30, 25, 50),
        scaffoldBackgroundColor: const Color.fromARGB(255, 20, 18, 40),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white,fontSize: 12),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color.fromARGB(255, 100, 80, 150),
          elevation: 8
        )
      );

  ThemeData lightTheme = ThemeData(
        primaryColor: const Color.fromARGB(255, 235, 220, 255),
        unselectedWidgetColor: const Color.fromARGB(255, 235, 220, 255),
        highlightColor: Colors.deepPurple,
        canvasColor: const Color.fromARGB(255, 190, 180, 230),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black,fontSize: 12),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color.fromARGB(255, 30, 25, 50),
          elevation: 8
        )
      );

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      theme: (_useDarkMode?darkTheme:lightTheme),
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
  
  Color _selectedIconColour = const Color.fromARGB(255, 71, 74, 255);
  Color _inactiveIconColour = const Color.fromARGB(255, 116, 116, 116);
  Color _backgroundColour = const Color.fromARGB(192, 235, 221, 255);

  //Color _selectedIconColour;
  //Color _inactiveIconColour;
  //Color _backgroundColour;

  void setColors(){
    _backgroundColour = Theme.of(context).unselectedWidgetColor;
    _inactiveIconColour = Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(150);
    _selectedIconColour = Theme.of(context).highlightColor.withGreen(150);
  }
  
  
  @override
  Widget build(BuildContext context) {
    setColors();
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
              icon: Icons.qr_code_scanner_rounded, 
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






