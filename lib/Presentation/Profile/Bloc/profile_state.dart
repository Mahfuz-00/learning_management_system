import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/student_profile_entity.dart';

/// Load status for the profile screen.
enum ProfileStatus { initial, loading, loaded, saving, error }

/// State of the student profile / onboarding flow.
class ProfileState extends Equatable {
  final ProfileStatus status;

  /// The student's profile as returned by the server.
  final StudentProfileEntity? profile;

  /// True when the compulsory onboarding form still has to be completed.
  ///
  /// Manual §4.1: the form *"pops up automatically after verification... Cannot
  /// be skipped."* The router uses this flag to force the student onto the
  /// onboarding screen.
  final bool needsOnboarding;

  final String? errorMessage;

  /// One-shot success flag for a snackbar.
  final bool actionSucceeded;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.needsOnboarding = false,
    this.errorMessage,
    this.actionSucceeded = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    StudentProfileEntity? profile,
    bool? needsOnboarding,
    String? errorMessage,
    bool? actionSucceeded,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSucceeded: actionSucceeded ?? this.actionSucceeded,
    );
  }

  @override
  List<Object?> get props =>
      [status, profile, needsOnboarding, errorMessage, actionSucceeded];
}