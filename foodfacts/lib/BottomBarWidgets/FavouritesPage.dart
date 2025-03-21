// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodfacts/Food.dart';


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
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Theme.of(context).primaryColor,
                border: Border.all(color: Theme.of(context).highlightColor)
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
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
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

  void backToItemsPage()
  {
    setState(() {
      _showFoodInfo = false;
    });
  }

  Scaffold foodInfo()
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20,),
            SizedBox(
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
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
                      filled:true,
                      fillColor: Theme.of(context).primaryColor,
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: increaseWeight,
                    child: Text('+',style: TextStyle(fontSize: 20))
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox(),),
            Container(
              padding: EdgeInsets.all(12),
              width: 420,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).highlightColor),
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  
                  Text("Calories: ${_foodList[_foodInfoIndex].calories}kcal",style: TextStyle(fontSize: 20)),
                  Text("Carbs   : ${_foodList[_foodInfoIndex].carbs}g",style: TextStyle(fontSize: 20)),
                  Text("Protein : ${_foodList[_foodInfoIndex].protein}g",style: TextStyle(fontSize: 20)),
                  Text("Salt    : ${_foodList[_foodInfoIndex].salt}g",style: TextStyle(fontSize: 20)),
                  Text("Fat     : ${_foodList[_foodInfoIndex].fat}g",style: TextStyle(fontSize: 20)),
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: backToItemsPage,
                    child: Text('Back')
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: confirmSelection,
                    child: Text('Confirm selection')
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
                      child: Text('Remove favourite')
                    )
                )
              ],
            ),
            SizedBox(height: 20,)
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
}