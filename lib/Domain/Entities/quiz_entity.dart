import 'package:equatable/equatable.dart';

class QuizEntity extends Equatable {
  final String id;
  final String lessonId;
  final String title;
  final List<QuestionEntity> questions;

  const QuizEntity({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.questions,
  });

  @override
  List<Object?> get props => [id, lessonId, title, questions];
}

class QuestionEntity extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  @override
  List<Object?> get props => [id, text, options, correctOptionIndex];
}
