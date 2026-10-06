import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../Constants/app_constants.dart';
import '../Constants/api_routes.dart';
import '../../Data/DataSources/auth_local_data_source.dart';

/// Configures the single [Dio] instance used by the entire app.
///
/// Responsibilities:
/// 1. Base URL / timeouts (Bangladeshi mobile networks are slow — generous 30s).
/// 2. Attaching the JWT `Authorization: Bearer <token>` header.
/// 3. **Transparent token refresh on 401** — the previous implementation left
///    this as an empty `TODO`, so an expired session produced confusing errors
///    instead of a clean refresh (or a clean logout).
/// 4. Skipping the auth header for the public `/free-live` namespace
///    (**Rule 12**: "`/free-live` is fully public. Anyone can watch without
///    logging in or registering").
class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  /// Guards against multiple concurrent refreshes. If five requests fail with
  /// 401 at once we must refresh **once**, not five times (which would burn
  /// three extra attempts against the Rule 13 rate limiter).
  bool _isRefreshing = false;

  /// Callback invoked when the session cannot be recovered.
  /// Wired up in DI to `AuthBloc.add(LogoutRequested())` so the GoRouter guard
  /// bounces the user to `/login`.
  void Function()? onSessionExpired;

  DioClient(this.dio, this.localDataSource) {
    dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json;

    // Verbose logging is a development aid only. Shipping request bodies and
    // response payloads to production logs leaks JWTs and student data.
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Rule 12: the free-live namespace is public. Sending a stale token
        // there can cause a 401 on a route that should never require auth.
        if (_isPublicRoute(options.path)) {
          return handler.next(options);
        }

        final token = await localDataSource.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // ── Token refresh ────────────────────────────────────────────────
        if (error.response?.statusCode == 401 &&
            !_isPublicRoute(error.requestOptions.path) &&
            !_isAuthRoute(error.requestOptions.path) &&
            error.requestOptions.extra['__retried'] != true) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            try {
              // Replay the original request with the new token.
              final options = error.requestOptions;
              options.extra['__retried'] = true;
              final token = await localDataSource.getToken();
              options.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
          // Refresh failed — the session is genuinely gone.
          onSessionExpired?.call();
        }
        return handler.next(error);
      },
    ));
  }

  /// True for routes that must never carry an `Authorization` header.
  static bool _isPublicRoute(String path) {
    return path.contains('LiveClass/free') ||
        path.contains('Register/invite') ||
        path.contains('Register/Login') ||
        path.contains('app/login') ||
        path.contains('Register/Register') ||
        path.contains('PasswordReset') ||
        path.contains('Announcement/active') ||
        path.contains('Course/GetAll') ||
        path.contains('Course/GetById') ||
        path.contains('Instructor') ||
        path.contains('Store/items') ||
        path.contains('CourseRating/summary') ||
        path.contains('CourseComment/course');
  }

  /// True for auth routes — a 401 here means "bad credentials", not "expired
  /// session", so refreshing would be pointless and wasteful.
  static bool _isAuthRoute(String path) {
    return path.contains('Register/Login') ||
        path.contains('app/login') ||
        path.contains('Register/Register') ||
        path.contains('Register/Refresh') ||
        path.contains('PasswordReset');
  }

  /// Attempts `POST /api/Register/Refresh` exactly once across all callers.
  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) {
      // Another request is already refreshing — wait for it to finish rather
      // than firing a second refresh.
      while (_isRefreshing) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
      final token = await localDataSource.getToken();
      return token != null && token.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) return false;

      // Use a bare Dio so the refresh call cannot recurse through this
      // interceptor chain.
      final bare = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await bare.post(
        ApiRoutes.refresh,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      final newToken = data is Map
          ? (data['token'] ?? data['data']?['token'])?.toString()
          : null;

      if (newToken != null && newToken.isNotEmpty) {
        await localDataSource.cacheToken(newToken);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
