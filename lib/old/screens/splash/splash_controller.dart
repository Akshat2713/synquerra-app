import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/old/providers/user_provider.dart';

class SplashController {
  final UserProvider _userProvider;
  final VoidCallback onAuthenticated;
  final VoidCallback onUnauthenticated;

  SplashController({
    required UserProvider userProvider,
    required this.onAuthenticated,
    required this.onUnauthenticated,
  }) : _userProvider = userProvider;

  Future<void> checkLoginStatus() async {
    debugPrint("--- [SPLASH CONTROLLER] Checking login status ---");

    try {
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _userProvider.initUser(),
      ]);

      if (_userProvider.user != null) {
        onAuthenticated();
      } else {
        onUnauthenticated();
      }
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
      onUnauthenticated();
    }
  }

  void dispose() {
    // Clean up if needed
  }
}
