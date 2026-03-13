import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/core/services/update_device_service.dart';
import 'package:synquerra/providers/intervals_provider.dart';
import 'package:synquerra/providers/theme_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/theme/app_theme.dart';
import 'package:synquerra/core/services/base_api_service.dart';
import 'package:synquerra/core/services/device_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // 1. Independent Core Providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => IntervalsProvider()),

        // 2. Service Layer: Injects token from UserProvider into DeviceService
        // Whenever UserProvider updates (login/logout), this service recreates with the right token
        ProxyProvider<UserProvider, DeviceService>(
          update: (_, userProv, __) {
            final String? token = userProv.user?.accessToken;
            return DeviceService(BaseApiService(token));
          },
        ),

        // 3. Logic Layer: The Consolidated DeviceProvider
        // We use ProxyProvider2 because it needs BOTH the User (for IMEI) and Service (for API calls)
        ChangeNotifierProxyProvider2<
          UserProvider,
          DeviceService,
          DeviceProvider
        >(
          create: (context) => DeviceProvider(context.read<DeviceService>()),
          update: (_, userProv, deviceService, deviceProv) {
            // Precise Logic: Auto-trigger refresh ONLY when a valid IMEI exists
            final imei = userProv.user?.imei;
            if (imei != null && imei.isNotEmpty) {
              // This is safe because refreshMyDevice has internal guard clauses
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
    // Optimization: Using context.select to only rebuild if themeMode changes
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.themeMode,
    );

    return MaterialApp(
      title: 'GPS Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}
