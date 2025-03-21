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
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 235, 220, 255),
        unselectedWidgetColor: const Color.fromARGB(255, 215, 190, 250),
        highlightColor: Colors.deepPurple,
        canvasColor: const Color.fromARGB(255, 190, 180, 230),
        useMaterial3: true,
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
          onTap: (int i) => _onItemTapped(i),
        )
        //BottomNavigationBar(
        //  items: <BottomNavigationBarItem>[
        //    BottomNavigationBarItem(
        //      icon: Icon(Icons.search, color: 
        //        (_selectedIndex==0) ? (_selectedIconColour) : (_inactiveIconColour)),
        //      label: 'Search',
        //    ),
        //    BottomNavigationBarItem(
        //      icon: Icon(Icons.golf_course, color: 
        //        (_selectedIndex==1) ? (_selectedIconColour) : (_inactiveIconColour)),
        //      label: 'Goals',
        //    ),
        //    BottomNavigationBarItem(
        //      icon: Icon(Icons.star, color: 
        //        (_selectedIndex==2) ? (_selectedIconColour) : (_inactiveIconColour)),
        //      label: 'Favourites',
        //    ),
        //    BottomNavigationBarItem(
        //      icon: Icon(Icons.settings, color: 
        //        (_selectedIndex==3) ? (_selectedIconColour) : (_inactiveIconColour)),
        //      label: 'Settings',
        //    ),
        //  ],
        //  currentIndex: _selectedIndex,
        //  selectedItemColor: _selectedIconColour,
        //  onTap: _onItemTapped,
        //),
    );
  }
}








