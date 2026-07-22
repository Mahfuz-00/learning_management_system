import 'package:dio/dio.dart';
import '../Constants/app_constants.dart';
import '../../Data/DataSources/auth_local_data_source.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  DioClient(this.dio, this.localDataSource) {
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
          final token = await localDataSource.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token expiration - potentially logout user via some global event or sl<AuthBloc>().add(LogoutRequested())
          }
          return handler.next(e);
        },
      ));
  }
}
