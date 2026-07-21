import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/user_preference_entity.dart';
import '../../../Domain/Repositories/course_repository.dart';

abstract class PreferenceEvent extends Equatable {
  const PreferenceEvent();
  @override
  List<Object?> get props => [];
}

class SavePreferencesRequested extends PreferenceEvent {
  final UserPreferenceEntity preferences;
  const SavePreferencesRequested(this.preferences);
  @override
  List<Object?> get props => [preferences];
}

class LoadPreferencesRequested extends PreferenceEvent {}

abstract class PreferenceState extends Equatable {
  const PreferenceState();
  @override
  List<Object?> get props => [];
}

class PreferenceInitial extends PreferenceState {}
class PreferenceLoading extends PreferenceState {}
class PreferenceLoaded extends PreferenceState {
  final UserPreferenceEntity preferences;
  const PreferenceLoaded(this.preferences);
  @override
  List<Object?> get props => [preferences];
}
class PreferenceSaved extends PreferenceState {}
class PreferenceError extends PreferenceState {
  final String message;
  const PreferenceError(this.message);
  @override
  List<Object?> get props => [message];
}

class PreferenceBloc extends Bloc<PreferenceEvent, PreferenceState> {
  final CourseRepository repository;

  PreferenceBloc({required this.repository}) : super(PreferenceInitial()) {
    on<SavePreferencesRequested>((event, emit) async {
      emit(PreferenceLoading());
      final result = await repository.saveUserPreferences(event.preferences);
      result.fold(
        (failure) => emit(PreferenceError(failure.message)),
        (_) => emit(PreferenceSaved()),
      );
    });

    on<LoadPreferencesRequested>((event, emit) async {
      emit(PreferenceLoading());
      final result = await repository.getUserPreferences();
      result.fold(
        (failure) => emit(PreferenceError(failure.message)),
        (preferences) => emit(PreferenceLoaded(preferences)),
      );
    });
  }
}
