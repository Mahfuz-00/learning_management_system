import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/quiz_entity.dart';
import '../../../Domain/Repositories/course_repository.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuiz extends QuizEvent {
  final String lessonId;
  const LoadQuiz(this.lessonId);
  @override
  List<Object?> get props => [lessonId];
}

class SubmitQuizEvent extends QuizEvent {
  final String lessonId;
  final Map<String, dynamic> answers;
  const SubmitQuizEvent(this.lessonId, this.answers);
  @override
  List<Object?> get props => [lessonId, answers];
}

abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}
class QuizLoading extends QuizState {}
class QuizLoaded extends QuizState {
  final List<QuestionEntity> questions;
  final bool hasAttempted;
  const QuizLoaded({required this.questions, required this.hasAttempted});
  @override
  List<Object?> get props => [questions, hasAttempted];
}
class QuizSubmissionSuccess extends QuizState {
  final Map<String, dynamic> result;
  const QuizSubmissionSuccess(this.result);
  @override
  List<Object?> get props => [result];
}
class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);
  @override
  List<Object?> get props => [message];
}

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final CourseRepository repository;

  QuizBloc({required this.repository}) : super(QuizInitial()) {
    on<LoadQuiz>((event, emit) async {
      emit(QuizLoading());
      final questionsResult = await repository.getQuizQuestions(event.lessonId);
      final attemptedResult = await repository.hasAttemptedQuiz(event.lessonId);
      
      questionsResult.fold(
        (failure) => emit(QuizError(failure.message)),
        (questions) {
          attemptedResult.fold(
            (failure) => emit(QuizError(failure.message)),
            (hasAttempted) => emit(QuizLoaded(questions: questions, hasAttempted: hasAttempted)),
          );
        },
      );
    });

    on<SubmitQuizEvent>((event, emit) async {
      emit(QuizLoading());
      final result = await repository.submitQuiz(event.lessonId, event.answers);
      result.fold(
        (failure) => emit(QuizError(failure.message)),
        (data) => emit(QuizSubmissionSuccess(data)),
      );
    });
  }
}
