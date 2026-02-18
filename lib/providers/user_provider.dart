import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/preferences/user_preferences.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;
  bool _isInitialized = false;

  // Getters to access data from any UI screen
  UserData? get user => _user;
  bool get isInitialized => _isInitialized;

  String? get accessToken => _user?.accessToken;

  Future<void> initUser() async {
    // Optimization: If already in memory, don't hit the disk again
    if (_isInitialized) return;

    debugPrint("--- [USER PROVIDER] Initializing User Session ---");
    try {
      // _user = await compute(_loadUserInBackground, null);
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
      notifyListeners();
    }
  }

  /// Updates the user data in memory and on disk simultaneously
  Future<void> setUser(UserData newUser) async {
    _user = newUser;
    // _isInitialized = true;
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

// Future<UserData?> _loadUserInBackground(_) async {
//   return await UserPreferences().getUser();
// }
