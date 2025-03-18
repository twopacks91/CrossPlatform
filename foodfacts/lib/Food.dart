class Food{
  String name;
  String imageUrl;
  String barcode;
  double calories;
  double carbs;
  double protein;
  double salt;
  double fat;
  int? timeAdded;
  double? weight;
  Food(this.name,this.imageUrl,this.barcode,this.calories,this.carbs,this.protein,this.salt,this.fat);

  Map<String,dynamic> asMap() {
    if(timeAdded == null || weight == null) {
      return {
        'name': name,
        'imageUrl': imageUrl,
        'barcode': barcode,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'salt': salt,
        'fat': fat,
      };
    }
    else{
      return {
        'name': name,
        'imageUrl': imageUrl,
        'barcode': barcode,
        'calories': double.parse(((calories/100)*weight!).toStringAsFixed(1)),
        'carbs': double.parse(((carbs/100)*weight!).toStringAsFixed(1)),
        'protein': double.parse(((protein/100)*weight!).toStringAsFixed(1)),
        'salt': double.parse(((salt/100)*weight!).toStringAsFixed(1)),
        'fat': double.parse(((fat/100)*weight!).toStringAsFixed(1)),
        'timeAdded' : timeAdded,
        'weight' : weight,
      };
    }
    
  }
}