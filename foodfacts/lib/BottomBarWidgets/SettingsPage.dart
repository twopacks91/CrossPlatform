// ignore_for_file: prefer_const_constructors
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

  //Future<void> loadGoals() async {
  //  dynamic settings = await SharedPreferences.getInstance();
  //  _carbsGoalController.text = settings.getInt('carbsGoal') ?? 0;
  //  _proteinGoalController.text = settings.getInt('proteinGoal') ?? 0;
  //  _saltGoalController.text = settings.getInt('saltGoal') ?? 0;
  //  _fatGoalController.text = settings.getInt('fatGoal') ?? 0;
  //}

  //Future<void> saveCarbsGoal() async {
  //  if(int.tryParse(_carbsGoalController.text)==null) {
  //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a value for carbs goal before saving"),duration: Duration(seconds: 2) ));
  //  }
  //  else{
  //    dynamic settings = await SharedPreferences.getInstance();
  //    await settings.setInt('carbsGoal', _carbsGoalController.text);
  //  }
  //}
//
  //Future<void> saveProteinGoal() async {
  //  if(int.tryParse(_proteinGoalController.text)==null) {
  //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a value for protein goal before saving"),duration: Duration(seconds: 2) ));
  //  }
  //  else{
  //    dynamic settings = await SharedPreferences.getInstance();
  //    await settings.setInt('proteinGoal', _proteinGoalController.text);
  //  }
  //}
//
  //Future<void> saveSaltGoal() async {
  //  if(int.tryParse(_saltGoalController.text)==null) {
  //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a value for salt goal before saving"),duration: Duration(seconds: 2) ));
  //  }
  //  else{
  //    dynamic settings = await SharedPreferences.getInstance();
  //    await settings.setInt('saltGoal', _saltGoalController.text);
  //  }
  //}
//
  //Future<void> saveFatGoal() async {
  //  if(int.tryParse(_fatGoalController.text)==null) {
  //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a value for fat goal before saving"),duration: Duration(seconds: 2) ));
  //  }
  //  else{
  //    dynamic settings = await SharedPreferences.getInstance();
  //    await settings.setInt('fatGoal', _fatGoalController.text);
  //  }
  //}

  @override
  void initState()
  {
    super.initState();
    //loadGoals();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExpansionTile(
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
                      border: OutlineInputBorder()
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
                      suffixIcon:OutlinedButton(onPressed: (){}, 
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
                      border: OutlineInputBorder()
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
                      border: OutlineInputBorder()
                    ),
                  ),
                  ),
                ],
              )
            ],
            
          )
        ],
      )
      );
  }
}