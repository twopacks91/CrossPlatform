import 'package:flutter_test/flutter_test.dart';
import 'package:foodfacts/DatabaseManager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'unit_test.mocks.dart';

//https://docs.flutter.dev/cookbook/testing/unit/mocking

@GenerateMocks([SharedPreferences])

void main(){

  test('DBM assigns default goals when none present', () async {
    // Arrange
    int defaultValue = 260;
    final mockSharedPrefs =  MockSharedPreferences();
    final database = _DatabaseWatcher();
    when(mockSharedPrefs.getInt('carbsGoal')).thenReturn(null); // Simulates user having no saved carb goal
    when(mockSharedPrefs.setInt('carbsGoal', defaultValue)).thenAnswer((_) async => true);
    SharedPreferences.setMockInitialValues({});
    
    // Act
    final result = await database.getCarbsGoalTest();

    // Assert
    expect(result,equals(defaultValue)); // Returns expected value
    expect(database.called(),equals(defaultValue)); // Verify the database made a call to set the carbs goal to the default
  });
  
}


class _DatabaseWatcher extends DatabaseManager{
  int param = -1;

  @override
  Future<void> setCarbsGoalTest(int c) async {
    param = c;
    return;
  }

  int called(){
    return param;
  }
}
