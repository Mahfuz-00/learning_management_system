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
        throw Exception(response.data['message'] ?? 'Failed to login');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> signupData) async {
    try {
      final response = await dio.post('register/register', data: signupData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to register');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('register/profile');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // Endpoint not explicitly in Image 2/3 but requested in workflow
      await dio.post('register/forgotpassword', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error sending OTP');
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await dio.post('register/verifyotp', data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid OTP');
    }
  }

  @override
  Future<void> resetPassword(String email, String password) async {
    try {
      await dio.post('register/resetpassword', data: {'email': email, 'password': password});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error resetting password');
    }
  }
}
