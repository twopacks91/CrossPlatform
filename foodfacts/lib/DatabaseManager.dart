import 'package:shared_preferences/shared_preferences.dart';


class DatabaseManager {

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('isDarkMode');
    if(darkMode==null) {
      setDarkMode(false);
      return false;
    }
    else {
      return darkMode;
    }
  }

  // Non static method for use in testing
  Future<int> getCarbsGoalTest() async {
    final prefs = await SharedPreferences.getInstance();
    int? goal = prefs.getInt('carbsGoal');
    if(goal==null){
      setCarbsGoalTest(260);
      return 260; 
    }
    return goal;
  }

  // Non static method for use in testing
  Future<void> setCarbsGoalTest(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('carbsGoal', goal);
  }
  
  
  static Future<void> setDarkMode(bool set) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', set);
  }

  static Future<int> getCarbsGoal() async {
    final prefs = await SharedPreferences.getInstance();
    int? goal = prefs.getInt('carbsGoal');
    if(goal==null){
      setCarbsGoal(260);
      return 260;
    }
    return goal;
  }

  static Future<int> getProteinGoal() async {
    final prefs = await SharedPreferences.getInstance();
    int? goal = prefs.getInt('proteinGoal');
    if(goal==null){
      setProteinGoal(56);
      return 56;
    }
    return goal;
  }

  static Future<int> getFatGoal() async {
    final prefs = await SharedPreferences.getInstance();
    int? goal = prefs.getInt('fatGoal');
    if(goal==null){
      setFatGoal(70);
      return 70;
    }
    return goal;
  }

  static Future<int> getSaltGoal() async {
    final prefs = await SharedPreferences.getInstance();
    int? goal = prefs.getInt('saltGoal');
    if(goal==null){
      setSaltGoal(6);
      return 6;
    }
    return goal;
  }

  

  static Future<void> setCarbsGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('carbsGoal', goal);
  }

  static Future<void> setProteinGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('proteinGoal', goal);
  }

  static Future<void> setFatGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('fatGoal', goal);
  }

  static Future<void> setSaltGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('saltGoal', goal);
  }
}