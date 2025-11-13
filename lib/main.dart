import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:safe_track/providers/theme_provider.dart'; // Import your new provider
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
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.navBlue,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          surface: AppColors.backgroundContainer,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 18),
          bodyMedium: TextStyle(color: AppColors.lightText, fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navBlue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),

      // --- NEWLY ADDED DARK THEME ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.navBlue,
        scaffoldBackgroundColor:
            AppColors.backgroundDarkMode, // Dark background
        colorScheme: ColorScheme.dark(
          surface: AppColors.backgroundContainerDark,
          primary: AppColors.navBlue,
          secondary: Colors.blueAccent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navBlue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
          ),
        ),
      ),

      // -----------------------------
      home: const SplashScreen(),
    );
  }
}
