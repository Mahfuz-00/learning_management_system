import 'package:dio/dio.dart';
import '../Models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(Map<String, dynamic> signupData);
  Future<UserModel> getProfile();
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String otp);
  Future<void> resetPassword(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post('register/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw _handleError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> signupData) async {
    try {
      final response = await dio.post('register/register', data: signupData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw _handleError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('register/profile');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw _handleError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('register/forgotpassword', data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await dio.post('register/verifyotp', data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword(String email, String password) async {
    try {
      await dio.post('register/resetpassword', data: {'email': email, 'password': password});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Safe error handling for response data
  Exception _handleError(Response response) {
    if (response.data is Map) {
      return Exception(response.data['message'] ?? 'Server error');
    }
    return Exception('Server error: ${response.statusCode}');
  }

  // Safe error handling for Dio exceptions
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return Exception('Connection timeout');
    if (e.response?.data is Map) {
      return Exception(e.response?.data['message'] ?? 'Network error');
    }
    return Exception(e.message ?? 'Network error');
  }
}
