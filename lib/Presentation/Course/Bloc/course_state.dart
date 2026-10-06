import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Domain/Entities/quiz_entity.dart';
import '../../../Domain/Entities/live_class_entity.dart';

enum CourseStatus { initial, loading, loaded, error }

class CourseState extends Equatable {
  final CourseStatus allCoursesStatus;
  final List<CourseEntity> allCourses;
  
  final CourseStatus enrolledStatus;
  final List<CourseEntity> enrolledCourses;
  
  final CourseStatus teacherStatus;
  final List<CourseEntity> teacherCourses;
  
  final CourseStatus detailsStatus;
  final CourseEntity? selectedCourse;
  final List<LessonEntity> lessons;
  final List<LiveClassEntity> liveClasses;
  
  /// Past live classes the teacher uploaded (the Recordings hub card).
  final List<LiveClassEntity> recordings;

  /// The signed-in student's saved courses.
  final List<CourseEntity> wishlist;
  final CourseStatus wishlistStatus;

  final QuizEntity? activeQuiz;
  final CourseStatus quizStatus;

  /// True when the student has already sat the active quiz.
  final bool hasAttemptedQuiz;

  /// Score from the most recent quiz submission.
  final int? lastQuizScore;
  final int? lastQuizTotal;
  final int? lastQuizCorrect;

  /// Global quiz leaderboard rows.
  final List<dynamic> leaderboard;

  final String? errorMessage;

  /// One-shot flag so the UI can show a snackbar exactly once.
  final bool actionSucceeded;

  /// True while an upload/submit is in flight.
  final bool isSubmitting;

  const CourseState({
    this.allCoursesStatus = CourseStatus.initial,
    this.allCourses = const [],
    this.enrolledStatus = CourseStatus.initial,
    this.enrolledCourses = const [],
    this.teacherStatus = CourseStatus.initial,
    this.teacherCourses = const [],
    this.detailsStatus = CourseStatus.initial,
    this.selectedCourse,
    this.lessons = const [],
    this.liveClasses = const [],
    this.recordings = const [],
    this.wishlist = const [],
    this.wishlistStatus = CourseStatus.initial,
    this.activeQuiz,
    this.quizStatus = CourseStatus.initial,
    this.hasAttemptedQuiz = false,
    this.lastQuizScore,
    this.lastQuizTotal,
    this.lastQuizCorrect,
    this.leaderboard = const [],
    this.errorMessage,
    this.actionSucceeded = false,
    this.isSubmitting = false,
  });

  CourseState copyWith({
    CourseStatus? allCoursesStatus,
    List<CourseEntity>? allCourses,
    CourseStatus? enrolledStatus,
    List<CourseEntity>? enrolledCourses,
    CourseStatus? teacherStatus,
    List<CourseEntity>? teacherCourses,
    CourseStatus? detailsStatus,
    CourseEntity? selectedCourse,
    List<LessonEntity>? lessons,
    List<LiveClassEntity>? liveClasses,
    List<LiveClassEntity>? recordings,
    List<CourseEntity>? wishlist,
    CourseStatus? wishlistStatus,
    QuizEntity? activeQuiz,
    CourseStatus? quizStatus,
    bool? hasAttemptedQuiz,
    int? lastQuizScore,
    int? lastQuizTotal,
    int? lastQuizCorrect,
    List<dynamic>? leaderboard,
    String? errorMessage,
    bool? actionSucceeded,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return CourseState(
      allCoursesStatus: allCoursesStatus ?? this.allCoursesStatus,
      allCourses: allCourses ?? this.allCourses,
      enrolledStatus: enrolledStatus ?? this.enrolledStatus,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      teacherStatus: teacherStatus ?? this.teacherStatus,
      teacherCourses: teacherCourses ?? this.teacherCourses,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      lessons: lessons ?? this.lessons,
      liveClasses: liveClasses ?? this.liveClasses,
      recordings: recordings ?? this.recordings,
      wishlist: wishlist ?? this.wishlist,
      wishlistStatus: wishlistStatus ?? this.wishlistStatus,
      activeQuiz: activeQuiz ?? this.activeQuiz,
      quizStatus: quizStatus ?? this.quizStatus,
      hasAttemptedQuiz: hasAttemptedQuiz ?? this.hasAttemptedQuiz,
      lastQuizScore: lastQuizScore ?? this.lastQuizScore,
      lastQuizTotal: lastQuizTotal ?? this.lastQuizTotal,
      lastQuizCorrect: lastQuizCorrect ?? this.lastQuizCorrect,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSucceeded: actionSucceeded ?? this.actionSucceeded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        allCoursesStatus,
        allCourses,
        enrolledStatus,
        enrolledCourses,
        teacherStatus,
        teacherCourses,
        detailsStatus,
        selectedCourse,
        lessons,
        liveClasses,
        recordings,
        wishlist,
        wishlistStatus,
        activeQuiz,
        quizStatus,
        hasAttemptedQuiz,
        lastQuizScore,
        lastQuizTotal,
        lastQuizCorrect,
        leaderboard,
        errorMessage,
        actionSucceeded,
        isSubmitting,
      ];
}
