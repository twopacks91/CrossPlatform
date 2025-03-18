// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodfacts/Food.dart';
import 'package:intl/intl.dart';

class GoalsPage extends StatefulWidget
{
  const GoalsPage({super.key});
  

  @override
  State<GoalsPage> createState()=> _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
{
  // Read these from database
  double carbsGoal = 100;
  double proteinGoal = 25;
  double saltGoal = 15;
  double fatGoal = 25;

  double carbsTotal = 0;
  double proteinTotal = 0;
  double saltTotal = 0;
  double fatTotal = 0;

  double carbsProgress = 0;
  double proteinProgress = 0;
  double saltProgress = 0;
  double fatProgress = 0;

  List<Food> _meals = [];

  void fetchMeals() async {
    List<Food> newFoods = [];
    carbsTotal = 0;
    proteinTotal = 0;
    saltTotal= 0;
    fatTotal= 0;
    await FirebaseFirestore.instance.collection("meals").get().then((collection){
      for (dynamic doc in collection.docs){
        
        dynamic docData = doc.data();
        int timeAdded = docData["timeAdded"];
        int timeSinceAdded = DateTime.timestamp().millisecondsSinceEpoch - timeAdded;
        const int millisecondsPerDay = 24 * 60 * 60 * 1000;

        // Only display meals eaten in the last 24 hours
        if(timeSinceAdded<millisecondsPerDay)
        {
          String name = docData['name'];
          String imageUrl = docData['imageUrl'];
          String barcode = docData['barcode'];
          double calories = docData["calories"]?.toDouble();
          double carbs = docData["carbs"]?.toDouble();
          carbsTotal += carbs;
          double protein = docData["protein"]?.toDouble();
          proteinTotal += protein;
          double salt = docData["salt"]?.toDouble();
          saltTotal += salt;
          double fat = docData["fat"]?.toDouble();
          fatTotal += fat;

          double weight = docData["weight"].toDouble();
          Food newFood = Food(name, imageUrl, barcode, calories, carbs, protein, salt, fat);
          newFood.timeAdded = timeAdded;
          newFood.weight = weight;
          newFoods.add(newFood);
        }
        
      }
    });
    // Sort meals by time added to database
    newFoods.sort((a,b) => b.timeAdded!.compareTo(a.timeAdded!));
    setState(() {
      carbsProgress = carbsTotal/carbsGoal;
      proteinProgress = proteinTotal/proteinGoal;
      saltProgress = saltTotal/saltGoal;
      fatProgress = fatTotal/fatGoal;
      _meals = newFoods;
    });
  }

  void removeMeal(Food meal) async{
    String docName = meal.barcode + meal.timeAdded.toString();
    await FirebaseFirestore.instance.collection("meals").doc(docName).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal removed"),duration: Duration(seconds: 2),));
    fetchMeals();
  }

  @override
  void initState()
  {
    super.initState();
    fetchMeals();
  }

  String unixToTimeString(int unix)
  {
    DateTime dt =DateTime.fromMillisecondsSinceEpoch(unix).toLocal();
    return DateFormat('HH:mm').format(dt);
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(20)),
          createProgressCircle(300, 300, "Carbs", carbsProgress),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            children: [
              createProgressCircle(100, 100, "Protein", proteinProgress),
              createProgressCircle(100, 100, "Salt", saltProgress),
              createProgressCircle(100, 100, "Fat", fatProgress),
            ], 
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.all(12),
            width: 420,
            height: 350,
            
            child: ListView.builder(
              itemCount: _meals.length,
              itemBuilder: (context,index){
                return Card(
                  child: ExpansionTile(
                    title: Text("${_meals[index].name} : ${_meals[index].weight.toString()}g"),
                    trailing: Icon(Icons.arrow_drop_down),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time eaten: ${(_meals[index].timeAdded==null?"Time eaten not available":unixToTimeString(_meals[index].timeAdded!))}"),
                            Text("Calories  : ${_meals[index].calories}kcal"),
                            Text("Carbs     : ${_meals[index].carbs}g"),
                            Text("Protein   : ${_meals[index].protein}g"),
                            Text("Salt      : ${_meals[index].salt}g"),
                            Text("Fat       : ${_meals[index].fat}g"),
                            SizedBox(height: 10,),
                            Center(
                              child: OutlinedButton(onPressed: ()=>{removeMeal(_meals[index])}, child: Text("Remove meal")),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                    
                );
              }
            
            ),
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