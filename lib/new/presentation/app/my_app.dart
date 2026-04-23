// lib/presentation/app/my_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../business/blocs/device_bloc/device_bloc.dart';
import '../../business/blocs/searched_device_bloc/searched_device_bloc.dart';
import '../../business/blocs/theme_bloc/theme_bloc.dart';
import '../../business/blocs/device_config_bloc/device_config_bloc.dart';
import '../../business/blocs/navigation_bloc/navigation_bloc.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/map_screen.dart';
import '../themes/app_theme.dart';
import '../../di/injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              di.sl<AuthBloc>()..add(AuthCheckStatusRequested()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>()..add(ThemeLoaded()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => di.sl<NavigationBloc>(),
        ),
        BlocProvider<DeviceBloc>(
          create: (context) => di.sl<DeviceBloc>(),
          lazy: true,
        ),
        BlocProvider<SearchedDeviceBloc>(
          create: (context) => di.sl<SearchedDeviceBloc>(),
          lazy: true,
        ),
        BlocProvider<DeviceConfigBloc>(
          create: (context) =>
              di.sl<DeviceConfigBloc>()..add(DeviceConfigLoaded()),
          lazy: true,
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final themeMode = themeState is ThemeReady
              ? themeState.themeMode
              : ThemeMode.light;

          return MaterialApp(
            title: 'GPS Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/map': (context) => const MapScreen(),
            },
          );
        },
      ),
    );
  }
}
