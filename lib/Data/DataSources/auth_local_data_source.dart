import 'package:hive_flutter/hive_flutter.dart';
import '../../Core/Constants/app_constants.dart';
import '../Models/user_model.dart';
import '../Models/user_preference_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearCache();
  Future<void> cacheUserPreferences(UserPreferenceModel preferences);
  Future<UserPreferenceModel?> getUserPreferences();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheToken(String token) async {
    final box = await Hive.openBox(AppConstants.userBox);
    await box.put(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final box = await Hive.openBox(AppConstants.userBox);
    return box.get(AppConstants.tokenKey);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final box = await Hive.openBox(AppConstants.userBox);
    await box.put(AppConstants.userDataKey, user.toJson());
  }

  @override
  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(AppConstants.userBox);
    final userData = box.get(AppConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    final box = await Hive.openBox(AppConstants.userBox);
    await box.clear();
  }

  @override
  Future<void> cacheUserPreferences(UserPreferenceModel preferences) async {
    final box = await Hive.openBox(AppConstants.userBox);
    await box.put(AppConstants.userPreferencesKey, preferences.toJson());
  }

  @override
  Future<UserPreferenceModel?> getUserPreferences() async {
    final box = await Hive.openBox(AppConstants.userBox);
    final data = box.get(AppConstants.userPreferencesKey);
    if (data != null) {
      return UserPreferenceModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}
