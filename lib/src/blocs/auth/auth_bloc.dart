import 'package:backtix_app/src/core/network/dio_client.dart';
import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:dio/dio.dart';
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
    on<_RefreshAuthentication>(_refreshAuthentication);
    on<_RemoveAuthentication>(_removeAuthentication);
    on<_UpdateUserDetails>(_updateUserDetails);
  }

  Future<void> _addAuthentication(
    _AddAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    _dioClient.setAccessTokenHeader(accessToken: event.newAuth.accessToken);

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (e) {
        if (e.response?.statusCode == 401) {
          return emit(const AuthState.unauthenticated());
        }
        return emit(AuthState.unauthenticated(error: e));
      },
      (user) {
        return emit(AuthState.authenticated(
          user: user,
          auth: event.newAuth,
        ));
      },
    );
  }

  Future<void> _refreshAuthentication(
    _RefreshAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! _Authenticated) {
      return emit(const AuthState.unauthenticated());
    }

    try {
      final currentState = (state as _Authenticated);

      if (currentState.auth.refreshToken == null) {
        return emit(const AuthState.unauthenticated());
      }

      final response = await _authService
          .refreshAccessToken(currentState.auth.refreshToken!);

      _dioClient.setAccessTokenHeader(accessToken: response.data.accessToken);

      return emit(AuthState.authenticated(
        user: (state as _Authenticated).user,
        auth: response.data,
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return emit(const AuthState.unauthenticated());
      }
    }
  }

  Future<void> _removeAuthentication(
    _RemoveAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = (state as _Authenticated);

      if (currentState.auth.refreshToken == null) {
        return emit(const AuthState.unauthenticated());
      }

      await _authService.logoutUser(currentState.auth.refreshToken!);
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
    emit(AuthState.authenticated(user: event.user, auth: currentState.auth));
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
