/// Central registry of every backend route used by the mobile client.
///
/// **Why this file exists**
/// The previous implementation hard-coded route strings inside each data source.
/// Several of those strings did not match the live API (wrong casing / renamed
/// routes), producing silent 404s that were very hard to trace. Every route now
/// lives here, verified against `https://api.nirvoor.com/swagger/v1/swagger.json`
/// (261 paths). If a backend route changes, exactly one line changes here.
///
/// Note: [AppConstants.baseUrl] already ends with `/api/`, therefore the paths
/// below intentionally omit the `/api` prefix.
class ApiRoutes {
  ApiRoutes._();

  // ─────────────────────────────────────────────────────────────
  // Auth / Register  (spec tag: "Register")
  // ─────────────────────────────────────────────────────────────

  /// Primary login route. `/api/Register/Login` and `/api/app/login` both exist;
  /// `/api/app/login` is the mobile-oriented alias. Both accept [LoginDTO].
  static const String login = 'Register/Login';

  /// Mobile-specific login alias (identical payload).
  static const String mobileLogin = 'app/login';

  /// Student/teacher self-registration. Body: RegisterDTO.
  static const String register = 'Register/Register';

  /// Refreshes an expiring JWT. Called by the Dio 401 interceptor.
  static const String refresh = 'Register/Refresh';

  /// Returns the currently authenticated user's profile.
  static const String profile = 'Register/Profile';

  /// Confirms the 6-digit e-mail code sent after student sign-up.
  /// Body: VerifyEmailDTO { email, otp }.
  static const String verifyEmail = 'Register/verify-email';

  /// Re-sends the verification code (available 60s after the previous one).
  static const String resendVerification = 'Register/resend-verification';

  /// Change password while logged in. Body: ChangePasswordDTO.
  static const String changePassword = 'Register/change-password';

  /// Resolves a teacher invitation token (public — no auth header required).
  static String invite(String token) => 'Register/invite/$token';

  /// Account deletion impact preview + execution (GDPR-style flow).
  static const String accountDeleteImpact = 'Register/account/delete-impact';
  static const String accountDelete = 'Register/account/delete';

  // ─────────────────────────────────────────────────────────────
  // Password reset  (spec tag: "PasswordReset")
  // ─────────────────────────────────────────────────────────────

  /// Step 1 — request a reset code by e-mail.
  static const String passwordResetRequest = 'PasswordReset/request';

  /// Step 2 — verify the reset code.
  static const String passwordResetVerify = 'PasswordReset/verify-code';

  /// Step 3 — set the new password (PUT).
  static const String passwordResetReset = 'PasswordReset/reset';

  // ─────────────────────────────────────────────────────────────
  // Student profile / onboarding  (spec tag: "Student")
  // ─────────────────────────────────────────────────────────────

  static const String studentMe = 'Student/me';

  /// Compulsory profile form shown right after e-mail verification (Manual §4.1).
  static const String studentCompleteOnboarding = 'Student/complete-onboarding';
  static const String studentUpdateProfile = 'Student/update-profile';
  static const String studentUploadProfileImage = 'Student/upload-profile-image';

  // ─────────────────────────────────────────────────────────────
  // User preference wizard  (spec tag: "UserPreference")
  // ─────────────────────────────────────────────────────────────

  static const String userPreference = 'UserPreference';

  // ─────────────────────────────────────────────────────────────
  // Courses
  // ─────────────────────────────────────────────────────────────

  /// Catalogue. Sorting + paging are server-side (Manual §4.2).
  static const String allCourses = 'Course/GetAll';
  static const String teacherCourses = 'Course/GetByTeacher';
  static String courseById(String id) => 'Course/GetById/$id';
  static String courseTeachers(String id) => 'Course/$id/teachers';

  /// Real vs. marketing counts (Rule 5).
  static String courseStats(String id) => 'Course/$id/stats';

  static const String createCourse = 'Course/Create';
  static String updateCourse(String id) => 'Course/Update/$id';
  static String deleteCourse(String id) => 'Course/Delete/$id';
  static String deleteCourseImpact(String id) => 'Course/delete-impact/$id';
  static String uploadCourseThumbnail(String id) => 'Course/UploadThumbnail/$id';

  /// Marks a course complete (issues certificate eligibility).
  static String completeCourse(String id) => 'Course/Complete/$id';

  /// Manual ordering of the catalogue (admin-authored order).
  static const String reorderCourses = 'Course/Reorder';

