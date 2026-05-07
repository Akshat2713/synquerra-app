import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/device/device_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/device_list/device_list_screen.dart';
import '../screens/device_detail/device_detail_screen.dart';

// ── Route names ───────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String deviceDetail = '/device-detail';
}

// ── Router ────────────────────────────────────────────
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          settings,
          BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const SplashScreen(),
          ),
        );

      case AppRoutes.login:
        return _buildRoute(
          settings,
          BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        );

      case AppRoutes.home:
        return _buildRoute(
          settings,
          BlocProvider(
            create: (_) => sl<HomeBloc>(),
            child: const DeviceListScreen(),
          ),
        );

      case AppRoutes.deviceDetail:
        final device = settings.arguments as DeviceEntity;
        return _buildRoute(
          settings,
          BlocProvider(
            create: (_) => sl<AnalyticsBloc>(),
            child: DeviceDetailScreen(device: device),
          ),
        );

      default:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('404 — Route not found'))),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}
