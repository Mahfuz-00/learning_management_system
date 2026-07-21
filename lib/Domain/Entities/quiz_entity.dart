import 'package:equatable/equatable.dart';

class QuizEntity extends Equatable {
  final String lessonId;
  final List<QuestionEntity> questions;
  final bool hasAttempted;
  final int? score;

  const QuizEntity({
    required this.lessonId,
    required this.questions,
    this.hasAttempted = false,
    this.score,
  });

  @override
  List<Object?> get props => [lessonId, questions, hasAttempted, score];
}

class QuestionEntity extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final String? correctAnswer; // Used by teacher or for results

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswer,
  });

  @override
  List<Object?> get props => [id, text, options, correctAnswer];
}
