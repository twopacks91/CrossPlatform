// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodfacts/DatabaseManager.dart';
import 'package:foodfacts/main.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal removed",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2),));
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

  Widget mealsList(){
    return ListView.builder(
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
                    child: OutlinedButton(
                      onPressed: ()=>{removeMeal(_meals[index])}, 
                      child: Text("Remove meal",style: Theme.of(context).textTheme.bodyLarge)
                    ),
                  )
                ]
              )
            ],
          )
        );
      }
    );
  }
  
  Widget mealHistoryTab(){
    return Container(
      decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).highlightColor),
        color: Theme.of(context).primaryColor,
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
            child: FutureBuilder(future: isConnectedToInternet(), builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.data == true){
                  return mealsList();
                }
                else {
                  return Center(
                    child: Text("Not connected to internet",style: Theme.of(context).textTheme.bodyMedium,),
                  );
                }
              }
              else{
                return Shimmer.fromColors(
                  baseColor: Theme.of(context).primaryColor, 
                  highlightColor: Theme.of(context).unselectedWidgetColor,
                  child: mealsList(),
                );
              }
            })
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the carbs goal textbox",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setCarbsGoal(int.parse(_carbsGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Carbohydrate goal updated",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setProteinGoal() async {
    if(int.tryParse(_proteinGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the protein goal textbox",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setProteinGoal(int.parse(_proteinGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Protein goal updated",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setSaltGoal() async {
    if(int.tryParse(_saltGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the salt goal textbox",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setSaltGoal(int.parse(_saltGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salt goal updated",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setFatGoal() async {
    if(int.tryParse(_fatGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the fat goal textbox",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
    else {
      await DatabaseManager.setFatGoal(int.parse(_fatGoalController.text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fat goal updated",style: Theme.of(context).textTheme.bodyMedium),duration: Duration(seconds: 2)));
    }
  }


  Widget goal(String header, TextEditingController controller, Function() updateGoal){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(header),
        SizedBox(height: 5,),
        SizedBox(
          width: 400,
          height: 40,
          child: TextField(
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).unselectedWidgetColor,
              border: OutlineInputBorder(),
              suffixIcon:OutlinedButton(
                onPressed: updateGoal,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).textTheme.bodyLarge!.color!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  backgroundColor: Theme.of(context).highlightColor.withOpacity(0.3)
                ), 
                child: Icon(Icons.check,color: Theme.of(context).textTheme.bodyLarge!.color!,)
              )
            ),
          ),
        ),
      ],
    );
    
  }

  Widget goalsTab()
  {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).highlightColor),
        color: Theme.of(context).primaryColor,
      ),
      child: ExpansionTile(
        childrenPadding: EdgeInsets.all(8),
        title: Text("Goals",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
        children: [
          SizedBox(height: 8,),
          goal("Carbs goal (g) :", _carbsGoalController, setCarbsGoal),
          SizedBox(height: 8,),
          goal("Protein goal (g) :", _proteinGoalController, setProteinGoal),
          SizedBox(height: 8,),
          goal("Fat goal (g) :", _fatGoalController, setFatGoal),
          SizedBox(height: 8,),
          goal("Salt goal (g) :", _saltGoalController, setSaltGoal)
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
      border: Border.all(color: Theme.of(context).highlightColor),
        color: Theme.of(context).primaryColor,
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