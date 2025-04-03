import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


// Image.network with better internet error handling
class InternetImage extends StatelessWidget{
  final String url;
  final double height;

  const InternetImage({super.key,required this.url, required this.height});

  Future<bool> isConnectedToInternet() async{
    try{
      // ignore: unused_local_variable
      dynamic resp = await http.get(Uri.parse("https://example.com/api/fetch?limit=10,20,30&max=100"));
      return true;
    }
    catch(ex){
      return false;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: isConnectedToInternet(), builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.done){
        if(snapshot.data==false){
          return Image(
            image: const AssetImage('assets/nointernet.png'),
            height: height,
            fit: BoxFit.fill,
          );
        }
        else{
          return Image.network(
            url,
            height: height,
            fit: BoxFit.fill,
          );
        }
      }
      else{
        return Shimmer.fromColors(
          baseColor: Theme.of(context).primaryColor, 
          highlightColor: Theme.of(context).splashColor,
          child: Container(
            height: height, 
            width: height,
            color: Colors.white,
          )
        );
      }
    });
  }
}