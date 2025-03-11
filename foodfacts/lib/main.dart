// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Food{
  String name;
  String imageUrl;
  String barcode;
  Food(this.name,this.imageUrl,this.barcode);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  TextEditingController _searchBarController = TextEditingController();
  TextEditingController _weightEntryController = TextEditingController();
  String query = 'jaffa cake';
  bool _showFoodInfo = false;
  int _foodInfoIndex = 0;

  Future<void> fetchFoods() async {
    query = _searchBarController.text;
    final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true');
    final response = await http.get(uri);
    List<Food> newFoods = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>;

      for (var product in products) {
        final String? name = product['product_name'];
        final String? imageUrl = product['image_url'];
        final String? barcode = product['code'];
        if (name != null && imageUrl != null && barcode != null) {
          newFoods.add( Food(name,imageUrl,barcode));
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

  void tappedFood(int index)
  {
    print("Tapped $index");
    setState(() {
      _showFoodInfo = true;
      _foodInfoIndex = index;
    });

  }


  GridView itemViewer()
  {
    return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              tappedFood(index);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Color.fromARGB(255, 104, 80, 107),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    items[index].imageUrl,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items[index].name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
          
        },
      );
  }

  Scaffold FoodList()
  {
    return Scaffold(
      body: Column(children: [
        Padding(padding: 
        EdgeInsets.all(12),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Enter food name",
            border: OutlineInputBorder(),
            icon: Icon(Icons.search))
          ,controller: _searchBarController,),)
        ,
        Expanded(child: itemViewer(),),
      ],),
      floatingActionButton: FloatingActionButton(onPressed: fetchFoods,child: const Icon(Icons.refresh),),
    );
  }

  void decreaseWeight()
  {
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) - 10;
      _weightEntryController.text = newWeight.toString();
    });
  }

  void increaseWeight()
  {
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) + 10;
      _weightEntryController.text = newWeight.toString();
    });
  }


  Scaffold foodInfo()
  {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              height: 200,
              child: Image.network(
                items[_foodInfoIndex].imageUrl,
                fit: BoxFit.fill,
              )
            ),
            
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: decreaseWeight,
                    child: Text('-')
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      border: OutlineInputBorder(),
                    ),
                  controller: _weightEntryController,
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: increaseWeight,
                    child: Text('+')
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_showFoodInfo? foodInfo():FoodList());
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
  final double carbsProgress = 0.3;
  final double proteinProgress = 0.2;
  final double saltProgress = 0.5;
  final double fatProgress = 0.8;

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(20)),
          createProgressCircle(300, 300, "Carbs", carbsProgress),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            children: [
              createProgressCircle(100, 100, "Protein", proteinProgress),
              createProgressCircle(100, 100, "Salt", saltProgress),
              createProgressCircle(100, 100, "Fat", fatProgress),
            ], 
          )
        ],
      )
    );
  }

  Widget createProgressCircle(double width,double height,String text, double progress)
  {
    return Center(child: 
        Stack(children: [
          SizedBox(width: width,height: height, child: 
            CircularProgressIndicator(semanticsLabel: text,value: progress,)
          ,),
          SizedBox(width: width,height: height, child: 
            Center(child: 
              Text(text),
            )
          ,)
          ],
        )
      ,);
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
