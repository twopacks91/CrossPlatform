import 'package:flutter/material.dart';

class Barcodescanner extends StatefulWidget{
  const Barcodescanner({super.key});

  @override
  State<Barcodescanner> createState() =>  _BarcodeScannerState();
}

class _BarcodeScannerState extends State<Barcodescanner>
{
  @override
  Widget build(BuildContext context)
  {
    return const Scaffold(
      body: Text("Unimplemented",textAlign: TextAlign.center,),
    );
  }
}