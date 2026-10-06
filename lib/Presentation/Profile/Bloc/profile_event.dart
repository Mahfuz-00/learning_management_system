import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/student_profile_entity.dart';

/// Base class for profile and onboarding events.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the student profile and decides whether the compulsory onboarding
/// form must be shown (Manual §4.1).
class LoadStudentProfile extends ProfileEvent {
  const LoadStudentProfile();
}

/// Submits the compulsory post-verification profile form.
class CompleteOnboardingRequested extends ProfileEvent {
  final StudentProfileEntity profile;
  const CompleteOnboardingRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Saves editable profile details from the Settings tab.
class UpdateStudentProfileRequested extends ProfileEvent {
  final StudentProfileEntity profile;
  const UpdateStudentProfileRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Clears the one-shot success flag after the UI shows its snackbar.
class ClearProfileFeedback extends ProfileEvent {
  const ClearProfileFeedback();
}