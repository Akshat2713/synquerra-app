// lib/presentation/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:synquerra/presentation/blocs/alerts/alerts_bloc.dart';
import 'package:synquerra/presentation/screens/modes/modes_screen.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/usecases/base_usecase.dart';
import '../../domain/usecases/signup/get_saved_signup_progress_usecase.dart';
import '../blocs/geofence/geofence_bloc.dart';
import '../blocs/device_list/device_list_bloc.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../blocs/landing/landing_bloc.dart';
import '../blocs/link_device/link_device_bloc.dart';
import '../blocs/modes/mode_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/signup/signup_bloc.dart';
import '../screens/device_list/link_device_screen.dart';
import '../screens/auth/signup_password_setup_screen.dart';
import '../screens/auth/signup_profile_screen.dart';
import '../screens/device_shell/device_shell_screen.dart';
import '../screens/geofence/add_geofence_page.dart';
import '../screens/geofence/geofence_list_page.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/device_list/device_list_screen.dart';

class DeviceDetailArgs {
  final DeviceEntity device;
  final DeviceListBloc deviceListBloc;
  const DeviceDetailArgs({required this.device, required this.deviceListBloc});
}

// ── Route names ───────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String deviceList = '/device-list';
  static const String deviceDetail = '/device-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String geofence = '/geofence';
  static const String addGeofence = '/addFeofence';
  static const String modes = '/modes';
  static const String landing = 'landing';
  static const String signupProfile = '/signup-profile';
  static const String signupCredentials = '/signup-credentials';
  static const String linkDevice = '/link-device';
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

      case AppRoutes.deviceList:
        return _slide(
          settings,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<DeviceListBloc>()),
              BlocProvider(create: (_) => sl<AlertsBloc>()),
            ],
            child: const DeviceListScreen(),
          ),
        );
      // NEW
      // REPLACE (delete the DeviceDetailArgs class I added — not needed)

      // deviceDetail case:
      case AppRoutes.deviceDetail:
        final args = settings.arguments as DeviceDetailArgs;
        return _slide(
          settings,
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: args.deviceListBloc),
              BlocProvider(create: (_) => sl<LandingBloc>()),
              BlocProvider(create: (_) => sl<AnalyticsBloc>()),
              BlocProvider(create: (_) => sl<GeofenceBloc>()),
              // BlocProvider(create: (_) => sl<AlertsErrorsBloc>()),
              BlocProvider(create: (_) => sl<AlertsBloc>()),
            ],
            child: DeviceShellScreen(device: args.device),
          ),
        );

      // Push with:
      //   Navigator.pushNamed(context, AppRoutes.alertsErrors,
      //       arguments: imei);
      // case AppRoutes.alertsErrors:
      //   final deviceId = settings.arguments as String;
      //   return _slide(
      //     settings,
      //     BlocProvider(
      //       create: (_) => sl<AlertsErrorsBloc>(),
      //       child: AlertsErrorsScreen(deviceId: deviceId),
      //     ),
      //   );

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

      case AppRoutes.geofence:
        final args = settings.arguments as Map<String, dynamic>;
        final deviceId = args['deviceId'] as String;
        final center = args['center'] as LatLng;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<GeofenceBloc>(),
            child: GeofenceListPage(deviceId: deviceId, initialCenter: center),
          ),
        );

      case AppRoutes.addGeofence:
        final args = settings.arguments as Map<String, dynamic>;
        final deviceId = args['deviceId'] as String;
        final center = args['center'] as LatLng;
        return _slide(
          settings,
          // No BlocProvider here — inherits from GeofenceListPage's route?
          // NO — new route = new scope. Must provide again.
          BlocProvider(
            create: (_) => sl<GeofenceBloc>(),
            child: AddGeofencePage(deviceId: deviceId, initialCenter: center),
          ),
        );

      case AppRoutes.modes:
        final args = settings.arguments as Map<String, dynamic>;
        final deviceId = args['deviceId'] as String;
        final currentModeName = args['currentModeName'] as String;
        return _slide(
          settings,
          BlocProvider(
            create: (_) => sl<ModeBloc>(),
            child: ModesScreen(
              deviceId: deviceId,
              currentModeName: currentModeName,
            ),
          ),
        );

      // case AppRoutes.homeDetail:
      //   return _slide(
      //     settings,
      //     BlocProvider(
      //       create: (_) => sl<LandingBloc>()..add(const LandingLoadRequested()),
      //       child: const LandingScreen(),
      //     ),
      //   );

      case AppRoutes.signupProfile:
        _activeSignupBloc = sl<SignupBloc>();
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

      case AppRoutes.linkDevice:
        return _fade(
          settings,
          BlocProvider(
            create: (_) => sl<LinkDeviceBloc>(),
            child: const LinkDeviceScreen(),
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

  static Future<void> navigateToSignup(BuildContext context) async {
    _activeSignupBloc = sl<SignupBloc>();

    // Fetch progress via the UseCase / Domain layer
    final getSavedProgressUseCase = sl<GetSavedSignupProgressUseCase>();

    try {
      final result = await getSavedProgressUseCase(NoParams());

      if (!context.mounted) return;

      result.fold(
        (failure) {
          // Fallback on failure
          Navigator.pushNamed(context, AppRoutes.signupProfile);
        },
        (progress) {
          if (progress == null || progress.step == 1) {
            Navigator.pushNamed(context, AppRoutes.signupProfile);
          } else if (progress.step == 2) {
            _activeSignupBloc!.add(SignupProgressRestored());
            Navigator.pushNamed(context, AppRoutes.signupCredentials);
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('AppRouter', 'SIGNUP ROUTING ERROR', e, stackTrace);
      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.signupProfile);
      }
    }
  }
}
