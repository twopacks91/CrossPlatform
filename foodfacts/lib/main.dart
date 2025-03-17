// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class Food{
  String name;
  String imageUrl;
  String barcode;
  double? calories;
  double? carbs;
  double? protein;
  double? salt;
  double? fat;
  int? timeAdded;
  double? weight;
  Food(this.name,this.imageUrl,this.barcode,this.calories,this.carbs,this.protein,this.salt,this.fat);

  Map<String,dynamic> asMap() {
    if(timeAdded == null || weight == null) {
      return {
        'name': name,
        'imageUrl': imageUrl,
        'barcode': barcode,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'salt': salt,
        'fat': fat,
      };
    }
    else{
      return {
        'name': name,
        'imageUrl': imageUrl,
        'barcode': barcode,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'salt': salt,
        'fat': fat,
        'timeAdded' : timeAdded,
        'weight' : weight,
      };
    }
    
  }
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
  List<Food> _foodList = [];
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
        final nutriments = product['nutriments'] as Map<String, dynamic>;
        
        //nutriments["carbohydrates_value"]
        //nutriments["energy_value"]
        //nutriments["fat_value"]
        //nutriments["salt_100g"]
        
        final double? calories = (nutriments['energy_value'])?.toDouble();
        final double? carbs = (nutriments['carbohydrates_value'])?.toDouble();
        final double? protein = (nutriments['proteins'])?.toDouble();
        final double? salt = (nutriments['salt_100g'])?.toDouble();
        final double? fat = (nutriments['fat_value'])?.toDouble();

        if (name != null && 
        imageUrl != null && 
        barcode != null &&
        calories != null &&
        carbs != null &&
        protein != null &&
        salt != null &&
        fat != null
        ) {
          newFoods.add( Food(name,imageUrl,barcode,calories,carbs,protein,salt,fat));
        }
      }
      setState(() {
        _foodList = newFoods;
      });
    } 
    else {
      print('Failed to fetch products');
    }
  }

  void addFoodToFavourites() async
  {
    Food food = _foodList[_foodInfoIndex];
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).set(food.asMap());
    setState(() {
      _showFoodInfo = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Food added to favourites list"),duration: Duration(seconds: 2),));
  }

  void removeFoodFromFavourites() async
  {
    setState(() {
      _showFoodInfo = false;
    });
    Food food = _foodList[_foodInfoIndex];
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Food removed from favourites list"),duration: Duration(seconds: 2),));
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
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _foodList.length,
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
                    _foodList[index].imageUrl,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _foodList[index].name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
          
        },
      );
  }

  Scaffold foodList()
  {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: 
            EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter food name",
                  border: OutlineInputBorder(),
                  icon: IconButton(
                    onPressed: fetchFoods, 
                    icon: Icon(Icons.search)
                  )
                ),
                controller: _searchBarController
              ),
            ),
            Expanded(child: itemViewer(),
          ),
        ],
      ),
    );
  }

  void decreaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text=="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) - 10;
      if(newWeight<=0)
      {
        _weightEntryController.text = "0";
      }
      else
      {
        _weightEntryController.text = newWeight.toString();
      }
      
    });
  }

  void increaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) + 10;
      _weightEntryController.text = newWeight.toString();
    });
  }

  void confirmSelection()
  {
    addMealToDB();
    
    
  }

  void addMealToDB() async
  {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    Food food = _foodList[_foodInfoIndex];
    food.timeAdded = timeStamp;
    String docName = food.barcode + timeStamp.toString();
    double weight = int.parse(_weightEntryController.text).toDouble();
    if(weight>0)
    {
      food.weight = weight;
      await FirebaseFirestore.instance.collection("meals").doc(docName).set(food.asMap());
      setState(() {
      _showFoodInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal added"),duration: Duration(seconds: 2),));
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a meal weight before adding"),duration: Duration(seconds: 2),));
    }
  }

  void backToItemsPage()
  {
    setState(() {
      _showFoodInfo = false;
    });
  }

  Future<bool> isSelectedItemFavourited() async
  {
    List<String> favedBarcodes = [];
    await FirebaseFirestore.instance.collection("favfoods").get().then((collection){
      for (dynamic doc in collection.docs){
        favedBarcodes.add(doc.id);
      }
    });
    if(favedBarcodes.contains(_foodList[_foodInfoIndex].barcode)) { 
      return true;
    }
    else
    {
      return false;
    }
  }

  Scaffold foodInfo()
  {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20,),
            SizedBox(
              width: 400,
              height: 200,
              child: Image.network(
                _foodList[_foodInfoIndex].imageUrl,
                fit: BoxFit.fill,
              )
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: decreaseWeight,
                    child: Text('-')
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      border: OutlineInputBorder(),
                    ),
                  controller: _weightEntryController,
                  textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8,),
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: increaseWeight,
                    child: Text('+')
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox(),),
            Container(
              padding: EdgeInsets.all(12),
              width: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black)
              ),
              child: Column(
                children: [
                  Text("Calories: ${_foodList[_foodInfoIndex].calories}kcal"),
                  Text("Carbs   : ${_foodList[_foodInfoIndex].carbs}g"),
                  Text("Protein : ${_foodList[_foodInfoIndex].protein}g"),
                  Text("Salt    : ${_foodList[_foodInfoIndex].salt}g"),
                  Text("Fat     : ${_foodList[_foodInfoIndex].fat}g"),
                ],
              ),
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: backToItemsPage,
                    child: Text('Back')
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: confirmSelection,
                    child: Text('Confirm selection')
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: FutureBuilder(future: isSelectedItemFavourited(), builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.done)
                    {
                      bool isFavourited = snapshot.data ?? false;
                      return (isFavourited?
                        OutlinedButton(
                          onPressed: removeFoodFromFavourites,
                          child: Text('Remove from favourites')
                        )
                      :
                        OutlinedButton(
                          onPressed: addFoodToFavourites,
                          child: Text('Add food to favourites')
                        )
                      );
                    }
                    else
                    {
                      return OutlinedButton(
                          onPressed: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Still talking with database, try again later"),duration: Duration(seconds: 2),));},
                          child: Text('Add food to favourites')
                        );
                    }
                  })
                  )
                
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_showFoodInfo? foodInfo():foodList());
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
  bool _hasNoFavourites = false;
  List<Food> _foodList = [];
  TextEditingController _weightEntryController = TextEditingController();
  String query = 'jaffa cake';
  bool _showFoodInfo = false;
  int _foodInfoIndex = 0;

  void fetchFoods() async{
    List<Food> newFoods = [];
    await FirebaseFirestore.instance.collection("favfoods").get().then((collection){
      if(collection.docs.isEmpty)
      {
        setState(() {
          _hasNoFavourites = true;
        });
      }
      else
      {
        for (dynamic doc in collection.docs){
          dynamic docData = doc.data();
          String name = docData['name'];
          String imageUrl = docData['imageUrl'];
          String barcode = docData['barcode'];
          double calories = docData["calories"]?.toDouble();
          double carbs = docData["carbs"]?.toDouble();
          double protein = docData["protein"]?.toDouble();
          double salt = docData["salt"]?.toDouble();
          double fat = docData["fat"]?.toDouble();

          newFoods.add(Food(name,imageUrl,barcode,calories,carbs,protein,salt,fat));
        }
        if(mounted)
        {
          setState(() {
          _hasNoFavourites = false;
          _foodList=newFoods;
        });
        }
        
      }
    });
    
  }

  void removeFoodFromFavourites() async
  {
    setState(() {
      _showFoodInfo = false;
      fetchFoods();
    });
    Food food = _foodList[_foodInfoIndex];
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Food removed from favourites list"),duration: Duration(seconds: 2),));
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
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _foodList.length,
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
                    _foodList[index].imageUrl,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _foodList[index].name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
          
        },
      );
  }

  Scaffold foodList()
  {
    return Scaffold(
      body: (_hasNoFavourites? 
        // If user has no favourited foods, tell them
        Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const [
              Text("You have no favourited foods",textAlign: TextAlign.center),
              Text("Try adding some from the search page",textAlign: TextAlign.center),
            ],
          )
        )
        :
        // Else display their favourites
        Column(
          children: [
            Padding(
              padding: 
                EdgeInsets.all(12),
              ),
              Expanded(child: itemViewer(),
            ),
          ],
        )
      )
    );
  }

  void decreaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) - 10;
      if(newWeight<=0)
      {
        _weightEntryController.text = "0";
      }
      else
      {
        _weightEntryController.text = newWeight.toString();
      }
      
    });
  }

  void increaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) + 10;
      _weightEntryController.text = newWeight.toString();
    });
  }

  void confirmSelection()
  {
    addMealToDB();
    
    
  }

  void addMealToDB() async
  {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    Food food = _foodList[_foodInfoIndex];
    food.timeAdded = timeStamp;
    String docName = food.barcode + timeStamp.toString();
    double weight = int.parse(_weightEntryController.text).toDouble();
    if(weight>0)
    {
      food.weight = weight;
      await FirebaseFirestore.instance.collection("meals").doc(docName).set(food.asMap());
      setState(() {
      _showFoodInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal added"),duration: Duration(seconds: 2),));
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a meal weight before adding"),duration: Duration(seconds: 2),));
    }
  }

  Scaffold foodInfo()
  {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20,),
            SizedBox(
              width: 400,
              height: 200,
              child: Image.network(
                _foodList[_foodInfoIndex].imageUrl,
                fit: BoxFit.fill,
              )
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: decreaseWeight,
                    child: Text('-')
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      border: OutlineInputBorder(),
                    ),
                  controller: _weightEntryController,
                  textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8,),
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: increaseWeight,
                    child: Text('+')
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox(),),
            Container(
              padding: EdgeInsets.all(12),
              width: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black)
              ),
              child: Column(
                children: [
                  Text("Calories: ${_foodList[_foodInfoIndex].calories}kcal"),
                  Text("Carbs   : ${_foodList[_foodInfoIndex].carbs}g"),
                  Text("Protein : ${_foodList[_foodInfoIndex].protein}g"),
                  Text("Salt    : ${_foodList[_foodInfoIndex].salt}g"),
                  Text("Fat     : ${_foodList[_foodInfoIndex].fat}g"),
                ],
              ),
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 175,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: confirmSelection,
                    child: Text('Confirm selection')
                  ),
                ),
                SizedBox(
                  width: 175,
                  height: 50,
                  child:OutlinedButton(
                    onPressed: removeFoodFromFavourites,
                    child: Text('Remove from favourites')
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchFoods();
    return (_showFoodInfo? foodInfo():foodList());
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
