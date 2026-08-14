import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core & Network
import '../../data/datasources/remote/device_assignment_remote_datasource.dart';
import '../../data/datasources/remote/relationship_remote_datasource.dart';
import '../../data/datasources/remote/settings_remote_datasource.dart';
import '../../data/repositories_impl/device_assignment_repository_impl.dart';
import '../../data/repositories_impl/relationship_repository_impl.dart';
import '../../data/repositories_impl/settings_repository_impl.dart';
import '../../domain/repositories/device_assignment_repository.dart';
import '../../domain/repositories/relationship_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/device_assignments/assign_device_usecase.dart';
import '../../domain/usecases/device_assignments/unassign_device_usecase.dart';
import '../../domain/usecases/relationship/create_relationship_by_phone_usecase.dart';
import '../../domain/usecases/relationship/create_relationship_usecase.dart';
import '../../domain/usecases/relationship/delete_relationship_usecase.dart';
import '../../domain/usecases/relationship/get_relationship_list_usecase.dart';
import '../../domain/usecases/settings/get_settings_usecase.dart';
import '../../domain/usecases/settings/update_phone_numbers_usecase.dart';
import '../../domain/usecases/signup/delete_person_usecase.dart';
import '../../presentation/blocs/manage_devices/manage_devices_bloc.dart';
import '../../presentation/blocs/manage_users/manage_users_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';
import '../config/map_config.dart';
import '../../data/network/dio_client.dart';

// Entities
import '../../domain/entities/auth/user_entity.dart';

// Data Sources (Local)
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/signup_local_datasource.dart';
import '../../data/datasources/local/theme_local_datasource.dart';

// Data Sources (Remote)
import '../../data/datasources/remote/alerts_remote_datasource.dart';
import '../../data/datasources/remote/analytics_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/datasources/remote/geofence_remote_datasource.dart';
import '../../data/datasources/remote/link_device_remote_datasource.dart';
import '../../data/datasources/remote/mode_remote_datasource.dart';
import '../../data/datasources/remote/signup_remote_datasource.dart';

// Repositories (Interfaces)
import '../../domain/repositories/alerts_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../../domain/repositories/link_device_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/mode_repository.dart';
import '../../domain/repositories/signup_repository.dart';

// Repository Implementations
import '../../data/repositories_impl/alerts_repository_impl.dart';
import '../../data/repositories_impl/analytics_repository_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/device_repository_impl.dart';
import '../../data/repositories_impl/geofence_repository_impl.dart';
import '../../data/repositories_impl/link_device_repository_impl.dart';
import '../../data/repositories_impl/location_repository_impl.dart';
import '../../data/repositories_impl/mode_repository_impl.dart';
import '../../data/repositories_impl/signup_repository_impl.dart';
import '../../data/repositories_impl/theme_repository_impl.dart';

// Use Cases
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../domain/usecases/analytics/get_analytics_usecase.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/device/get_device_list_usecase.dart';
import '../../domain/usecases/device/invalidate_device_cache_usecase.dart';
import '../../domain/usecases/geofence/create_geofence_usecase.dart';
import '../../domain/usecases/geofence/delete_geofence_usecase.dart';
import '../../domain/usecases/geofence/edit_geofence_usecase.dart';
import '../../domain/usecases/geofence/get_geofences_usecase.dart';
import '../../domain/usecases/link_device/link_device_usecase.dart';
import '../../domain/usecases/location/get_user_location_usecase.dart';
import '../../domain/usecases/modes/get_modes_usecase.dart';
import '../../domain/usecases/modes/switch_mode_usecase.dart';
import '../../domain/usecases/signup/clear_saved_signup_progress_usecase.dart';
import '../../domain/usecases/signup/create_credentials_usecase.dart';
import '../../domain/usecases/signup/create_person_usecase.dart';
import '../../domain/usecases/signup/get_saved_signup_progress_usecase.dart';

