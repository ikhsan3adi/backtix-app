import 'package:backtix_app/src/blocs/auth/auth_helper.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthHelper _authHelper;

  AuthInterceptor({
    required Dio dio,
    required AuthHelper authHelper,
  })  : _dio = dio,
        _authHelper = authHelper;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final dynamic messageResponse = err.response?.data['message'];
    final String? message = messageResponse.runtimeType == List
        ? messageResponse[0]
        : messageResponse;

    if (statusCode == 401) {
      // If a 401 response is received, refresh the access token
      if (await _authHelper.refreshAccessToken() != null) {
        // Repeat the request with the updated header
        return handler.resolve(
          await _dio.fetch(
            err.requestOptions.copyWith(headers: _dio.options.headers),
          ),
        );
      }
    } else if (statusCode == 403 && message == 'UNACTIVATED') {
      // If a UNACTIVATED response is received, set user to unactivated
      _authHelper.deactivateUser();
    }
    return handler.next(err);
  }
}
