import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/theme_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/theme/app_theme.dart';
import 'package:synquerra/core/services/base_api_service.dart'; // Ensure these are imported
import 'package:synquerra/core/services/device_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // 1. Core Providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // 2. Logic Layer: Injects token from UserProvider into DeviceService
        ProxyProvider<UserProvider, DeviceService>(
          update: (context, userProv, _) {
            // Get token from RAM (UserProvider), not Disk (Preferences)
            final String? token = userProv.user?.accessToken;
            final apiBase = BaseApiService(token);
            return DeviceService(apiBase);
          },
        ),

        // 3. UI Providers: Depend on the pre-configured DeviceService
        ChangeNotifierProxyProvider<DeviceService, DeviceProvider>(
          create: (context) => DeviceProvider(context.read<DeviceService>()),
          update: (context, service, previous) => DeviceProvider(service),
        ),

        ChangeNotifierProxyProvider<DeviceService, SearchedDeviceProvider>(
          create: (context) =>
              SearchedDeviceProvider(context.read<DeviceService>()),
          update: (context, service, previous) =>
              SearchedDeviceProvider(service),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
