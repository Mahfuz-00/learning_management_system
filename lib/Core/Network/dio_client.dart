import 'package:dio/dio.dart';
import '../Constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json
      ..interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final box = await Hive.openBox(AppConstants.userBox);
          final token = box.get(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token expiration - potentially logout user
          }
          return handler.next(e);
        },
      ));
  }
}