  // ─────────────────────────────────────────────────────────────
  // Lessons
  // ─────────────────────────────────────────────────────────────

  static String lessonsByCourse(String courseId) => 'Lesson/GetByCourse/$courseId';
  static String lessonById(String id) => 'Lesson/GetById/$id';
  static const String createLesson = 'Lesson/Create';
  static String updateLesson(String id) => 'Lesson/Update/$id';
  static String deleteLesson(String id) => 'Lesson/Delete/$id';
  static String uploadLessonThumbnail(String id) => 'Lesson/UploadThumbnail/$id';
  static String uploadLessonVideo(String id) => 'Lesson/UploadVideo/$id';
  static String setLessonVideoUrl(String id) => 'Lesson/SetVideoUrl/$id';

  // ─────────────────────────────────────────────────────────────
  // Enrollment
  // ─────────────────────────────────────────────────────────────

  static const String enroll = 'Enrollment/create';

  /// Course-scoped enrollment info. NOTE: this is NOT the current user's own
  /// enrollment status — use [myEnrollments] for that.
  static String enrollmentByCourse(String courseId) => 'Enrollment/by-course/$courseId';
  static String enrollmentCount(String courseId) => 'Enrollment/count/$courseId';
  static const String myEnrollments = 'Enrollment/my-enrollments';
  static String enrolledStudents(String courseId) => 'Enrollment/students/$courseId';

  // ─────────────────────────────────────────────────────────────
  // Quiz
  // ─────────────────────────────────────────────────────────────

  static String quizByLesson(String lessonId) => 'quiz/getbylesson/$lessonId';
  static String addQuiz(String lessonId) => 'quiz/add/$lessonId';
  static String deleteQuiz(String quizId) => 'quiz/delete/$quizId';
  static String hasAttemptedQuiz(String lessonId, String userId) =>
      'quiz/hasattempted/$lessonId/$userId';
  static String quizProgress(String lessonId, String userId) =>
      'quiz/progress/$lessonId/$userId';
  static String quizOverallProgress(String userId) => 'quiz/overall-progress/$userId';
  static String submitQuiz(String lessonId) => 'quiz/submit/$lessonId';
  static const String quizLeaderboard = 'quiz/leaderboard';
  static String quizLeaderboardByCourse(String courseId) => 'quiz/leaderboard/course/$courseId';

  // ─────────────────────────────────────────────────────────────
  // Video progress / watch history  (Manual §4.3)
  // ─────────────────────────────────────────────────────────────

  static String saveVideoProgress(String lessonId) => 'VideoProgress/save/$lessonId';
  static String getVideoProgress(String lessonId, String userId) =>
      'VideoProgress/get/$lessonId/$userId';

  /// Full watch history (newest first) + delete + restore.
  static String watchHistory(String userId) => 'VideoProgress/history/$userId';
  static String watchHistoryItem(String userId, String lessonId) =>
      'VideoProgress/history/$userId/$lessonId';
  static String restoreWatchHistoryItem(String userId, String lessonId) =>
      'VideoProgress/history/$userId/$lessonId/restore';

  /// Recording watch progress (live-class recordings behave like lessons).
  static String saveRecordingProgress(String liveClassId) =>
      'VideoProgress/recording/save/$liveClassId';
  static String getRecordingProgress(String liveClassId) =>
      'VideoProgress/recording/get/$liveClassId';
  static String deleteRecordingHistory(String userId, String liveClassId) =>
      'VideoProgress/history/$userId/recording/$liveClassId';
  static String restoreRecordingHistory(String userId, String liveClassId) =>
      'VideoProgress/history/$userId/recording/$liveClassId/restore';

  /// Free-live recording progress (public namespace).
  static String saveFreeRecordingProgress(String freeLiveClassId) =>
      'VideoProgress/free-recording/save/$freeLiveClassId';
  static String getFreeRecordingProgress(String freeLiveClassId) =>
      'VideoProgress/free-recording/get/$freeLiveClassId';
  static String deleteFreeRecordingHistory(String userId, String freeLiveClassId) =>
      'VideoProgress/history/$userId/free-recording/$freeLiveClassId';
  static String restoreFreeRecordingHistory(String userId, String freeLiveClassId) =>
      'VideoProgress/history/$userId/free-recording/$freeLiveClassId/restore';

  // ─────────────────────────────────────────────────────────────
  // Progress  (weighted: video 40 / quiz 15 / exam 15 / live 20 / attendance 10)
  // ─────────────────────────────────────────────────────────────

