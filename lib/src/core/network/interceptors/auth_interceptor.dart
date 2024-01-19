import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthBloc _authBloc;

  AuthInterceptor({
    required Dio dio,
    required AuthBloc authBloc,
  })  : _dio = dio,
        _authBloc = authBloc;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final dynamic messageResponse = err.response?.data['message'];
    final String? message = messageResponse.runtimeType == List
        ? messageResponse[0]
        : messageResponse;

    if (statusCode == 401) {
      // If a 401 response is received, refresh the access token
      _authBloc.add(const AuthEvent.refreshAuthentication());

      // Repeat the request with the updated header
      return await _authBloc.stream.first.then((state) async {
        state.mapOrNull(
          authenticated: (_) async {
            return handler.resolve(
              await _dio.fetch(
                err.requestOptions.copyWith(headers: _dio.options.headers),
              ),
            );
          },
        );
      });
    } else if (statusCode == 403 && message == 'UNACTIVATED') {
      // If a UNACTIVATED response is received, set user to unactivated
      final user = _authBloc.state.mapOrNull(
        authenticated: (state) => state.user,
      );

      if (user != null) {
        _authBloc.add(
          AuthEvent.updateUserDetails(
            user: user.copyWith(activated: false),
          ),
        );
      }
    }
    return handler.next(err);
  }
}
