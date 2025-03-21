// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> getGoals() async {
    dynamic doc = await FirebaseFirestore.instance.collection("settings").doc("goals").get();
    Map<String,dynamic> docData = doc.data() as Map<String,dynamic>;
    int carbs = docData["carbsgoal"];
    int protein = docData["proteingoal"];
    int salt = docData["saltgoal"];
    int fat = docData["fatgoal"];
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
      await FirebaseFirestore.instance.collection("settings").doc("goals").update({ "carbsgoal" : int.parse(_carbsGoalController.text) });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Carbohydrate goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setProteinGoal() async {
    if(int.tryParse(_proteinGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the protein goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await FirebaseFirestore.instance.collection("settings").doc("goals").update({ "proteingoal" : int.parse(_proteinGoalController.text) });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Protein goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setSaltGoal() async {
    if(int.tryParse(_saltGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the salt goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await FirebaseFirestore.instance.collection("settings").doc("goals").update({ "saltgoal" : int.parse(_saltGoalController.text) });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salt goal updated"),duration: Duration(seconds: 2)));
    }
  }

  Future<void> setFatGoal() async {
    if(int.tryParse(_fatGoalController.text)==null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a number in the fat goal textbox"),duration: Duration(seconds: 2)));
    }
    else {
      await FirebaseFirestore.instance.collection("settings").doc("goals").update({ "fatgoal" : int.parse(_fatGoalController.text) });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Carbohydrate goal updated"),duration: Duration(seconds: 2)));
    }
  }

  @override
  void initState()
  {
    super.initState();
    getGoals();
  }

  Widget goalsTab()
  {
    return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.all(8),
              title: Text("Goals"),
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
          goalsTab()
        ],
      )
    );
  }
}