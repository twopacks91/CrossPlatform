import 'package:flutter/material.dart';

// A snackbar that elevates the child by 20 pixels
// Used to clear the fixed circle from ConvexAppBar
class MySnackBar extends SnackBar{

  MySnackBar({super.key, required Widget content, required super.duration}) : 
    super(
      content: Column(
        children: [
          content,
          const SizedBox(
            height: 20,
          )
        ],
      )
    );

}