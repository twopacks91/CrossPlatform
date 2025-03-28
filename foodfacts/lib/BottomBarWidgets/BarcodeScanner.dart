import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Barcodescanner extends StatefulWidget{
  const Barcodescanner({super.key});

  @override
  State<Barcodescanner> createState() =>  _BarcodeScannerState();
}

class _BarcodeScannerState extends State<Barcodescanner>
{
  bool _showScanner = true;
  String _scannedBarcode = "";

  //Future<void> scanBarcode() async
  //{
  //  String result = "";
  //  try{
  //    result = await FlutterBarcodeScanner.scanBarcode(
  //      Theme.of(context).highlightColor.toString(), 
  //      "Cancel", 
  //      false, 
  //      ScanMode.BARCODE);
  //    
  //    setState(() {
  //      _scannedBarcode = result;
  //      _showScanner = false;
  //    });
  //  }
  //  catch (ex){
  //    setState(() {
  //      _scannedBarcode = "Fail";
  //      _showScanner = false;
  //    });
  //  }
  //}

  Widget scanScreen(){
    //scanBarcode();
    return Center(
      
      child: Text("Unimplemented",textAlign: TextAlign.center));
  }

  Widget foodScreen()
  {
    return Center(
      child: Text(_scannedBarcode,textAlign: TextAlign.center,));
  }

  @override
  Widget build(BuildContext context)
  {
    return (_showScanner?scanScreen():foodScreen());
  }
}