// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../Food.dart';
import 'package:http/http.dart' as http;


class Barcodescanner extends StatefulWidget{
  const Barcodescanner({super.key});

  @override
  State<Barcodescanner> createState() =>  _BarcodeScannerState();
}

class _BarcodeScannerState extends State<Barcodescanner>
{
  bool _showFoodInfo = false;
  bool _showError = false;
  String _errorMessage = ":(";
  String _scannedBarcode = "";
  late Food _scannedFood;
  final TextEditingController _weightEntryController = TextEditingController();
  
  Future<void> scanBarcode() async
  {
    String? result;
    
    result = await SimpleBarcodeScanner.scanBarcode(
    context,
    scanFormat: ScanFormat.ONLY_BARCODE,
    //lineColor: Theme.of(context).highlightColor.toString()
    );
    if(result==(-1).toString())
    {
      setState(() {
        _showError = true;
        _errorMessage = "Exited barcode scan";
      });
    }
    else if(result != null)
    {
      setState(() {
        _scannedBarcode = result!;
        _showError = false;
      });
      await fetchFood();
    }
  }

  void showError(String message)
  {
    setState(() {
      _showError = true;
      _errorMessage = message;
    });
    
  }

  Future<void> fetchFood() async {
    final uri = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$_scannedBarcode&json=true');
    final resp;
    try{
      resp = await http.get(uri);
    }
    catch(ex){
      showError("You must be connected to the internet to use the barcode scanner");
      return;
    }
    
    final jsondata = json.decode(resp.body);
    final product = jsondata["product"];
    if(product==null)
    {
      showError("Failed to find the product you were looking for :(");
      return;
    }
    final nutriments = product["nutriments"];
    final String? name = product["product_name"];
        final String? imageUrl = product['image_url'];
        final String? barcode = product['code'];
        
        
        final double? calories = (nutriments['energy_value'])?.toDouble();
        final double? carbs = (nutriments['carbohydrates_value'])?.toDouble();
        final double? protein = (nutriments['proteins'])?.toDouble();
        final double? salt = (nutriments['salt_100g'])?.toDouble();
        final double? fat = (nutriments['fat_value'])?.toDouble();

        if (name != null && 
        imageUrl != null && 
        barcode != null &&
        calories != null &&
        carbs != null &&
        protein != null &&
        salt != null &&
        fat != null
        ) 
        {
          setState(() {
            _scannedFood = Food(name, imageUrl, barcode, calories, carbs, protein, salt, fat);
            _showFoodInfo = true;
          });
        }
        else
        {
          showError("The information on this product is too limited to display");
        }

  }

  Future<bool> isSelectedItemFavourited() async
  {
    List<String> favedBarcodes = [];
    await FirebaseFirestore.instance.collection("favfoods").get().then((collection){
      for (dynamic doc in collection.docs){
        favedBarcodes.add(doc.id);
      }
    });
    if(favedBarcodes.contains(_scannedBarcode)) { 
      return true;
    }
    else
    {
      return false;
    }
  }

  void decreaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text=="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) - 10;
      if(newWeight<=0)
      {
        _weightEntryController.text = "0";
      }
      else
      {
        _weightEntryController.text = newWeight.toString();
      }
      
    });
  }

  void increaseWeight()
  {
    if(_weightEntryController.text=="")
    {
      _weightEntryController.text="0";
    }
    setState(() {
      int newWeight = int.parse(_weightEntryController.text) + 10;
      _weightEntryController.text = newWeight.toString();
    });
  }


  void addMealToDB() async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    Food food = _scannedFood;
    food.timeAdded = timeStamp;
    String docName = food.barcode + timeStamp.toString();
    double weight = int.parse(_weightEntryController.text).toDouble();
    if(weight>0)
    {
      food.weight = weight;
      await FirebaseFirestore.instance.collection("meals").doc(docName).set(food.asMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meal added"),duration: Duration(seconds: 2),));
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a meal weight before adding"),duration: Duration(seconds: 2),));
    }
  }

  void addFoodToFavourites() async
  {
    Food food = _scannedFood;
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).set(food.asMap());
    setState(() {
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Food added to favourites list"),duration: Duration(seconds: 2),));
  }

  void removeFoodFromFavourites() async
  {
    setState(() {
    });
    Food food = _scannedFood;
    await FirebaseFirestore.instance.collection("favfoods").doc(food.barcode).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Food removed from favourites list"),duration: Duration(seconds: 2),));
  }

  Scaffold foodInfoScreen()
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20,),
            SizedBox(
              height: 200,
              child: Image.network(
                _scannedFood.imageUrl,
                fit: BoxFit.fill,
              )
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: decreaseWeight,
                    child: Text('-',style: Theme.of(context).textTheme.bodyLarge,)
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      hintStyle: Theme.of(context).textTheme.bodyLarge,
                      filled:true,
                      fillColor: Theme.of(context).primaryColor,
                      border: OutlineInputBorder(),
                    ),
                  controller: _weightEntryController,
                  textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8,),
                SizedBox(
                  width: 50,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: increaseWeight,
                    child: Text('+',style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox(),),
            Container(
              padding: EdgeInsets.all(12),
              width: 420,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).highlightColor),
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  
                  Text("Calories: ${_scannedFood.calories}kcal",style: TextStyle(fontSize: 20)),
                  Text("Carbs   : ${_scannedFood.carbs}g",style: TextStyle(fontSize: 20)),
                  Text("Protein : ${_scannedFood.protein}g",style: TextStyle(fontSize: 20)),
                  Text("Salt    : ${_scannedFood.salt}g",style: TextStyle(fontSize: 20)),
                  Text("Fat     : ${_scannedFood.fat}g",style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: scanBarcode,
                    child: Text('Rescan',style: Theme.of(context).textTheme.bodyMedium)
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child:OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: addMealToDB,
                    child: Text('Confirm meal',style: Theme.of(context).textTheme.bodyMedium)
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: FutureBuilder(future: isSelectedItemFavourited(), builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.done)
                    {
                      bool isFavourited = snapshot.data ?? false;
                      return (isFavourited?
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: removeFoodFromFavourites,
                          child: Text('Remove favourites',style: Theme.of(context).textTheme.bodyMedium)
                        )
                      :
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: addFoodToFavourites,
                          child: Text('Add to favourites',style: Theme.of(context).textTheme.bodyMedium)
                        )
                      );
                    }
                    else
                    {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                          onPressed: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Still talking with database, try again later"),duration: Duration(seconds: 2),));},
                          child: Text('Add to favourites',style: Theme.of(context).textTheme.bodyMedium)
                        );
                    }
                  })
                  )
              ],
            ),
            SizedBox(height: 20,)
          ],
        ),
      )
    );
  }


  Widget errorScreen()
  {
    return Center(
      child: Container(
        padding: EdgeInsets.all(12),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).highlightColor),
          color: Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(_errorMessage),
              OutlinedButton(
                child: Text("Retry scan",style: Theme.of(context).textTheme.bodyLarge,),
                onPressed: scanBarcode,
              )
            ],
          ),
        ),
      )
    );
  }

  Widget currentScreen(){
    if(!_showFoodInfo && !_showError)
    {
      return SizedBox();
    }
    else if(_showFoodInfo && !_showError)
    {
      return foodInfoScreen();
    }
    else
    {
      return errorScreen();
    }
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((x){scanBarcode();});
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: currentScreen()
    );
    
  }
}