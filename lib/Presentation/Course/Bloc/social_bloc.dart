import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/comment_entity.dart';
import '../../../Domain/Entities/rating_entity.dart';
import '../../../Domain/Repositories/course_repository.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();
  @override
  List<Object?> get props => [];
}

class LoadSocialDataRequested extends SocialEvent {
  final String courseId;
  const LoadSocialDataRequested(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

class AddRatingRequested extends SocialEvent {
  final String courseId;
  final int rating;
  final String feedback;
  const AddRatingRequested({required this.courseId, required this.rating, required this.feedback});
  @override
  List<Object?> get props => [courseId, rating, feedback];
}

class AddCommentRequested extends SocialEvent {
  final String courseId;
  final String content;
  const AddCommentRequested({required this.courseId, required this.content});
  @override
  List<Object?> get props => [courseId, content];
}

abstract class SocialState extends Equatable {
  const SocialState();
  @override
  List<Object?> get props => [];
}

class SocialInitial extends SocialState {}
class SocialLoading extends SocialState {}
class SocialLoaded extends SocialState {
  final Map<String, dynamic> ratingSummary;
  final List<CommentEntity> comments;
  const SocialLoaded({required this.ratingSummary, required this.comments});
  @override
  List<Object?> get props => [ratingSummary, comments];
}
class SocialError extends SocialState {
  final String message;
  const SocialError(this.message);
  @override
  List<Object?> get props => [message];
}

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final CourseRepository repository;

  SocialBloc({required this.repository}) : super(SocialInitial()) {
    on<LoadSocialDataRequested>((event, emit) async {
      emit(SocialLoading());
      final ratingResult = await repository.getRatingSummary(event.courseId);
      final commentResult = await repository.getCourseComments(event.courseId);
      
      ratingResult.fold(
        (f) => emit(SocialError(f.message)),
        (summary) {
          commentResult.fold(
            (f) => emit(SocialError(f.message)),
            (comments) => emit(SocialLoaded(ratingSummary: summary, comments: comments)),
          );
        },
      );
    });

    on<AddRatingRequested>((event, emit) async {
      final result = await repository.addRating({
        'courseId': event.courseId,
        'rating': event.rating,
        'feedback': event.feedback,
      });
      result.fold(
        (f) => emit(SocialError(f.message)),
        (_) => add(LoadSocialDataRequested(event.courseId)),
      );
    });

    on<AddCommentRequested>((event, emit) async {
      final result = await repository.addComment({
        'courseId': event.courseId,
        'content': event.content,
      });
      result.fold(
        (f) => emit(SocialError(f.message)),
        (_) => add(LoadSocialDataRequested(event.courseId)),
      );
    });
  }
}
