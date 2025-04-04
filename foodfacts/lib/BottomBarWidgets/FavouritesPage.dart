

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodfacts/Food.dart';
import 'package:foodfacts/MyWidgets/InternetImage.dart';
import 'package:foodfacts/MyWidgets/MySnackBar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class FavouritesPage extends StatefulWidget
{
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState()=> _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
{
  bool _hasNoFavourites = true;
  List<Food> _foodList = [];
  final TextEditingController _weightEntryController = TextEditingController();
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
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Food removed from favourites list",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));
    }
  }

  void tappedFood(int index)
  {
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
                    _foodList[index].name,
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
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
          children: [
            const Padding(
              padding: 
                EdgeInsets.all(12),
              ),
              Expanded(child: FutureBuilder(future: isConnectedToInternet(), builder: (context,snapshot){

                if(snapshot.connectionState == ConnectionState.done){
                  if(snapshot.data==true){
                    if(_hasNoFavourites){
                      return const Center(
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text("You have no favourited foods",textAlign: TextAlign.center),
                            Text("Try adding some from the search page",textAlign: TextAlign.center),
                          ],
                        )
                      );
                    }
                    else{
                      return itemViewer();
                    }
                  }
                  else{
                    return connectionIssue();
                  }
                }
                else{
                  return foodGridSkeleton();
                }
                
              }),
            ),
          ],
        )
    );
  }

  Future<bool> isConnectedToInternet() async{
    try{
      // ignore: unused_local_variable
      dynamic resp = await http.get(Uri.parse("https://example.com/api/fetch?limit=10,20,30&max=100"));
      return true;
    }
    catch(ex){
      return false;
    }
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
    double weight = (int.tryParse(_weightEntryController.text) ?? 0).toDouble();
    if(weight>0)
    {
      food.weight = weight;
      await FirebaseFirestore.instance.collection("meals").doc(docName).set(food.asMap());
      setState(() {
      _showFoodInfo = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Meal added",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2)));
      }
    }
    else
    {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(MySnackBar(content: Text("Enter a meal weight before adding",style: Theme.of(context).textTheme.bodyMedium),duration: const Duration(seconds: 2),));      
      }
      
    }
  }

  void backToItemsPage()
  {
    setState(() {
      _showFoodInfo = false;
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
                  color: Theme.of(context).primaryColor,
                  border: Border.all(color: Theme.of(context).highlightColor)
                ),
              ),
        );
      }
    );
  }

  Scaffold foodInfo()
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
                height: 200,
              )
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
                  child: 
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        ),
                      onPressed: removeFoodFromFavourites,
                      child: Text('Remove favourite',style: Theme.of(context).textTheme.bodyMedium)
                    )
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
  void initState()
  {
    super.initState();
    fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    return (_showFoodInfo? foodInfo():foodList());
  }
  
  Widget connectionIssue()
  {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).highlightColor),
          color: Theme.of(context).primaryColor,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("You need to be connected to the internet to use the favourites feature"),
            ],
          ),
        ),
      )
    );
  }
}