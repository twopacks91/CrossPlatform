// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodfacts/DatabaseManager.dart';
import 'package:foodfacts/main.dart';
import 'package:intl/intl.dart';
import '../Food.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget
{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState()=> _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
{
  
  //final sharedPrefs = SharedPreferences.getInstance();


  final _carbsGoalController = TextEditingController();
  final _proteinGoalController = TextEditingController();
  final _saltGoalController = TextEditingController();
  final _fatGoalController = TextEditingController();

  List<Food> _meals = [];

  void fetchMeals() async {
    List<Food> newFoods = [];
    await FirebaseFirestore.instance.collection("meals").get().then((collection){
      for (dynamic doc in collection.docs){
        
        dynamic docData = doc.data();
        int timeAdded = docData["timeAdded"];
        String name = docData['name'];
        String imageUrl = docData['imageUrl'];
        String barcode = docData['barcode'];
        double calories = docData["calories"]?.toDouble();
        double carbs = docData["carbs"]?.toDouble();
        double protein = docData["protein"]?.toDouble();
        double salt = docData["salt"]?.toDouble();
        double fat = docData["fat"]?.toDouble();
        double weight = docData["weight"].toDouble();
        Food newFood = Food(name, imageUrl, barcode, calories, carbs, protein, salt, fat);
        newFood.timeAdded = timeAdded;
        newFood.weight = weight;
        newFoods.add(newFood);
      }
    });
    // Sort meals by time added to database
    newFoods.sort((a,b) => b.timeAdded!.compareTo(a.timeAdded!));
    setState(() {
      _meals = newFoods;
    });
  }

  String unixToTimeString(int unix)
  {
    DateTime dt =DateTime.fromMillisecondsSinceEpoch(unix).toLocal();
    return DateFormat('HH:mm dd/mm/yyyy').format(dt);
  }

  void removeMeal(Food meal) async{
    String docName = meal.barcode + meal.timeAdded.toString();
    await FirebaseFirestore.instance.collection("meals").doc(docName).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal removed"),duration: Duration(seconds: 2),));
    fetchMeals();
  }

  Future<bool> isConnectedToInternet() async{
    try{
      dynamic resp = await http.get(Uri.parse("https://example.com/api/fetch?limit=10,20,30&max=100"));
      return true;
    }
    catch(ex){
      return false;
    }
    
  }
  
  Widget mealHistoryTab(){
    return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.all(8),
              title: Text("Meal history",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
              children: [
                Container(
                  width: 420,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: Theme.of(context).highlightColor),
                    color: Theme.of(context).primaryColor
                  ),
                  child:ListView.builder(
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
                                  Text("Calories  : ${_meals[index].calories.round()}kcal"),
                                  Text("Carbs     : ${_meals[index].carbs.round()}g"),
                                  Text("Protein   : ${_meals[index].protein.round()}g"),
                                  Text("Salt      : ${_meals[index].salt.round()}g"),
                                  Text("Fat       : ${_meals[index].fat.round()}g"),
                                  SizedBox(height: 10,),
                                  Center(
                                    child: OutlinedButton(onPressed: ()=>{removeMeal(_meals[index])}, child: Text("Remove meal",style: Theme.of(context).textTheme.bodyLarge)),
                                  )
                                ],

                            )
                          ],
                        )
                      );


                    }
                  )
                )
              ],
            )
          );
  }

  Future<void> getGoals() async {
    int carbs = await DatabaseManager.getCarbsGoal();
    int protein = await DatabaseManager.getProteinGoal();
    int salt = await DatabaseManager.getSaltGoal();
    int fat = await DatabaseManager.getFatGoal();
    setState(() {
      _carbsGoalController.text = carbs.toString();
      _proteinGoalController.text = protein.toString();
      _saltGoalController.text = salt.toString();
      _fatGoalController.text = fat.toString();
    });
  }

  

  Future<void> setCarbsGoal() async {
    if(int.tryParse(_carbsGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the carbs goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setCarbsGoal(int.parse(_carbsGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Carbohydrate goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setProteinGoal() async {
    if(int.tryParse(_proteinGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the protein goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setProteinGoal(int.parse(_proteinGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Protein goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setSaltGoal() async {
    if(int.tryParse(_saltGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the salt goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setSaltGoal(int.parse(_saltGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salt goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setFatGoal() async {
    if(int.tryParse(_fatGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the fat goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setFatGoal(int.parse(_fatGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fat goal updated"),duration: Duration(seconds: 2)));
    }
  }


  Widget goalsTab()
  {
    return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.all(8),
              title: Text("Goals",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Carbs goal (g): "),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: TextField(
                      keyboardType: TextInputType.number,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _carbsGoalController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).primaryColor,
                        hintText: "Enter carbs goal",
                        border: OutlineInputBorder(),
                        suffixIcon:OutlinedButton(onPressed: setCarbsGoal, 
                        child: Icon(Icons.check),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)
                            )
                          )
                        ),
                        )
                      ),
                    ),
                    ),
                    SizedBox(height: 8,),
                    Text("Protein goal (g): "),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _proteinGoalController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).primaryColor,
                        hintText: "Enter protein goal",
                        border: OutlineInputBorder(),
                        suffixIcon:OutlinedButton(onPressed: setProteinGoal, 
                        child: Icon(Icons.check),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)
                            )
                          )
                        ),
                        )
                      ),
                    ),
                    ),
                    SizedBox(height: 8,),
                    Text("Fat goal (g): "),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _fatGoalController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).primaryColor,
                        hintText: "Enter fat goal",
                        border: OutlineInputBorder(),
                        suffixIcon:OutlinedButton(onPressed: setFatGoal, 
                        child: Icon(Icons.check),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)
                            )
                          )
                        ),
                        )
                      ),
                    ),
                    ),
                    SizedBox(height: 8,),
                    Text("Salt goal (g): "),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _saltGoalController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).primaryColor,
                        hintText: "Enter salt goal",
                        border: OutlineInputBorder(),
                        suffixIcon:OutlinedButton(onPressed: setSaltGoal, 
                        child: Icon(Icons.check),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)
                            )
                          )
                        ),
                        )
                      ),
                    ),
                    ),
                  ],
                )
              ],
            )
          );
  }
  
  void toggleDarkMode() async {
    final bool isDarkMode = await DatabaseManager.isDarkMode();
    if(isDarkMode){
      await DatabaseManager.setDarkMode(false);
    }
    else{
      await DatabaseManager.setDarkMode(true);
    }
    // Calls setstate from highest point in the widget tree so rebuild whole app
    // Hence changing the theme
    MyApp.of(context).rebuild();
  }

  Widget customizationTab(){
    return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.all(8),
              title: Text("Customization",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
              children: [
                Row(
                  children: [
                    Text("Use dark mode:"),
                    IconButton(onPressed: toggleDarkMode, icon:
                      FutureBuilder(
                        future: DatabaseManager.isDarkMode(), 
                        builder: (context,snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                            return Icon(Icons.refresh);
                          }
                          else if(snapshot.connectionState==ConnectionState.done){
                            if(snapshot.data==true){
                              return Icon(Icons.toggle_on);
                            }
                            else{
                              return Icon(Icons.toggle_off_outlined);
                            }
                          }
                          else{
                            return Icon(Icons.error);
                          }
                          
                        }
                      )
                    )
                     //IconButton(onPressed: toggleDarkMode, icon: Icon((()?Icons.toggle_on:Icons.toggle_off_outlined)))
                  ],
                )
              ],
            )
          );
  }
  @override
  void initState()
  {
    super.initState();
    getGoals();
    fetchMeals();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text("Settings",style: TextStyle(fontSize: 40),),
          SizedBox(height: 10),
          Expanded(child: 
            SingleChildScrollView(
              child: Column(
                children: [
                  goalsTab(),
                  mealHistoryTab(),
                  customizationTab()
                ]
              )
            )
          )
        ]
      )
    );
  }
}