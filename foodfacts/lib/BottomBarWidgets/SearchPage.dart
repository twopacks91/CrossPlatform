import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodfacts/MyWidgets/InternetImage.dart';
import 'package:foodfacts/MyWidgets/MySnackBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foodfacts/Food.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget
{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState()=> _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
{
  List<Food> _foodList = [];
  final TextEditingController _searchBarController = TextEditingController();
  final TextEditingController _weightEntryController = TextEditingController();
  String query = 'jaffa cake';
  bool _showFoodInfoScreen = false;
  int _foodInfoIndex = 0;
  bool _showSkeletonUI = false;
  bool _failedToFetchFoods = false;

  Future<void> fetchFoods() async {
    query = _searchBarController.text;
    final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true');
    try{
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
        _failedToFetchFoods = false;
      });
    } 
    else {
      print('Failed to fetch products');
      setState(() {
        _failedToFetchFoods = true;
      });
    }
    }
    catch(ex){
      print("No wifi probs");
      setState(() {
        _failedToFetchFoods = true;
      });
      return;
    }
    
  }

  void addFoodToFavourites() async
  {
    Food food = _foodList[_foodInfoIndex];
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).set(food.asMap());
    setState(() {
      _showFoodInfoScreen = false;
    });
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Food added to favourites list",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));
    }
  }

  void removeFoodFromFavourites() async
  {
    setState(() {
      _showFoodInfoScreen = false;
    });
    Food food = _foodList[_foodInfoIndex];
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).delete();
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Food removed from favourites list",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));
    }
  }

  void tappedFood(int index)
  {
    setState(() {
      _showFoodInfoScreen = true;
      _foodInfoIndex = index;
    });

  }

  // Used when waiting for API to return meaningful data
  GridView foodGridSkeleton(){
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ), 
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      itemBuilder: (context,index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).primaryColor, 
          highlightColor: Theme.of(context).splashColor,
          child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).highlightColor,
                  border: Border.all(color: Theme.of(context).highlightColor)
                ),
              ),
        );
      }
    );
  }

  Widget foodGrid() {
    if(_showSkeletonUI) {
      return foodGridSkeleton();
    }
    else if(_foodList.isEmpty)
    {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).primaryColor
            ),
            width: 300,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ (_failedToFetchFoods?
                const Text("Something went wrong :("):
                const Text("Please enter the name of a food in the text box above")
              )
              ],
            ),
          )
        ],
      );
    }
    else {
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
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).primaryColor,
                  border: Border.all(color: Theme.of(context).highlightColor)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InternetImage(
                      url: _foodList[index].imageUrl, 
                      height: 150
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _foodList[index].name
                    ),
                  ],
                ),
              ),
            );

          },
        );
      }
  }


  void updateFoodList() async {
    setState(() {
      _showSkeletonUI = true;
    });
    await fetchFoods();
    setState(() {
      _showSkeletonUI = false;
    });
  }
  Scaffold foodSearchScreen()
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: 
            const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).primaryColor,
                  hintText: "Enter food name",
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
                  border: const OutlineInputBorder(),
                  focusColor: Theme.of(context).highlightColor,
                  suffixIconColor: Theme.of(context).highlightColor,
                  suffixIcon: IconButton(
                    onPressed: updateFoodList, 
                    icon: const Icon(Icons.search)
                  )
                ),
                controller: _searchBarController
              ),
            ),
            Expanded(child: foodGrid(),
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


  void addMealToDB() async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    Food food = _foodList[_foodInfoIndex];
    food.timeAdded = timeStamp;
    String docName = food.barcode + timeStamp.toString();
    double weight = (int.tryParse(_weightEntryController.text) ?? 0).toDouble();
    if(weight>0)
    {
      food.weight = weight;
      await FirebaseFirestore.instance.collection("meals").doc(docName).set(food.asMap());
      setState(() {
      _showFoodInfoScreen = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Meal added",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Enter a meal weight before adding",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));
    }
  }

  void backToItemsPage()
  {
    setState(() {
      _showFoodInfoScreen = false;
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

  Scaffold foodInfoScreen()
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 20,),
            SizedBox(
              height: 200,
              child: InternetImage(
                url: _foodList[_foodInfoIndex].imageUrl, 
                height: 150
              ),
            ),
            const Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: decreaseWeight,
                    child: Text('-',style: Theme.of(context).textTheme.bodyLarge,)
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      hintStyle: Theme.of(context).textTheme.bodyLarge,
                      filled:true,
                      fillColor: Theme.of(context).primaryColor,
                      border: const OutlineInputBorder(),
                    ),
                  controller: _weightEntryController,
                  textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8,),
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: increaseWeight,
                    child: Text('+',style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox(),),
            Container(
              padding: const EdgeInsets.all(12),
              width: 420,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).highlightColor),
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  
                  Text("Calories: ${_foodList[_foodInfoIndex].calories.round()}kcal",style: const TextStyle(fontSize: 20)),
                  Text("Carbs   : ${_foodList[_foodInfoIndex].carbs.round()}g",style: const TextStyle(fontSize: 20)),
                  Text("Protein : ${_foodList[_foodInfoIndex].protein.round()}g",style: const TextStyle(fontSize: 20)),
                  Text("Salt    : ${_foodList[_foodInfoIndex].salt.round()}g",style: const TextStyle(fontSize: 20)),
                  Text("Fat     : ${_foodList[_foodInfoIndex].fat.round()}g",style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: backToItemsPage,
                    child: Text('Back',style: Theme.of(context).textTheme.bodyMedium)
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: addMealToDB,
                    child: Text('Confirm meal',style: Theme.of(context).textTheme.bodyMedium)
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
                          style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: removeFoodFromFavourites,
                          child: Text('Remove favourite',style: Theme.of(context).textTheme.bodyMedium)
                        )
                      :
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: addFoodToFavourites,
                          child: Text('Add to favourites',style: Theme.of(context).textTheme.bodyMedium)
                        )
                      );
                    }
                    else
                    {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: (){ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Still talking with database, try again later",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));},
                          child: Text('Add to favourites',style: Theme.of(context).textTheme.bodyMedium)
                        );
                    }
                  })
                  )
              ],
            ),
            const SizedBox(height: 20,)
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_showFoodInfoScreen? foodInfoScreen():foodSearchScreen());
  }
}