import 'package:equatable/equatable.dart';

/// The compulsory student profile form (Manual §4.1).
///
/// *"Profile form — Pops up automatically after verification. A short
/// compulsory form (school, batch, guardian details). Cannot be skipped."*
///
/// The fields mirror `CompleteStudentOnboardingDTO` in the live API exactly,
/// including the three consent booleans the student must accept.
class StudentProfileEntity extends Equatable {
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;

  /// Bangladeshi mobile number — 11 digits starting `01`, or `+880…`.
  final String? mobileNumber;

  /// Education board, e.g. "Dhaka".
  final String? board;

  /// School / college name.
  final String? institution;

  /// Year the student sits SSC, e.g. "2027".
  final String? sscExamYear;

  final String? thana;
  final String? district;

  final String? guardianName;
  final String? motherName;
  final String? guardianPhone;
  final String? parentEmail;
  final String? guardianOccupation;

  /// How the student heard about Nirvoor.
  final String? referralSource;

  /// Consent: the information given is correct.
  final bool agreedInfoCorrect;

  /// Consent: data may be stored.
  final bool agreedDataStorage;

  /// Consent: receive notifications.
  final bool agreedNotifications;

  // ── Editable profile extras (UpdateStudentProfileDTO) ─────────────────
  final String? phone;
  final String? bio;
  final String? address;
  final String? classOrGrade;
  final String? facebookLink;
  final String? linkedInLink;

  const StudentProfileEntity({
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.mobileNumber,
    this.board,
    this.institution,
    this.sscExamYear,
    this.thana,
    this.district,
    this.guardianName,
    this.motherName,
    this.guardianPhone,
    this.parentEmail,
    this.guardianOccupation,
    this.referralSource,
    this.agreedInfoCorrect = false,
    this.agreedDataStorage = false,
    this.agreedNotifications = false,
    this.phone,
    this.bio,
    this.address,
    this.classOrGrade,
    this.facebookLink,
    this.linkedInLink,
  });

  /// True when every field required by the onboarding endpoint is present.
  bool get isCompleteForOnboarding {
    return (fullName?.isNotEmpty ?? false) &&
        (mobileNumber?.isNotEmpty ?? false) &&
        (institution?.isNotEmpty ?? false) &&
        (guardianName?.isNotEmpty ?? false) &&
        (guardianPhone?.isNotEmpty ?? false) &&
        agreedInfoCorrect &&
        agreedDataStorage;
  }

  /// Validates a Bangladeshi mobile number (Manual §4.1).
  ///
  /// *"Mobile must be a real Bangladeshi number (11 digits starting 01, or
  /// +880…)."*
  static bool isValidBdMobile(String? value) {
    if (value == null) return false;
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (RegExp(r'^01[3-9]\d{8}$').hasMatch(cleaned)) return true;
    if (RegExp(r'^\+8801[3-9]\d{8}$').hasMatch(cleaned)) return true;
    return false;
  }

  /// Payload for `POST /api/Student/complete-onboarding`.
  Map<String, dynamic> toOnboardingJson() => {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'mobileNumber': mobileNumber,
        'board': board,
        'institution': institution,
        'sscExamYear': sscExamYear,
        'thana': thana,
        'district': district,
        'guardianName': guardianName,
        'motherName': motherName,
        'guardianPhone': guardianPhone,
        'parentEmail': parentEmail,
        'guardianOccupation': guardianOccupation,
        'referralSource': referralSource,
        'agreedInfoCorrect': agreedInfoCorrect,
        'agreedDataStorage': agreedDataStorage,
        'agreedNotifications': agreedNotifications,
      };

  /// Payload for `PUT /api/Student/update-profile`.
  Map<String, dynamic> toUpdateJson() => {
        'fullName': fullName,
        'phone': phone,
        'bio': bio,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'address': address,
        'institution': institution,
        'classOrGrade': classOrGrade,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'facebookLink': facebookLink,
        'linkedInLink': linkedInLink,
      };

  /// Creates a copy with selected fields replaced (used by the onboarding form).
  StudentProfileEntity copyWith({
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? mobileNumber,
    String? board,
    String? institution,
    String? sscExamYear,
    String? thana,
    String? district,
    String? guardianName,
    String? motherName,
    String? guardianPhone,
    String? parentEmail,
    String? guardianOccupation,
    String? referralSource,
    bool? agreedInfoCorrect,
    bool? agreedDataStorage,
    bool? agreedNotifications,
    String? phone,
    String? bio,
    String? address,
    String? classOrGrade,
    String? facebookLink,
    String? linkedInLink,
  }) {
    return StudentProfileEntity(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      board: board ?? this.board,
      institution: institution ?? this.institution,
      sscExamYear: sscExamYear ?? this.sscExamYear,
      thana: thana ?? this.thana,
      district: district ?? this.district,
      guardianName: guardianName ?? this.guardianName,
      motherName: motherName ?? this.motherName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      guardianOccupation: guardianOccupation ?? this.guardianOccupation,
      referralSource: referralSource ?? this.referralSource,
      agreedInfoCorrect: agreedInfoCorrect ?? this.agreedInfoCorrect,
      agreedDataStorage: agreedDataStorage ?? this.agreedDataStorage,
      agreedNotifications: agreedNotifications ?? this.agreedNotifications,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      classOrGrade: classOrGrade ?? this.classOrGrade,
      facebookLink: facebookLink ?? this.facebookLink,
      linkedInLink: linkedInLink ?? this.linkedInLink,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        gender,
        mobileNumber,
        board,
        institution,
        sscExamYear,
        thana,
        district,
        guardianName,
        motherName,
        guardianPhone,
        parentEmail,
        guardianOccupation,
        referralSource,
        agreedInfoCorrect,
        agreedDataStorage,
        agreedNotifications,
        phone,
        bio,
        address,
        classOrGrade,
        facebookLink,
        linkedInLink,
      ];
}