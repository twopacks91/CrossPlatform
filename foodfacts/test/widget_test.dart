// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodfacts/MyWidgets/GoalProgressCircle.dart';


void main() {
  testWidgets("Progress circle overruns when progress>1", (tester) async {

    // Create testing environment for progress circle
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          // Progress set to 1.2 to make cicle overrun
          body: GoalProgressCircle(diameter: 100, progress: 1.2, child: Text("Test"))
        )
      )
    );
    
    // Get references to the circular progress indicators (CPIs) inside the progress circle
    final cPIs = tester.widgetList<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).toList();

    // Ensure that the value of the red CPI has been set to a non zero value
    expect(cPIs[2].value, greaterThan(0));
  });

  testWidgets("Progress circle doesnt overrun when progress<1", (tester) async {

    // Create testing environment for progress circle
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          // Progress set to 0.8 to make cicle not overrun
          body: GoalProgressCircle(diameter: 100, progress: 0.8, child: Text("Test"))
        )
      )
    );
    
    // Get references to the circular progress indicators (CPIs) inside the progress circle
    final cPIs = tester.widgetList<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).toList();

    // Ensure that the value of the red CPI has been set to a value less than zero
    expect(cPIs[2].value, lessThanOrEqualTo(0));
  });
}
