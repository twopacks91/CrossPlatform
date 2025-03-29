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

  static Future<void> setDarkMode(bool set) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', set);
  }
}