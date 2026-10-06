import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../Entities/student_profile_entity.dart';
import '../Entities/user_entity.dart';

/// Domain contract for authentication and the student account lifecycle.
///
/// Implemented in the data layer by `AuthRepositoryImpl`, which maps thrown
/// exceptions into [Failure] values. Nothing above this interface ever sees an
/// exception.
abstract class AuthRepository {
  /// Authenticates and persists the JWT + user profile locally.
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Registers a student or teacher.
  ///
  /// Teachers created this way are **locked** until an admin approves them
  /// (Manual §5.1), so the caller must route to the pending-approval screen
  /// rather than the dashboard.
  Future<Either<Failure, Unit>> register(Map<String, dynamic> signupData);

  /// Fetches the authenticated user's profile.
  Future<Either<Failure, UserEntity>> getProfile();

  /// True when a non-empty JWT is cached locally.
  Future<Either<Failure, bool>> isUserLoggedIn();

  /// Clears the session (token + cached user) and any user-scoped cache.
  Future<void> logout();

  // ── E-mail verification (Manual §4.1) ──────────────────────────────────

  /// Confirms the 6-digit code e-mailed after student sign-up.
  /// Teachers skip this step entirely.
  Future<Either<Failure, Unit>> verifyEmail(String email, String otp);

  /// Re-sends the verification code. The UI enforces the 60-second cooldown.
  Future<Either<Failure, Unit>> resendVerification(String email);

  // ── Password recovery (3 steps) ────────────────────────────────────────

  /// Step 1 — requests a reset code by e-mail.
  Future<Either<Failure, Unit>> requestPasswordReset(String email);

  /// Step 2 — verifies the reset code.
  Future<Either<Failure, Unit>> verifyPasswordResetCode(String email, String code);

  /// Step 3 — sets the new password.
  Future<Either<Failure, Unit>> resetPassword(
    String email,
    String code,
    String newPassword,
  );

  /// Changes the password while logged in (Settings screen).
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  );

  // ── Student profile & onboarding (Manual §4.1) ─────────────────────────

  /// Reads the student profile, including whether onboarding is outstanding.
  Future<Either<Failure, StudentProfileEntity>> getStudentProfile();

  /// Submits the compulsory post-verification profile form.
  Future<Either<Failure, Unit>> completeOnboarding(StudentProfileEntity profile);

  /// Updates editable profile details from Settings.
  Future<Either<Failure, Unit>> updateStudentProfile(StudentProfileEntity profile);

  // ── Teacher invitation (Manual §5.1) ───────────────────────────────────

  /// Resolves a teacher invitation token (public endpoint).
  /// A teacher registering through an invite is approved **instantly**.
  Future<Either<Failure, Map<String, dynamic>>> resolveInvite(String token);
}