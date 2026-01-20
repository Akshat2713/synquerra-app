import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/preferences/user_preferences.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;
  bool _isInitialized = false;

  // Getters to access data from any UI screen
  UserData? get user => _user;
  bool get isInitialized => _isInitialized;

  /// Structural Fix: Loads UserData from SharedPreferences into RAM exactly once.
  /// This prevents the repetitive JSON parsing seen in debug logs.
  Future<void> initUser() async {
    // Optimization: If already in memory, don't hit the disk again
    if (_isInitialized) return;

    debugPrint("--- [USER PROVIDER] Initializing User Session ---");
    try {
      _user = await UserPreferences().getUser();
      _isInitialized = true;

      if (_user != null) {
        debugPrint(
          "--- [USER PROVIDER] User Loaded: ${_user!.firstName} (IMEI: ${_user!.imei}) ---",
        );
      } else {
        debugPrint("--- [USER PROVIDER] No user found in storage ---");
      }
    } catch (e) {
      debugPrint("--- [USER PROVIDER] Initialization Error: $e ---");
    } finally {
      notifyListeners(); // Updates the MapScreen and other listeners
    }
  }

  /// Updates the user data in memory and on disk simultaneously
  Future<void> updateUser(UserData newUser) async {
    _user = newUser;
    await UserPreferences().saveUser(newUser);
    notifyListeners();
  }

  /// Clears user data on logout to ensure data integrity
  Future<void> logout() async {
    _user = null;
    _isInitialized = false;
    await UserPreferences().removeUser();
    notifyListeners();
  }
}
