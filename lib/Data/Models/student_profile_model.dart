import '../../Domain/Entities/student_profile_entity.dart';
import 'json_utils.dart';

/// JSON mapping for the student profile (Manual §4.1).
class StudentProfileModel extends StudentProfileEntity {
  /// True when the server reports onboarding is still outstanding.
  ///
  /// Accepts several plausible flag names because the response schema is
  /// untyped in the spec. When every flag is absent it defaults to `false`, so a
  /// missing field never traps the user in an onboarding loop.
  final bool needsOnboarding;

  const StudentProfileModel({
    this.needsOnboarding = false,
    super.fullName,
    super.dateOfBirth,
    super.gender,
    super.mobileNumber,
    super.board,
    super.institution,
    super.sscExamYear,
    super.thana,
    super.district,
    super.guardianName,
    super.motherName,
    super.guardianPhone,
    super.parentEmail,
    super.guardianOccupation,
    super.referralSource,
    super.agreedInfoCorrect,
    super.agreedDataStorage,
    super.agreedNotifications,
    super.phone,
    super.bio,
    super.address,
    super.classOrGrade,
    super.facebookLink,
    super.linkedInLink,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      fullName: JsonUtils.toStringOrNull(json['fullName']),
      dateOfBirth: JsonUtils.toStringOrNull(json['dateOfBirth']),
      gender: JsonUtils.toStringOrNull(json['gender']),
      mobileNumber: JsonUtils.toStringOrNull(json['mobileNumber'] ?? json['phone']),
      board: JsonUtils.toStringOrNull(json['board']),
      institution: JsonUtils.toStringOrNull(json['institution']),
      sscExamYear: JsonUtils.toStringOrNull(json['sscExamYear']),
      thana: JsonUtils.toStringOrNull(json['thana']),
      district: JsonUtils.toStringOrNull(json['district']),
      guardianName: JsonUtils.toStringOrNull(json['guardianName']),
      motherName: JsonUtils.toStringOrNull(json['motherName']),
      guardianPhone: JsonUtils.toStringOrNull(json['guardianPhone']),
      parentEmail: JsonUtils.toStringOrNull(json['parentEmail']),
      guardianOccupation: JsonUtils.toStringOrNull(json['guardianOccupation']),
      referralSource: JsonUtils.toStringOrNull(json['referralSource']),
      agreedInfoCorrect: JsonUtils.toBool(json['agreedInfoCorrect']),
      agreedDataStorage: JsonUtils.toBool(json['agreedDataStorage']),
      agreedNotifications: JsonUtils.toBool(json['agreedNotifications']),
      phone: JsonUtils.toStringOrNull(json['phone']),
      bio: JsonUtils.toStringOrNull(json['bio']),
      address: JsonUtils.toStringOrNull(json['address']),
      classOrGrade: JsonUtils.toStringOrNull(json['classOrGrade']),
      facebookLink: JsonUtils.toStringOrNull(json['facebookLink']),
      linkedInLink: JsonUtils.toStringOrNull(json['linkedInLink']),
      needsOnboarding: _resolveNeedsOnboarding(json),
    );
  }

  /// Determines whether the compulsory profile form still has to be shown.
  ///
  /// If the server explicitly reports an onboarding flag, that wins. Otherwise
  /// we infer it from the data: a profile with no institution **and** no
  /// guardian name has clearly never been through the form (Manual §4.1).
  static bool _resolveNeedsOnboarding(Map<String, dynamic> json) {
    final explicit = json['needsOnboarding'] ??
        json['isOnboardingComplete'] ??
        json['hasCompletedOnboarding'];
    if (explicit != null) {
      // `isOnboardingComplete: true` means NO onboarding is needed.
      final value = JsonUtils.toBool(explicit);
      if (json.containsKey('isOnboardingComplete') ||
          json.containsKey('hasCompletedOnboarding')) {
        return !value;
      }
      return value;
    }

    final institution = JsonUtils.toStringValue(json['institution']);
    final guardian = JsonUtils.toStringValue(json['guardianName']);
    return institution.isEmpty && guardian.isEmpty;
  }
}