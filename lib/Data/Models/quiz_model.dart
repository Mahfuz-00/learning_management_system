import '../../Domain/Entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.lessonId,
    required super.questions,
    super.hasAttempted,
    super.score,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return QuizModel(
      lessonId: '', // Usually not returned in the list itself but known from context
      questions: data.map((e) => QuestionModel.fromJson(e)).toList(),
      hasAttempted: json['hasAttempted'] ?? false,
      score: json['score'],
    );
  }
}

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.options,
    super.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: (json['id'] ?? '').toString(),
      text: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': text,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
