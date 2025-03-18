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
    return const Scaffold(
      body: Text(
      'Index 3: Settings',
      ),
    );
  }
}