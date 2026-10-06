import 'package:dio/dio.dart';
import '../../Core/Constants/api_routes.dart';
import '../../Core/Error/exceptions.dart';
import '../Models/user_model.dart';

/// Remote contract for authentication and account management.
///
/// Every route used here was verified against the live OpenAPI document. The
/// previous implementation called `register/login`, `register/register`,
/// `register/verifyotp`, `register/forgotpassword` and `register/resetpassword`
/// — **none of which exist** — so authentication was broken against the real
/// server. All paths now come from [ApiRoutes].
abstract class AuthRemoteDataSource {
  /// Authenticates with e-mail + password. Returns the user with a JWT.
  Future<UserModel> login(String email, String password);

  /// Creates a student or teacher account.
  Future<UserModel> register(Map<String, dynamic> signupData);

  /// Fetches the authenticated user's profile.
  Future<UserModel> getProfile();

  /// Step 1 of password recovery — e-mails a reset code.
  Future<void> requestPasswordReset(String email);

  /// Step 2 of password recovery — verifies the reset code.
  Future<void> verifyPasswordResetCode(String email, String code);

  /// Step 3 of password recovery — sets the new password.
  Future<void> resetPassword(String email, String code, String newPassword);

  /// Confirms the 6-digit code e-mailed after student sign-up.
  Future<void> verifyEmail(String email, String otp);

  /// Re-sends the verification code (available 60s after the previous one).
  Future<void> resendVerification(String email);

  /// Changes the password while logged in.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Resolves a teacher invitation token (public endpoint).
  Future<Map<String, dynamic>> resolveInvite(String token);
}

/// Dio-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiRoutes.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> signupData) async {
    try {
      final response = await dio.post(ApiRoutes.register, data: signupData);
      return UserModel.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get(ApiRoutes.profile);
      return UserModel.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await dio.post(ApiRoutes.passwordResetRequest, data: {'email': email});
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> verifyPasswordResetCode(String email, String code) async {
    try {
      await dio.post(
        ApiRoutes.passwordResetVerify,
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // The spec exposes this as PUT, not POST.
      await dio.put(
        ApiRoutes.passwordResetReset,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> verifyEmail(String email, String otp) async {
    try {
      await dio.post(
        ApiRoutes.verifyEmail,
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    try {
      await dio.post(ApiRoutes.resendVerification, data: {'email': email});
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await dio.put(
        ApiRoutes.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> resolveInvite(String token) async {
    try {
      final response = await dio.get(ApiRoutes.invite(token));
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  /// Unwraps `{ data: {...} }` envelopes and tolerates a bare object.
  static Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
