import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> saveUserSession(String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    await prefs.setString('userRole', role);
    await prefs.setBool('isLoggedIn', true);
  }

  // For getting User Session
  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    String? role = prefs.getString('userRole');
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && email != null && role != null) {
      return {'email': email, 'role': role};
    }
    return {};
  }

  // For clearing session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