// Blocs & Cubits
import '../../presentation/blocs/alerts/alerts_bloc.dart';
import '../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/device_list/device_list_bloc.dart';
import '../../presentation/blocs/geofence/geofence_bloc.dart';
import '../../presentation/blocs/landing/landing_bloc.dart';
import '../../presentation/blocs/link_device/link_device_bloc.dart';
import '../../presentation/blocs/modes/mode_bloc.dart';
import '../../presentation/blocs/manage/manage_bloc.dart';
import '../../presentation/blocs/signup/signup_bloc.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../../presentation/blocs/user_location/user_location_bloc.dart';

// Wrapper to allow nullable user in get_it
class UserHolder {
  final UserEntity? user;
  const UserHolder(this.user);
}

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();
  await MapConfig.init();

  // ── Core & External ─────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ── Network ─────────────────────────────────────────────
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ── Global State Holders ────────────────────────────────
  sl.registerLazySingleton<UserHolder>(() => const UserHolder(null));

  // ── Theme Feature ───────────────────────────────────────

  sl.registerLazySingleton(() => ThemeLocalDataSource(sl()));
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(sl<ThemeLocalDataSource>()),
  );

  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<ThemeRepository>()));

  // ── Map Tile ────────────────────────────────────────

  sl.registerLazySingleton<TileProvider>(() => MapConfig.tileProvider);

  // ── Auth Feature ────────────────────────────────────────
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

  // ── Signup Feature ──────────────────────────────────────
  sl.registerLazySingleton<SignupRemoteDataSource>(
    () => SignupRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SignupLocalDataSource>(
    () => SignupLocalDataSource(sl()),
  );
  sl.registerLazySingleton<SignupRepository>(
    () => SignupRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton(() => CreatePersonUseCase(sl()));
  sl.registerLazySingleton(() => CreateCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedSignupProgressUseCase(sl()));
  sl.registerLazySingleton(() => ClearSavedSignupProgressUseCase(sl()));
  sl.registerFactory<SignupBloc>(
    () => SignupBloc(
      createPersonUseCase: sl(),
      createCredentialsUseCase: sl(),
      getSavedProgressUseCase: sl(),
      clearSavedProgressUseCase: sl(),
    ),
  );

  // ── Device List Feature ─────────────────────────────────
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetDeviceListUseCase(sl()));
  sl.registerLazySingleton(() => InvalidateDeviceCacheUseCase(sl()));
  sl.registerFactory<DeviceListBloc>(
    () => DeviceListBloc(
      getDeviceListUseCase: sl(),
      invalidateDeviceCacheUseCase: sl(),
      userHolder: sl(),
    ),
  );

  // ── Link Device Feature ─────────────────────────────────
  sl.registerLazySingleton<LinkDeviceRemoteDataSource>(
    () => LinkDeviceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<LinkDeviceRepository>(
    () => LinkDeviceRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => LinkDeviceUseCase(sl()));
  sl.registerFactory<LinkDeviceBloc>(
    () => LinkDeviceBloc(linkDeviceUseCase: sl()),
  );

  // ── Alerts Feature ──────────────────────────────────────
  sl.registerLazySingleton<AlertsRemoteDataSource>(
    () => AlertsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAlertsUseCase(sl()));
  sl.registerFactory<AlertsBloc>(() => AlertsBloc(getAlertsUseCase: sl()));

  // ── Analytics Feature ───────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAnalyticsUseCase(sl()));
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(getAnalyticsUseCase: sl()),
  );

  // ── Geofence Feature ────────────────────────────────────
  sl.registerLazySingleton<GeofenceRemoteDataSource>(
    () => GeofenceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<GeofenceRepository>(
    () => GeofenceRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetGeofencesUseCase(sl()));
  sl.registerLazySingleton(() => CreateGeofenceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGeofenceUseCase(sl()));
  sl.registerFactory(() => EditGeofenceUseCase(sl()));
  sl.registerFactory<GeofenceBloc>(
    () => GeofenceBloc(
      getGeofencesUseCase: sl(),
      createGeofenceUseCase: sl(),
      editGeofenceUseCase: sl(),
      deleteGeofenceUseCase: sl(),
    ),
  );

  // ── Modes & Profiles Feature ────────────────────────────
  sl.registerLazySingleton<ModeRemoteDataSource>(
    () => ModeRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ModeRepository>(
    () => ModeRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetModesUseCase(sl()));
  sl.registerLazySingleton(() => SwitchModeUseCase(sl()));
  sl.registerFactory<ModeBloc>(
    () => ModeBloc(getModesUseCase: sl(), switchModeUseCase: sl()),
  );
  // ── Manage Feature ──────────────────────────────────────
  sl.registerFactory<ManageBloc>(
    () => ManageBloc(
      getModesUseCase: sl(),
      switchModeUseCase: sl(),
      getSettingsUseCase: sl(),
      updatePhoneNumbersUseCase: sl(),
    ),
  );

  // ── User Location Feature ───────────────────────────────
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl());
  sl.registerLazySingleton(() => GetUserLocationUseCase(sl()));
  sl.registerFactory(() => UserLocationBloc(getUserLocationUseCase: sl()));

  // ── UI Navigation / Shell Blocs ─────────────────────────
  sl.registerFactory<LandingBloc>(
    () => LandingBloc(
      getAnalyticsUseCase: sl(),
      getAlertsUseCase: sl(),
      userHolder: sl(),
    ),
  );

  // ── Settings Feature ───────────────────────────────────
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePhoneNumbersUseCase(sl()));
  sl.registerFactory<SettingsBloc>(
    () =>
        SettingsBloc(getSettingsUseCase: sl(), updatePhoneNumbersUseCase: sl()),
  );

  // ── Manage Devices Feature ──────────────────────────────
  sl.registerLazySingleton<RelationshipRemoteDataSource>(
    () => RelationshipRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<RelationshipRepository>(
    () => RelationshipRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetRelationshipListUseCase(sl()));

  sl.registerLazySingleton<DeviceAssignmentRemoteDataSource>(
    () => DeviceAssignmentRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<DeviceAssignmentRepository>(
    () => DeviceAssignmentRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => AssignDeviceUseCase(sl()));
  sl.registerLazySingleton(() => UnassignDeviceUseCase(sl()));

  sl.registerFactoryParam<ManageDevicesBloc, DeviceListBloc, void>(
    (deviceListBloc, _) => ManageDevicesBloc(
      getRelationshipListUseCase: sl(),
      assignDeviceUseCase: sl(),
      unassignDeviceUseCase: sl(),
      userHolder: sl(),
      deviceListBloc: deviceListBloc,
    ),
  );

  // ── Manage Users Feature ────────────────────────────────
  sl.registerLazySingleton(() => CreateRelationshipUseCase(sl()));
  sl.registerLazySingleton(() => CreateRelationshipByPhoneUseCase(sl()));
  sl.registerLazySingleton(() => DeletePersonUseCase(sl()));
  sl.registerLazySingleton(() => UnlinkRelationshipUseCase(sl()));
  sl.registerFactory<ManageUsersBloc>(
    () => ManageUsersBloc(
      getRelationshipListUseCase: sl(),
      createPersonUseCase: sl(),
      createRelationshipUseCase: sl(),
      createRelationshipByPhoneUseCase: sl(),
      deletePersonUseCase: sl(),
      unlinkRelationshipUseCase: sl(),
      userHolder: sl(),
    ),
  );
}

/// Called after successful login to store user globally
void registerUser(UserEntity user) {
  if (sl.isRegistered<UserHolder>()) {
    sl.unregister<UserHolder>();
  }
  sl.registerLazySingleton<UserHolder>(() => UserHolder(user));
}
