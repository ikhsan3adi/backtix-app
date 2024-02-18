import 'package:backtix_app/src/core/network/dio_client.dart';
import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserRepository _userRepository;
  final DioClient _dioClient;
  final GoogleAuthService _googleAuthService;

  AuthBloc(
    this._authService,
    this._userRepository,
    this._dioClient,
    this._googleAuthService,
  ) : super(const _Initial()) {
    on<_AddAuthentication>(_addAuthentication);
    on<_RemoveAuthentication>(_removeAuthentication);
    on<_UpdateUserDetails>(_updateUserDetails);
  }

  /// Refresh user detail after [_refreshAt] times [_addAuthentication] called
  int _counter = 0;
  final int _refreshAt = 3;

  Future<void> _addAuthentication(
    _AddAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    _dioClient.setAccessTokenHeader(accessToken: event.newAuth.accessToken);

    final currentUser = state.mapOrNull(authenticated: (s) => s.user);

    if (_counter < _refreshAt && currentUser != null) {
      _counter++;
      return emit(AuthState.authenticated(
        user: currentUser,
        auth: event.newAuth,
      ));
    }
    _counter = 0;

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (e) {
        if (e.response?.statusCode == 401) {
          return emit(const AuthState.unauthenticated());
        }
        return emit(AuthState.unauthenticated(exception: e));
      },
      (user) {
        return emit(AuthState.authenticated(
          user: user,
          auth: event.newAuth,
        ));
      },
    );
  }

  Future<void> _removeAuthentication(
    _RemoveAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state.mapOrNull(authenticated: (s) => s);

      if (currentState?.auth.refreshToken == null) {
        return emit(const AuthState.unauthenticated());
      }

      await _authService.logoutUser(currentState!.auth.refreshToken!);
    } finally {
      _dioClient.deleteAccessTokenHeader();
      await _googleAuthService.signOut();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _updateUserDetails(
    _UpdateUserDetails event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = (state as _Authenticated);

    if (event.user != null) {
      return emit(
        AuthState.authenticated(user: event.user!, auth: currentState.auth),
      );
    }

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (_) => null,
      (user) {
        return emit(AuthState.authenticated(
          user: user,
          auth: currentState.auth,
        ));
      },
    );
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['authenticated']) {
      return AuthState.authenticated(
        user: UserModel.fromJson(json['user']),
        auth: NewAuthModel.fromJson(json['auth']),
      );
    }
    return const AuthState.unauthenticated();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.maybeMap(
      authenticated: (state) => {
        'authenticated': true,
        'user': state.user.toJson(),
        'auth': state.auth.toJson(),
      },
      orElse: () => {'authenticated': false, 'user': null},
    );
  }
}
