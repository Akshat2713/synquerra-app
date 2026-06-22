// lib/presentation/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:synquerra/presentation/screens/modes/modes_screen.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/entities/device/device_entity.dart';
import '../blocs/alerts_errors/alerts_errors_bloc.dart';
import '../blocs/geofence/geofence_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../blocs/home_detail/home_detail_bloc.dart';
import '../blocs/modes/mode_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/signup/signup_bloc.dart';
import '../screens/alerts_errors/alerts_errors_screen.dart';
import '../screens/auth/signup_link_device_screen.dart';
import '../screens/auth/signup_password_setup_screen.dart';
import '../screens/auth/signup_profile_screen.dart';
import '../screens/geofence/add_geofence_page.dart';
import '../screens/geofence/geofence_list_page.dart';
import '../screens/home_detail/home_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/device_list/device_list_screen.dart';
import '../screens/device_detail/device_detail_screen.dart';
import '../screens/telemetry_history/telemetry_history_screen.dart';

// ── Route names ───────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String deviceDetail = '/device-detail';
  static const String telemetryHistory = '/telemetry-history';
  static const String alertCodes = '/alert-codes';
  static const String alertsErrors = '/alerts-errors';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String geofence = '/geofence';
  static const String addGeofence = '/addFeofence';
  static const String modes = '/modes';
  static const String homeDetail = '/home-detail';
  static const String signupProfile = '/signup-profile';
  static const String signupCredentials = '/signup-credentials';
  static const String signupDevice = '/signup-device';
}

// ── Router ────────────────────────────────────────────────────────────────────

class AppRouter {
  AppRouter._();
  static SignupBloc? _activeSignupBloc;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(settings, const SplashScreen());

      case AppRoutes.login:
        _activeSignupBloc = null;
        return _fade(settings, const LoginScreen());

      case AppRoutes.home:
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<HomeBloc>(),
            child: const DeviceListScreen(),
          ),
        );

      case AppRoutes.deviceDetail:
        final device = settings.arguments as DeviceEntity;
        return _slide(
          settings,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<AnalyticsBloc>()),
              BlocProvider(create: (_) => sl<GeofenceBloc>()),
            ],
            child: DeviceDetailScreen(device: device),
          ),
        );

      // Push with:
      //   Navigator.pushNamed(context, AppRoutes.telemetryHistory,
      //       arguments: device);
      case AppRoutes.telemetryHistory:
        final device = settings.arguments as DeviceEntity;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<AnalyticsBloc>(),
            child: TelemetryHistoryScreen(device: device),
          ),
        );

      // Push with:
      //   Navigator.pushNamed(context, AppRoutes.alertsErrors,
      //       arguments: imei);
      case AppRoutes.alertsErrors:
        final imei = settings.arguments as String;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<AlertsErrorsBloc>(),
            child: AlertsErrorsScreen(imei: imei),
          ),
        );

      // Push with:
      //   Navigator.pushNamed(context, AppRoutes.profile,
      //       arguments: imei);
      case AppRoutes.profile:
        final args = settings.arguments as Map<String, dynamic>;
        final device = args['device'] as DeviceEntity;
        final analytics = args['analytics'] as AnalyticsEntity?;
        final analyticsBloc = args['analyticsBloc'] as AnalyticsBloc;
        return _slide(
          settings,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<ProfileBloc>()),
              BlocProvider.value(value: analyticsBloc),
            ],
            child: ProfileScreen(device: device, analytics: analytics),
          ),
        );

      case AppRoutes.settings:
        final args = settings.arguments as Map<String, dynamic>;
        final imei = args['imei'] as String;
        final center = args['center'] as LatLng;
        return _slide(
          settings,
          SettingsScreen(imei: imei, initialCenter: center),
        );

      case AppRoutes.geofence:
        final args = settings.arguments as Map<String, dynamic>;
        final imei = args['imei'] as String;
        final center = args['center'] as LatLng;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<GeofenceBloc>(),
            child: GeofenceListPage(imei: imei, initialCenter: center),
          ),
        );

      case AppRoutes.addGeofence:
        final args = settings.arguments as Map<String, dynamic>;
        final imei = args['imei'] as String;
        final center = args['center'] as LatLng;
        return _slide(
          settings,
          // No BlocProvider here — inherits from GeofenceListPage's route?
          // NO — new route = new scope. Must provide again.
          BlocProvider(
            create: (_) => sl<GeofenceBloc>(),
            child: AddGeofencePage(imei: imei, initialCenter: center),
          ),
        );

      case AppRoutes.modes:
        final args = settings.arguments as Map<String, dynamic>;
        final imei = args['imei'] as String;
        final currentModeName = args['currentModeName'] as String;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<ModeBloc>(),
            child: ModesScreen(imei: imei, currentModeName: currentModeName),
          ),
        );

      case AppRoutes.homeDetail:
        return _slide(
          settings,
          BlocProvider(
            create: (_) =>
                sl<HomeDetailBloc>()..add(const HomeDetailLoadRequested()),
            child: const HomeDetailScreen(),
          ),
        );

      case AppRoutes.signupProfile:
        _activeSignupBloc = sl<SignupBloc>()
          ..add(const SignupProgressRestored());
        return _fade(
          settings,
          BlocProvider.value(
            value: _activeSignupBloc!,
            child: const SignupProfileScreen(),
          ),
        );

      // ── ADD this helper to AppRouter class ──
      //  SignupBloc? _signupBloc;

      case AppRoutes.signupCredentials:
        return _fade(
          settings,
          BlocProvider.value(
            value: _activeSignupBloc!, // reuse same instance from sl
            child: const SignupPasswordSetupScreen(),
          ),
        );

      case AppRoutes.signupDevice:
        return _fade(
          settings,
          BlocProvider.value(
            value: _activeSignupBloc!, // reuse same instance from sl
            child: const SignupLinkDeviceScreen(),
          ),
        );
      default:
        return _fade(
          settings,
          const Scaffold(body: Center(child: Text('404 — Route not found'))),
        );
    }
  }

  // ── Transition helpers ──────────────────────────────────────────────────────

  /// Standard slide-up for main content screens.
  static MaterialPageRoute<dynamic> _slide(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }

  /// Fade for auth / splash (no back-stack feel).
  static PageRouteBuilder<dynamic> _fade(RouteSettings settings, Widget child) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
