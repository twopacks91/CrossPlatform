// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodfacts/Food.dart';
import 'package:intl/intl.dart';
import '../MyWidgets/GoalProgressCircle.dart';

class GoalsPage extends StatefulWidget
{
  const GoalsPage({super.key});
  

  @override
  State<GoalsPage> createState()=> _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
{
  // Read these from database
  int carbsGoal = 100;
  int proteinGoal = 100;
  int saltGoal = 100;
  int fatGoal = 100;

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

  Future<void> updateGoals() async {
    dynamic doc = await FirebaseFirestore.instance.collection("settings").doc("goals").get();
    Map<String,dynamic> docData = doc.data() as Map<String,dynamic>;
    int carbs = docData["carbsgoal"];
    int protein = docData["proteingoal"];
    int salt = docData["saltgoal"];
    int fat = docData["fatgoal"];
    setState(() {
      carbsGoal = carbs;
      proteinGoal = protein;
      saltGoal = salt;
      fatGoal = fat;
    });
  }

  @override
  void initState()
  {
    super.initState();
    updateGoals();
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
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        
        children: [
          Padding(padding: EdgeInsets.all(20)),
          GoalProgressCircle(
                diameter: 200, 
                progress: carbsProgress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${carbsTotal}g"),
                    Text("Carbs"),
                  ]
                ),
              ),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            children: [
              GoalProgressCircle(
                diameter: 100, 
                progress: proteinProgress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${proteinTotal}g"),
                    Text("Protein"),
                  ]
                ),
              ),
              GoalProgressCircle(
                diameter: 100, 
                progress: saltProgress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${saltTotal}g"),
                    Text("Salt"),
                  ]
                ),
              ),
              GoalProgressCircle(
                diameter: 100, 
                progress: fatProgress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${fatTotal}g"),
                    Text("Fat"),
                  ]
                ),
              ),
            ], 
          ),
          SizedBox(height: 20,),
          Padding(padding: EdgeInsets.all(8),child: 
          Container(
            width: 420,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Theme.of(context).highlightColor),
              color: Theme.of(context).primaryColor
            ),
            child: ( _meals.isEmpty ? 
            // If there are no meals tell the user
            Text("No meals listed for today",textAlign: TextAlign.center,) 
            : 
            // Else display meal list
            ListView.builder(
              itemCount: _meals.length,
              padding: EdgeInsets.all(0),
              itemBuilder: (context,index){
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Theme.of(context).unselectedWidgetColor
                  ),
                  child: ExpansionTile(
                    title: Text("${_meals[index].name} : ${_meals[index].weight.toString()}g",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),),
                    childrenPadding: EdgeInsets.all(8),
                    children: [
                        Column(
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
                        
                      )
                    ],
                  )
                );
                
                
              }
            )
            )
          ))
        ],
      )
    );
  }
}