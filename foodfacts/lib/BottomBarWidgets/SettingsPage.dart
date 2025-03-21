// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SettingsPage extends StatefulWidget
{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState()=> _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
{
  final _carbsGoalController = TextEditingController();
  final _proteinGoalController = TextEditingController();
  final _saltGoalController = TextEditingController();
  final _fatGoalController = TextEditingController();

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
                      border: OutlineInputBorder()
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