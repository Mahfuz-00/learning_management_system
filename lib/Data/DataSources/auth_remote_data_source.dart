import 'package:dio/dio.dart';
import '../Models/user_model.dart';
import 'dart:developer';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
    required String name,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    log('API Request: Login with email: $email');
    try {
      final response = await dio.post('/register/login', data: {
        'email': email,
        'password': password,
      });

      log('API Response: Login success: ${response.data}');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      log('API Error: Login failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      log('API Error: Unexpected error: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    log('API Request: Register for email: $email, role: $role');
    try {
      final response = await dio.post('/register/register', data: {
        'email': email,
        'password': password,
        'role': role,
        'name': name,
      });

      log('API Response: Register success: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      log('API Error: Register failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      log('API Error: Unexpected error: $e');
      throw Exception(e.toString());
    }
  }
}
