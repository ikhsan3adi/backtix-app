import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthHelper {
  ///! **Inject [AuthService] with different [Dio] instance without *interceptors***
  ///
  ///! **to avoid infinite interceptor loop (when) receive `401`**
  AuthHelper(
    this._authBloc,
    this._authService, {
    this.ignoreUnauthorized = false,
  });

  final AuthService _authService;
  final AuthBloc _authBloc;
  final bool ignoreUnauthorized;

  Future<String?> refreshAccessToken() async {
    try {
      if (ignoreUnauthorized) _authBloc.hydrate();

      final auth = _authBloc.state.mapOrNull(authenticated: (s) => s.auth);

      if (auth?.refreshToken == null) {
        if (!ignoreUnauthorized) {
          _authBloc.add(const AuthEvent.removeAuthentication());
        }
        return null;
      }

      // Won't loop here
      final response = await _authService.refreshAccessToken(
        auth!.refreshToken!,
      );

      _authBloc.add(AuthEvent.authenticate(
        newAuth: auth.copyWith(accessToken: response.data.accessToken),
      ));

      return response.data.accessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && !ignoreUnauthorized) {
        _authBloc.add(const AuthEvent.removeAuthentication());
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
    return null;
  }

  void deactivateUser() async {
    final user = _authBloc.state.mapOrNull(authenticated: (s) => s.user);

    if (user != null) {
      _authBloc.add(
        AuthEvent.updateUserDetails(user: user.copyWith(activated: false)),
      );
    }
  }
}
