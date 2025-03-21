// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget
{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState()=> _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
{
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExpansionTile(
            title: Text("eoptio"),
            children: [
              Text("heheh")
            ],
            
          )
        ],
      )
      );
  }
}