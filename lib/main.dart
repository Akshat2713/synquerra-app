// New App

// lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'di/injection_container.dart' as di;
// import 'presentation/app/my_app.dart';
// import 'data/network/ssl_config.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Configure SSL for development (if needed)
//   SslConfig.configureSsl();

//   // Initialize Firebase
//   await Firebase.initializeApp();

//   // Initialize dependency injection - THIS MUST BE CALLED
//   await di.initializeDependencies();

//   runApp(const MyApp());
// }

// Old App

import 'dart:io'; // 1. ADDED THIS IMPORT
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/old/core/services/update_device_service.dart';
import 'package:synquerra/old/providers/intervals_provider.dart';
import 'package:synquerra/old/providers/theme_provider.dart';
import 'package:synquerra/old/providers/device_provider.dart';
import 'package:synquerra/old/providers/searched_device_provider.dart';
import 'package:synquerra/old/providers/user_provider.dart';
import 'package:synquerra/old/theme/app_theme.dart';
import 'package:synquerra/old/core/services/base_api_service.dart';
import 'package:synquerra/old/core/services/device_service.dart';
import 'package:synquerra/old/screens/splash/splash_screen.dart';

// 2. ADD THIS CLASS TO BYPASS SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. APPLY THE OVERRIDE HERE
  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // 1. Independent Core Providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => IntervalsProvider()),

        // 2. Service Layer: Injects token from UserProvider into DeviceService
        ProxyProvider<UserProvider, DeviceService>(
          update: (_, userProv, __) {
            final String? token = userProv.user?.accessToken;
            return DeviceService(BaseApiService(token));
          },
        ),

        // 3. Logic Layer: The Consolidated DeviceProvider
        ChangeNotifierProxyProvider2<
          UserProvider,
          DeviceService,
          DeviceProvider
        >(
          create: (context) => DeviceProvider(context.read<DeviceService>()),
          update: (_, userProv, deviceService, deviceProv) {
            final imei = userProv.user?.imei;
            if (imei != null && imei.isNotEmpty) {
              deviceProv!.refreshMyDevice(imei);
            }
            return deviceProv!;
          },
        ),

        // 4. Secondary Providers: Reusing the DeviceService
        ChangeNotifierProxyProvider<DeviceService, SearchedDeviceProvider>(
          create: (context) =>
              SearchedDeviceProvider(context.read<DeviceService>()),
          update: (_, service, previous) =>
              previous ?? SearchedDeviceProvider(service),
        ),

        ProxyProvider<UserProvider, UpdateDeviceService>(
          update: (_, userProv, __) =>
              UpdateDeviceService(BaseApiService(userProv.user?.accessToken)),
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
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.themeMode,
    );

    return MaterialApp(
      title: 'GPS Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
