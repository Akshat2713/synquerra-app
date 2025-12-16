import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:safe_track/providers/theme_provider.dart'; // Import your new provider
import 'package:safe_track/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'package:safe_track/theme/colors.dart';

void main() {
  // Wrap your app with the provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes from the provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GPS Tracker',
      debugShowCheckedModeBanner: false,

      // Set the theme mode based on the provider's state
      themeMode: themeProvider.themeMode,

      // Your existing light theme
      theme: AppTheme.lightTheme,
      // Your existing dark theme
      darkTheme: AppTheme.darkTheme,

      // -----------------------------
      home: const SplashScreen(),
    );
  }
}
