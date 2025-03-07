import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Food{
  String name;
  String imageUrl;
  Food(this.name,this.imageUrl);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final Color _inactiveIconColour = const Color.fromARGB(255, 75, 75, 75);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Facts'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}

class SearchPage extends StatefulWidget
{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState()=> _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
{
  List<Food> items = [];

  String query = 'jaffa cake';

  Future<void> fetchFoods() async {
    final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true');
    final response = await http.get(url);
    List<Food> newFoods = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>;

      for (var product in products) {
        final String? name = product['product_name'];
        final String? imageUrl = product['image_url'];

        if (name != null && imageUrl != null) {
          newFoods.add( Food(name,imageUrl));
        }
      }
      setState(() {
        items = newFoods;
      });
    } 
    else {
      print('Failed to fetch products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foods')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[700], // Background color
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  items[index].imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  items[index].name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: fetchFoods,child: const Icon(Icons.refresh),),
    );
  }
}

class GoalsPage extends StatefulWidget
{
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState()=> _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
{
  @override
  Widget build(BuildContext context) 
  {
    return const Scaffold(
      body: Text(
      'Index 1: Goals',
      ),
    );
  }
}

class FavouritesPage extends StatefulWidget
{
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState()=> _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
{
  @override
  Widget build(BuildContext context) 
  {
    return const Scaffold(
      body: Text(
      'Index 2: Favourites',
      ),
    );
  }
}

class SettingsPage extends StatefulWidget
{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState()=> _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
{
  @override
  Widget build(BuildContext context) 
  {
    return const Scaffold(
      body: Text(
      'Index 3: Settings',
      ),
    );
  }
}
