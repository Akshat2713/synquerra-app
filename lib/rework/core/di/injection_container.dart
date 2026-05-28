import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synquerra/rework/presentation/blocs/theme/theme_cubit.dart';

// Network
import '../../data/datasources/local/theme_local_datasource.dart';
import '../../data/datasources/remote/alerts_errors_remote_datasource.dart';
import '../../data/datasources/remote/geofence_remote_datasource.dart';
import '../../data/network/dio_client.dart';

// Auth
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories_impl/alerts_errors_repository_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/geofence_repository_impl.dart';
import '../../domain/repositories/alerts_errors_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../../domain/usecases/alerts_errors/get_alerts_errors_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/entities/auth/user_entity.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/geofence/get_geofences_usecase.dart';
import '../../presentation/blocs/alerts_errors/alerts_errors_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

// Alerts
import '../../data/datasources/remote/alerts_remote_datasource.dart';
import '../../data/repositories_impl/alerts_repository_impl.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../domain/usecases/alerts/get_alerts_usecase.dart';

// Device
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/repositories_impl/device_repository_impl.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/usecases/device/get_device_list_usecase.dart';

// Analytics
import '../../data/datasources/remote/analytics_remote_datasource.dart';
import '../../data/repositories_impl/analytics_repository_impl.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/usecases/analytics/get_analytics_usecase.dart';

// Blocs
import '../../presentation/blocs/geofence/geofence_bloc.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../presentation/blocs/profile/profile_bloc.dart';

// Wrapper to allow nullable user in get_it
class UserHolder {
  final UserEntity? user;
  const UserHolder(this.user);
}

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // ── Theme ───────────────────────────────────────

  sl.registerLazySingleton(() => ThemeCubit(sl()));

  sl.registerLazySingleton(() => ThemeLocalDataSource(sl()));

  // ── Network ───────────────────────────────────────
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ── User singleton (set after login) ──────────────
  // registered as nullable, replaced after successful login
  sl.registerLazySingleton<UserHolder>(() => const UserHolder(null));

  // ── Auth ──────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ── Alerts ────────────────────────────────────────
  sl.registerLazySingleton<AlertsRemoteDataSource>(
    () => AlertsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAlertsUseCase(sl()));

  // ── Alerts and Errors ────────────────────────────────────────
  sl.registerLazySingleton<AlertErrorsRemoteDataSource>(
    () => AlertErrorsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AlertsErrorsRepository>(
    () => AlertsErrorsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAlertsErrorsUseCase(sl()));

  // sl.registerLazySingleton(() => GetDeviceAlertsUseCase(sl()));
  // sl.registerLazySingleton(() => GetDeviceErrorsUseCase(sl()));
  // ── Device ────────────────────────────────────────
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetDeviceListUseCase(sl()));

  // ── Analytics ─────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAnalyticsUseCase(sl()));

  // ── Home ──────────────────────────────────────────
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getAlertsUseCase: sl(),
      getDeviceListUseCase: sl(),
      deviceRepository: sl(),
    ),
  );

  // ── Analytics BLoC ────────────────────────────────
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(getAnalyticsUseCase: sl()),
  );
  // Profile ───────────────────────────────────────────────
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      // Inject any use cases your ProfileBloc requires here. For example:
      // getProfileUseCase: sl(),
    ),
  );

  // // ── Alerts & Errors BLoCs ─────────────────────────

  sl.registerFactory<AlertsErrorsBloc>(
    () => AlertsErrorsBloc(getAlertsErrors: sl()),
  );
  // sl.registerFactory<AlertsBloc>(
  //   () => AlertsBloc(getDeviceAlertsUseCase: sl()),
  // );
  // sl.registerFactory<ErrorsBloc>(
  //   () => ErrorsBloc(getDeviceErrorsUseCase: sl()),
  // );
  // ── Geofence ─────────────────────────────────────
  sl.registerLazySingleton<GeofenceRemoteDataSource>(
    () => GeofenceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<GeofenceRepository>(
    () => GeofenceRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetGeofencesUseCase(sl()));

  sl.registerFactory<GeofenceBloc>(
    () => GeofenceBloc(getGeofencesUseCase: sl()),
  );
}

/// Called after successful login to store user globally
void registerUser(UserEntity user) {
  if (sl.isRegistered<UserHolder>()) {
    sl.unregister<UserHolder>();
  }
  sl.registerLazySingleton<UserHolder>(() => UserHolder(user));
  debugPrint('[DI] User registered → ${user.fullName}');
}
