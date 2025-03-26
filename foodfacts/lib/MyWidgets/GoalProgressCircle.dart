import 'package:flutter/material.dart';

class GoalProgressCircle extends StatelessWidget{
  final Widget child;
  final double diameter;
  final double progress;
  
  const GoalProgressCircle({super.key, required this.child,required this.diameter,required this.progress});

  @override
  Widget build(BuildContext context)
  {
    double overrun = progress-1;
    return Center(
      child: 
        Stack(
          children: [
            CircleAvatar(
              radius: (diameter/2),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            SizedBox(
              width: diameter
              ,height: diameter, 
              child: CircularProgressIndicator(
                value: 1,
                color: Theme.of(context).unselectedWidgetColor,
                strokeWidth: 6,
              )
            ),
            SizedBox(
              width: diameter
              ,height: diameter, 
              child: CircularProgressIndicator(
                value: progress,
                color: const Color.fromARGB(255, 179, 255, 92),
                strokeWidth: 6,
              )
            ),
            SizedBox(
              width: diameter
              ,height: diameter, 
              child: CircularProgressIndicator(
                value: overrun,
                color: const Color.fromARGB(255, 255, 0, 0),
                strokeWidth: 6,
              )
            ),
            SizedBox(
              width: diameter,
              height: diameter, 
              child: Center(
                child: Transform.scale(scale: diameter/80,child: child,)
              )
            )
          ],
        )
      );
  }
}
