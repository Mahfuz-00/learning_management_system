import 'package:equatable/equatable.dart';

class UserPreferenceEntity extends Equatable {
  final List<String> categories;
  final String learningGoal;
  final String dailyTime;

  const UserPreferenceEntity({
    required this.categories,
    required this.learningGoal,
    required this.dailyTime,
  });

  @override
  List<Object?> get props => [categories, learningGoal, dailyTime];
}
