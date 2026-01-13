import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/theme_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart'; // Import SearchedDeviceProvider
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // MultiProvider allows you to stack all your state management classes
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SearchedDeviceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen specifically to theme changes for the MaterialApp setup
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GPS Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
