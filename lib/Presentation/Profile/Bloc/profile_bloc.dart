import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Drives the student profile screen and the compulsory onboarding form.
///
/// Manual §4.1: after e-mail verification the student *"must fill a short
/// profile form"* that *"cannot be skipped"*. The [ProfileState.needsOnboarding]
/// flag is what the router and the profile page use to enforce that.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileState()) {
    on<LoadStudentProfile>(_onLoadProfile);
    on<CompleteOnboardingRequested>(_onCompleteOnboarding);
    on<UpdateStudentProfileRequested>(_onUpdateProfile);
    on<ClearProfileFeedback>(_onClearFeedback);
  }

  /// Loads the profile and evaluates the onboarding requirement.
  Future<void> _onLoadProfile(
    LoadStudentProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final result = await repository.getStudentProfile();
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (profile) {
        // The model resolves `needsOnboarding` from the server flag when
        // present, and otherwise infers it from missing institution/guardian
        // data. It is read through a dynamic access so this BLoC does not
        // depend on the data-layer model type.
        final needs = _needsOnboarding(profile);
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          needsOnboarding: needs,
        ));
      },
    );
  }

  /// Submits the compulsory onboarding form.
  Future<void> _onCompleteOnboarding(
    CompleteOnboardingRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true, actionSucceeded: false));
    final result = await repository.completeOnboarding(event.profile);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: event.profile,
        needsOnboarding: false,
        actionSucceeded: true,
      )),
    );
  }

  /// Saves edits made in the Settings tab.
  Future<void> _onUpdateProfile(
    UpdateStudentProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true, actionSucceeded: false));
    final result = await repository.updateStudentProfile(event.profile);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: event.profile,
        actionSucceeded: true,
      )),
    );
  }

  /// Clears the one-shot success flag.
  Future<void> _onClearFeedback(
    ClearProfileFeedback event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(actionSucceeded: false, clearError: true));
  }

  /// Reads the onboarding flag without importing the data-layer model.
  static bool _needsOnboarding(dynamic profile) {
    try {
      return profile.needsOnboarding as bool;
    } catch (_) {
      return false;
    }
  }
}