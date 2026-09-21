import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/usecases/auth/logout_usecase.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/auth/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../../domain/usecases/auth/sync_fcm_token_usecase.dart';
import '../../../domain/usecases/base_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;
  final SyncFcmTokenUseCase _syncFcmTokenUseCase;
  final PushNotificationService _pushNotificationService;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LogoutUseCase logoutUseCase,
    required SyncFcmTokenUseCase syncFcmTokenUseCase,
    required PushNotificationService pushNotificationService,
  }) : _loginUseCase = loginUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _logoutUseCase = logoutUseCase,
       _syncFcmTokenUseCase = syncFcmTokenUseCase,
       _pushNotificationService = pushNotificationService,
       super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _checkAuthStatusUseCase(NoParams());
    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
        _syncFcmToken();
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthError(failure.userMessage)), (user) {
      emit(AuthAuthenticated(user));
      _syncFcmToken();
    });
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.userMessage)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _syncFcmToken() async {
    try {
      final token = await _pushNotificationService.getToken();
      if (token == null) return;
      final result = await _syncFcmTokenUseCase(token);
      result.fold(
        (failure) =>
            AppLogger.w('AuthBloc', 'FCM sync failed: ${failure.userMessage}'),
        (_) => AppLogger.d('AuthBloc', 'FCM token synced'),
      );
    } catch (e) {
      AppLogger.e('AuthBloc', 'FCM sync error', e);
    }
  }
}
