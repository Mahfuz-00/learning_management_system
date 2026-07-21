import '../../Domain/Entities/user_preference_entity.dart';

class UserPreferenceModel extends UserPreferenceEntity {
  const UserPreferenceModel({
    required super.categories,
    required super.learningGoal,
    required super.dailyTime,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      categories: List<String>.from(json['categories'] ?? []),
      learningGoal: json['learningGoal'] ?? '',
      dailyTime: json['dailyTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'learningGoal': learningGoal,
      'dailyTime': dailyTime,
    };
  }
}
