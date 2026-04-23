import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserPreferences {
  // Key to store the user data in local storage
  static const String _keyUser = 'user_key';

  // Save User Data
  Future<bool> saveUser(UserData user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the UserData object to a JSON Map, then to a String
    String userJson = jsonEncode(user.toJson());

    // Save the string
    return await prefs.setString(_keyUser, userJson);
  }

  // Get User Data
  Future<UserData?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Try to read the string
    String? userJson = prefs.getString(_keyUser);

    // If no data exists, return null
    if (userJson == null) return null;

    try {
      // Decode the string back to a Map
      Map<String, dynamic> userMap = jsonDecode(userJson);

      // Convert Map back to UserData object
      return UserData.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  // Remove User Data (Logout)
  Future<bool> removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyUser);
  }

  // Helper: Get just the Access Token (Useful for API headers later)
  Future<String> getAccessToken() async {
    final UserData? user = await getUser();
    return user?.accessToken ?? '';
  }
}