  static const String myProgress = 'Progress/my';
  static const String myPerformance = 'Progress/performance';
  static String courseStudentProgress(String courseId) => 'Progress/course/$courseId/students';

  // ─────────────────────────────────────────────────────────────
  // Live class  (paid — requires login + enrollment)
  // ─────────────────────────────────────────────────────────────

  static const String createLiveClass = 'LiveClass/create';
  static String startLiveClass(String id) => 'LiveClass/start/$id';
  static String endLiveClass(String id) => 'LiveClass/end/$id';
  static String joinLiveClass(String id) => 'LiveClass/join/$id';
  static String liveClassesByCourse(String courseId) => 'LiveClass/course/$courseId';
  static const String myActiveLiveClasses = 'LiveClass/my-active';

  /// Teacher uploads a browser-recorded file here (Rule 11).
  static String uploadRecording(String id) => 'LiveClass/recording/$id';
  static String recordingsByCourse(String courseId) => 'LiveClass/course/$courseId/recordings';
  static String updateLiveClass(String id) => 'LiveClass/$id';
  static String deleteLiveClass(String id) => 'LiveClass/$id';

  // ─────────────────────────────────────────────────────────────
  // Free live class  (Rule 12 — fully public, NO auth required)
  // ─────────────────────────────────────────────────────────────

  static const String freeLiveStart = 'LiveClass/free/start';
  static const String freeLiveSchedule = 'LiveClass/free/schedule';
  static String freeLiveStartById(String id) => 'LiveClass/free/start/$id';
  static const String freeLiveActive = 'LiveClass/free/active';
  static String freeLiveJoin(String id) => 'LiveClass/free/join/$id';
  static const String freeLiveMine = 'LiveClass/free/mine';
  static String freeLiveEnd(String id) => 'LiveClass/free/end/$id';
  static String freeLiveUploadRecording(String id) => 'LiveClass/free/recording/$id';
  static String freeLiveById(String id) => 'LiveClass/free/$id';
  static String freeLiveRecordingsByCourse(String courseId) =>
      'LiveClass/free/course/$courseId/recordings';
  static String freeLiveActiveByCourse(String courseId) =>
      'LiveClass/free/course/$courseId/active';
  static String freeLiveCount(String courseId) => 'LiveClass/free/count/$courseId';

  /// "Notify me" interest list for free classes.
  static String freeLiveInterest(String courseId) => 'LiveClass/free/interest/$courseId';
  static const String myFreeLiveInterests = 'LiveClass/free/my-interests';

  // ─────────────────────────────────────────────────────────────
  // Course exam  (Manual §4.4 — 4 slots: 1st, 2nd, 3rd, Final)
  // ─────────────────────────────────────────────────────────────

  static String examsByCourse(String courseId) => 'Exam/course/$courseId';
  static const String createExam = 'Exam/create';

  /// Uploading the question file is what OPENS the exam for students.
  static String uploadExamQuestion(String examId) => 'Exam/upload-question/$examId';
  static String updateExam(String examId) => 'Exam/update/$examId';
  static String deleteExam(String examId) => 'Exam/delete/$examId';
  static String examQuestion(String examId) => 'Exam/question/$examId';
  static String submitExam(String examId) => 'Exam/submit/$examId';
  static const String myExamPerformance = 'Exam/my-performance';
  static String myExamAnswer(String examId) => 'Exam/my-answer/$examId';

  /// Teacher grading queue.
  static String examSubmissions(String examId) => 'Exam/$examId/submissions';
  static String examSubmissionFile(String submissionId) => 'Exam/submission-file/$submissionId';
  static String gradeExam(String submissionId) => 'Exam/grade/$submissionId';

  // ─────────────────────────────────────────────────────────────
  // Live-class exam  (Google-Forms style — TEACHER ONLY, Rule 10)
  // ─────────────────────────────────────────────────────────────

