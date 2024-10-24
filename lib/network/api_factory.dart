import 'package:dio/dio.dart';
import 'package:qr_earth/network/refresh_token_interceptor.dart';
import 'package:qr_earth/network/routes.dart';
import 'package:qr_earth/network/session.dart';

class ApiFactory {
  static late final Dio dio;

  static Future<void> init() async {
    await Session.init();
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.serverBaseUrl,
      ),
    );
    dio.interceptors.add(RefreshTokenInterceptor());
  }

  static Future<Response> post(
    String path, {
    dynamic data,
    bool auth = false,
  }) async {
    return dio.post(
      path,
      data: data,
      options: auth
          ? Options(
              headers: {
                "Authorization": 'Bearer ${Session.userAccessToken}',
              },
            )
          : null,
    );
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool auth = false,
  }) async {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: auth
          ? Options(
              headers: {
                "Authorization": 'Bearer ${Session.userAccessToken}',
              },
            )
          : null,
    );
  }
}