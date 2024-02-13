import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   debugPrint(
  //     '${options.method} ${options.uri}\n${options.headers}\n${options.data}',
  //   );
  //   return handler.next(options);
  // }

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   debugPrint(
  //     '''${response.statusCode} ${response.statusMessage}
  //     \n${response.headers}
  //     \n${response.data}''',
  //   );
  //   return handler.next(response);
  // }

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) {
  //   debugPrint(
  //     '${err.type} - ${err.message}\n${err.error}',
  //   );
  //   return handler.next(err);
  // }
}
