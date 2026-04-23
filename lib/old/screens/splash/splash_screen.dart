import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/old/screens/splash/splash_controller.dart';
import 'package:synquerra/old/providers/user_provider.dart';
import 'package:synquerra/old/screens/landing/map_screen.dart';
import 'package:synquerra/old/screens/registration/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeNavigation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  void _initializeNavigation() {
    _controller = SplashController(
      userProvider: context.read<UserProvider>(),
      onAuthenticated: _navigateToMap,
      onUnauthenticated: _navigateToLogin,
    );

    _controller.checkLoginStatus();
  }

  void _navigateToMap() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