  static String liveExamByLiveClass(String liveClassId) => 'LiveExam/live-class/$liveClassId';
  static String liveExamManage(String liveClassId) => 'LiveExam/live-class/$liveClassId/manage';
  static const String liveExamUploadQuestionFile = 'LiveExam/upload-question-file';
  static String liveExamSave(String liveClassId) => 'LiveExam/save/$liveClassId';
  static String liveExamPublish(String examId) => 'LiveExam/publish/$examId';
  static String liveExamClose(String examId) => 'LiveExam/close/$examId';
  static String deleteLiveExam(String examId) => 'LiveExam/$examId';
  static String liveExamCourseSummary(String courseId) => 'LiveExam/course/$courseId/summary';
  static String liveExamSubmissions(String examId) => 'LiveExam/$examId/submissions';
  static String liveExamSubmission(String submissionId) => 'LiveExam/submission/$submissionId';
  static String gradeLiveExam(String submissionId) => 'LiveExam/grade/$submissionId';
  static String availableLiveExams(String courseId) => 'LiveExam/course/$courseId/available';
  static String takeLiveExam(String examId) => 'LiveExam/$examId/take';
  static String startLiveExam(String examId) => 'LiveExam/$examId/start';
  static String submitLiveExam(String examId) => 'LiveExam/$examId/submit';
  static String liveExamAnswerFile(String answerId) => 'LiveExam/answer-file/$answerId';

  // ─────────────────────────────────────────────────────────────
  // AI writing task  (Manual §4.4 — handwriting OCR, mark out of 100)
  // ─────────────────────────────────────────────────────────────

  static String aiWritingByCourse(String courseId) => 'AiWriting/course/$courseId';
  static String aiWritingTask(String taskId) => 'AiWriting/task/$taskId';
  static const String createAiWriting = 'AiWriting/create';
  static String updateAiWriting(String id) => 'AiWriting/update/$id';
  static String publishAiWriting(String id) => 'AiWriting/publish/$id';
  static String deleteAiWriting(String id) => 'AiWriting/delete/$id';
  static const String submitAiWriting = 'AiWriting/submit';
  static String aiWritingSubmissions(String taskId) => 'AiWriting/submissions/$taskId';
  static String gradeAiWriting(String submissionId) => 'AiWriting/grade/$submissionId';
  static String aiWritingFile(String submissionId) => 'AiWriting/file/$submissionId';

  // ─────────────────────────────────────────────────────────────
  // Practice material + suggestions  (hub cards, Manual §4.3)
  // ─────────────────────────────────────────────────────────────

  static String practiceByCourse(String courseId) => 'Practice/course/$courseId';
  static const String createPractice = 'Practice/create';
  static String updatePractice(String id) => 'Practice/update/$id';
  static String deletePractice(String id) => 'Practice/delete/$id';

  /// Streams the file for the built-in viewer (never opens a blank tab).
  static String practiceFile(String id) => 'Practice/file/$id';

  // ─────────────────────────────────────────────────────────────
  // Payments / checkout  (SSLCommerz — Manual §4.2, Rule 4)
  // ─────────────────────────────────────────────────────────────

  static const String initiatePayment = 'Payment/initiate';

  /// **Single source of truth for discounting (Rule 4).** Returns the applied
  /// discount plus the losing offers so the UI can grey them out.
  static const String paymentQuote = 'Payment/quote';
  static const String paymentIpn = 'Payment/ipn';
  static const String paymentSuccess = 'Payment/success';
  static const String paymentFail = 'Payment/fail';
  static const String paymentCancel = 'Payment/cancel';
  static String paymentStatus(String transactionId) => 'Payment/status/$transactionId';
  static const String heldPayments = 'Payment/held';
  static String releaseHeldPayment(String transactionId) => 'Payment/held/$transactionId/release';

  // ─────────────────────────────────────────────────────────────
  // Coupons + corporate discounts  (Rule 4)
  // ─────────────────────────────────────────────────────────────

  static const String validateCoupon = 'Coupon/validate';
  static String corporateCouponsForCourse(String courseId) => 'CorporateCoupon/course/$courseId';
  static const String validateCorporateCoupon = 'CorporateCoupon/validate';

  // ─────────────────────────────────────────────────────────────
  // Refunds  (Rule 9 — approval deletes the enrollment)
  // ─────────────────────────────────────────────────────────────

  static String refundEligibility(String courseId) => 'Refund/eligibility/$courseId';
  static const String requestRefund = 'Refund/request';
  static const String myRefunds = 'Refund/my';
  static String cancelRefund(String id) => 'Refund/my/$id/cancel';

  // ─────────────────────────────────────────────────────────────
  // Wishlist
  // ─────────────────────────────────────────────────────────────

  static const String wishlistCounts = 'Wishlist/counts';
  static String wishlist(String userId) => 'Wishlist/$userId';
  static String checkWishlist(String courseId, String userId) => 'Wishlist/check/$courseId/$userId';
  static String toggleWishlist(String courseId, String userId) => 'Wishlist/toggle/$courseId/$userId';

