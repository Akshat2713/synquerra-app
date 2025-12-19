import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/screens/registration/login_page.dart';
// 1. ADD THESE IMPORTS
import 'package:synquerra/screens/landing/map_screen.dart';
import '../../core/services/user_preferences.dart';
import '../../core/models/user_model.dart'; // Required to recognize UserData type

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start Animation slightly delayed
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });

    // 2. CALL THE CHECK LOGIC
    _checkLoginStatus();
  }

  // 3. LOGIC TO CHECK USER AND NAVIGATE
  Future<void> _checkLoginStatus() async {
    // We wait for BOTH the 2-second timer (for visual effect)
    // AND the UserPreferences check to complete.
    final List<dynamic> results = await Future.wait([
      Future.delayed(
        const Duration(seconds: 2),
      ), // Ensure logo shows for at least 2s
      UserPreferences().getUser(), // Check local storage
    ]);

    // results[0] is the delay (void)
    // results[1] is the UserData object (or null)
    final UserData? user = results[1];

    if (!mounted) return;

    // 4. DECIDE WHERE TO GO
    if (user != null) {
      // User is logged in -> Go to Map
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } else {
      // User is NOT logged in -> Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.school, size: 100, color: Colors.blue);
            },
          ),
        ),
      ),
    );
  }
}
