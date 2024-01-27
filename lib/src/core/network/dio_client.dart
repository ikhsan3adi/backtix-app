import 'package:dio/dio.dart';

class DioClient {
  DioClient({
    required String baseUrl,
    String? accessToken,
    List<Interceptor>? interceptors,
    String? contentType,
  }) : _dio = DioClient.createDio(
          baseUrl: baseUrl,
          accessToken: accessToken,
          interceptors: interceptors,
          contentType: contentType,
        );

  final Dio _dio;

  Dio get dio => _dio;

  static Dio createDio({
    required String baseUrl,
    String? accessToken,
    List<Interceptor>? interceptors,
    String? contentType = Headers.jsonContentType,
  }) {
    final Dio dio = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer $accessToken'},
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        contentType: contentType,
      ),
    );

    dio.interceptors.addAll([...?interceptors]);

    return dio;
  }

  void setAccessTokenHeader({required String accessToken}) {
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  void deleteAccessTokenHeader() {
    dio.options.headers['Authorization'] = null;
  }
}