  // ─────────────────────────────────────────────────────────────
  // Certificates
  // ─────────────────────────────────────────────────────────────

  static const String issueCertificate = 'Certificate/issue';
  static String myCertificates(String userId) => 'Certificate/my/$userId';
  static String courseCertificates(String courseId) => 'Certificate/course/$courseId';

  // ─────────────────────────────────────────────────────────────
  // Announcements / Notifications
  // ─────────────────────────────────────────────────────────────

  static const String activeAnnouncements = 'Announcement/active';
  static const String allAnnouncements = 'Announcement/all';
  static const String createAnnouncement = 'Announcement/create';
  static String deactivateAnnouncement(String id) => 'Announcement/deactivate/$id';
  static String deleteAnnouncement(String id) => 'Announcement/delete/$id';

  static const String myNotifications = 'Notification/my';
  static const String unreadNotificationCount = 'Notification/unread-count';
  static String readNotification(String id) => 'Notification/read/$id';
  static const String readAllNotifications = 'Notification/read-all';

  // ─────────────────────────────────────────────────────────────
  // Instructors / ratings / comments / evaluation
  // ─────────────────────────────────────────────────────────────

  static const String allInstructors = 'Instructor/all';
  static String instructorProfile(String teacherId) => 'Instructor/$teacherId';
  static const String myInstructorProfile = 'Instructor/me';
  static const String updateInstructorProfile = 'Instructor/update-profile';
  static const String uploadInstructorImage = 'Instructor/upload-profile-image';

  static const String addRating = 'CourseRating/add';
  static String myRating(String courseId, String userId) => 'CourseRating/$courseId/$userId';
  static String ratingSummary(String courseId) => 'CourseRating/summary/$courseId';
  static String myRatings(String userId) => 'CourseRating/my-ratings/$userId';
  static String deleteRating(String ratingId, String userId) => 'CourseRating/$ratingId/$userId';

  static String courseComments(String courseId) => 'CourseComment/course/$courseId';
  static String commentById(String commentId) => 'CourseComment/$commentId';
  static String commentsByUser(String userId) => 'CourseComment/user/$userId';
  static const String addComment = 'CourseComment/add';
  static String updateComment(String commentId) => 'CourseComment/update/$commentId';
  static String deleteComment(String commentId) => 'CourseComment/delete/$commentId';

  /// Anonymous teacher evaluation (Manual §4.4).
  static const String submitTeacherEvaluation = 'TeacherEvaluation/submit';
  static String myTeacherEvaluation(String courseId) => 'TeacherEvaluation/mine/$courseId';

  // ─────────────────────────────────────────────────────────────
  // Store  (books & items — Manual §4.5)
  // ─────────────────────────────────────────────────────────────

  static const String storeItems = 'Store/items';
  static const String addStoreItem = 'Store/add';
  static String uploadStoreImage(String itemId) => 'Store/upload-image/$itemId';
  static String uploadStorePdf(String itemId) => 'Store/upload-pdf/$itemId';
  static String updateStoreItem(String itemId) => 'Store/update/$itemId';
  static String deleteStoreItem(String itemId) => 'Store/delete/$itemId';
  static String downloadStorePdf(String itemId) => 'Store/download-pdf/$itemId';
  static String viewStorePdf(String itemId) => 'Store/view-pdf/$itemId';
  static String myStoreDownloads(String itemId) => 'Store/my-download/$itemId';

  static const String initiateStorePurchase = 'store/purchase/initiate';
  static const String myStorePurchases = 'store/purchase/my';
  static String storePurchaseStatus(String transactionId) =>
      'store/purchase/status/$transactionId';

  // ─────────────────────────────────────────────────────────────
  // Secure media streaming  (token-protected, link cannot be shared)
  // ─────────────────────────────────────────────────────────────

  /// Issues the short-lived token required by [streamFile].
  static const String videoToken = 'Files/video-token';
  static const String hlsPlaylist = 'Files/hls/playlist';
  static const String hlsSegment = 'Files/hls/segment';
  static const String streamFile = 'Files/Stream';
  static const String downloadFile = 'Files/Download';

  // ─────────────────────────────────────────────────────────────
  // Pre-booking  (Rule 3 — "Coming soon" courses)
  // ─────────────────────────────────────────────────────────────

  static const String preBooking = 'PreBooking';

  // ─────────────────────────────────────────────────────────────
  // Support
  // ─────────────────────────────────────────────────────────────

  static const String supportTicket = 'Support/ticket';
}