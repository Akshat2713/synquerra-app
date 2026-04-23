// lib/di/injection_container.dart
import 'package:get_it/get_it.dart';
import '../data/datasources/local/auth_local_datasource.dart';
import '../data/datasources/local/device_config_local_datasource.dart';
import '../data/datasources/local/secure_storage_service.dart';
import '../data/datasources/local/theme_local_datasource.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/command_remote_datasource.dart';
import '../data/datasources/remote/device_remote_datasource.dart';
import '../data/mappers/analytics_mapper.dart';
import '../data/mappers/device_config_mapper.dart';
import '../data/mappers/user_mapper.dart';
import '../data/network/api_client.dart';
import '../data/repositories_impl/auth_repository_impl.dart';
import '../data/repositories_impl/device_config_repository_impl.dart';
import '../data/repositories_impl/device_repository_impl.dart';
import '../data/repositories_impl/theme_repository_impl.dart';
import '../business/repositories/auth_repository.dart';
import '../business/repositories/device_config_repository.dart';
import '../business/repositories/device_repository.dart';
import '../business/repositories/theme_repository.dart';
import '../business/usecases/auth/check_auth_status_usecase.dart';
import '../business/usecases/auth/login_usecase.dart';
import '../business/usecases/auth/logout_usecase.dart';
import '../business/usecases/auth/signup_usecase.dart';
import '../business/usecases/device/get_device_telemetry_usecase.dart';
import '../business/usecases/device/refresh_device_usecase.dart';
import '../business/blocs/auth_bloc/auth_bloc.dart';
import '../business/blocs/device_bloc/device_bloc.dart';
import '../business/blocs/device_config_bloc/device_config_bloc.dart';
import '../business/blocs/navigation_bloc/navigation_bloc.dart';
import '../business/blocs/searched_device_bloc/searched_device_bloc.dart';
import '../business/blocs/theme_bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ============ LOCAL DATA SOURCES ============
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(secureStorage: sl()),
  );
  sl.registerLazySingleton<ThemeLocalDataSource>(() => ThemeLocalDataSource());
  sl.registerLazySingleton<DeviceConfigLocalDataSource>(
    () => DeviceConfigLocalDataSource(mapper: sl()),
  );

  // ============ NETWORK ============
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ============ REMOTE DATA SOURCES ============
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSource(apiClient: sl(), mapper: sl()),
  );
  sl.registerLazySingleton<CommandRemoteDataSource>(
    () => CommandRemoteDataSource(apiClient: sl()),
  );

  // ============ MAPPERS ============
  sl.registerLazySingleton<UserMapper>(() => UserMapper());
  sl.registerLazySingleton<AnalyticsMapper>(() => AnalyticsMapper());
  sl.registerLazySingleton<DeviceConfigMapper>(() => DeviceConfigMapper());

  // ============ REPOSITORIES ============
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      mapper: sl(),
    ),
  );
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remoteDataSource: sl(), mapper: sl()),
  );
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<DeviceConfigRepository>(
    () => DeviceConfigRepositoryImpl(localDataSource: sl(), mapper: sl()),
  );

  // ============ USE CASES ============
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // Device Use Cases
  sl.registerLazySingleton(() => RefreshDeviceUseCase(sl()));
  sl.registerLazySingleton(() => GetDeviceTelemetryUseCase(sl()));

  // ============ BLOCs ============
  // IMPORTANT: Register all BLoCs here
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => DeviceBloc(deviceRepository: sl()));
  sl.registerFactory(() => SearchedDeviceBloc(deviceRepository: sl()));
  sl.registerFactory(() => ThemeBloc(themeRepository: sl()));
  sl.registerFactory(() => DeviceConfigBloc(repository: sl()));
  sl.registerFactory(() => NavigationBloc());
}
