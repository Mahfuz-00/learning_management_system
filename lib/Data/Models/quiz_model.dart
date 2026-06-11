import '../../Domain/Entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.lessonId,
    required super.title,
    required super.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id']?.toString() ?? '',
      lessonId: json['lessonId']?.toString() ?? '',
      title: json['title'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'questions': questions.map((q) => (q as QuestionModel).toJson()).toList(),
    };
  }
}

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.options,
    required super.correctOptionIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
