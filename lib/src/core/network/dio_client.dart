import 'package:dio/dio.dart';

class DioClient {
  DioClient({
    required String baseUrl,
    String? accessToken,
    List<Interceptor>? interceptors,
    String? contentType,
    Map<String, dynamic>? headers,
  }) : _dio = DioClient.createDio(
          baseUrl: baseUrl,
          accessToken: accessToken,
          interceptors: interceptors,
          contentType: contentType,
          headers: headers ?? {},
        );

  final Dio _dio;

  Dio get dio => _dio;

  static Dio createDio({
    required String baseUrl,
    String? accessToken,
    List<Interceptor>? interceptors,
    String? contentType = Headers.jsonContentType,
    Map<String, dynamic> headers = const {},
  }) {
    final Dio dio = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer $accessToken'}..addAll(headers),
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
