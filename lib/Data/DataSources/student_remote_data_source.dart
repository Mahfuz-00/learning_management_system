import 'dart:io';
import 'package:dio/dio.dart';
import '../../Core/Constants/api_routes.dart';
import '../../Core/Error/exceptions.dart';
import '../Models/json_utils.dart';
import '../Models/student_profile_model.dart';

/// Remote contract for the student profile and the compulsory onboarding form.
///
/// Manual §4.1: the profile form *"pops up automatically after verification. A
/// short compulsory form (school, batch, guardian details). **Cannot be
/// skipped.**"* The previous client had no onboarding support at all, so a
/// freshly verified student could never complete registration.
abstract class StudentRemoteDataSource {
  /// Fetches the full student profile including onboarding state.
  Future<StudentProfileModel> getMyProfile();

  /// Submits the compulsory post-verification profile form.
  Future<void> completeOnboarding(Map<String, dynamic> data);

  /// Updates editable profile details from Settings.
  Future<void> updateProfile(Map<String, dynamic> data);

  /// Uploads a new profile picture.
  Future<void> uploadProfileImage(File image);

  /// Previews what deleting the account would remove.
  Future<Map<String, dynamic>> getAccountDeleteImpact();
}

/// Dio-backed implementation of [StudentRemoteDataSource].
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl({required this.dio});

  @override
  Future<StudentProfileModel> getMyProfile() async {
    try {
      final response = await dio.get(ApiRoutes.studentMe);
      return StudentProfileModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> completeOnboarding(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.studentCompleteOnboarding, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await dio.put(ApiRoutes.studentUpdateProfile, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadProfileImage(File image) async {
    try {
      final fileName = image.path.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });
      await dio.post(ApiRoutes.studentUploadProfileImage, data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountDeleteImpact() async {
    try {
      final response = await dio.get(ApiRoutes.accountDeleteImpact);
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}