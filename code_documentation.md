# Nirvoor Learning — Flutter Client Code Documentation

**Project:** `lms_touch_and_solve` (Nirvoor Learning mobile client)
**Platforms:** Flutter (mobile)
**Architecture:** Clean Architecture + BLoC + `get_it` DI + `dio` + `hive` + `go_router`
**Scope:** Student & Teacher panels only (Admin/Super-Admin excluded by design)
**Document version:** 2.0 — 2026-10-05
**Companion docs:** `SYSTEM_USER_MANUAL.md`, `nirvoor_learning_system_developer_prompt.md`, `api_gap_analysis.md`

---

## 0. Implementation Status

This document describes the **implemented** application. The following were built
in this pass and verified:

| Verification | Result |
|---|---|
| `flutter analyze` | **0 errors** (140 info-level `withOpacity` deprecations remain in pre-existing UI code) |
| `flutter test` | **20 / 20 passing** (`test/business_rules_test.dart`) |
| Dart compilation | Verified — the test runner compiles the entire app before executing |

> **Environment note:** `flutter build apk` cannot run on this machine for
> reasons unrelated to the code — Java 25 is installed but the project's Gradle
> 8.12 requires Java 17–21, and the `T&S` ampersand in the Windows username
> breaks Gradle's shell invocation. Both are pre-existing environment issues.
> Dart-level verification (analyze + compile + test) is clean.

### What was implemented

**Business rules now enforced in code**

| Rule | Implementation |
|---|---|
| **R1** Role separation | `AppRouter.redirect` blocks students from `/teacher/*` |
| **R2** Course vanishes after start date | `CourseEntity.isEnrollable` / `isEnrollmentClosed` + "Enrollment closed" UI state |
| **R3** Upcoming = visible, not buyable | `CourseEntity.isUpcoming` / `isComingSoon`; no price, never the word "Free", Buy disabled, "Notify me" instead |
| **R4** Discounts never stack | `CheckoutBloc` delegates entirely to `POST /api/Payment/quote`; losing offers render greyed out |
| **R5** Inflated marketing counts | `marketingEnrollmentCount` vs `realEnrollmentCount`, `displayEnrollmentCount` |
| **R6** Duration in MONTHS | `durationMonths` replaces the misleading `durationMinutes` everywhere |
| **R9** Refund deletes enrollment | `RefundBloc` + explicit Rule 9 warning before submission |
| **R10** Teacher-only live exams | Live-exam write routes gated to teachers by the router |
| **R11** Browser-recorded upload | `CourseBloc.uploadRecording` with a 30-minute timeout |
| **R12** `/free-live` is public | Unguarded route + `DioClient._isPublicRoute` skips the auth header |
| **R13** 8 attempts/minute lockout | `RateLimitFailure` + `DioErrorMapper` parses `Retry-After` |
| Timezone | Wall-clock only; no conversion anywhere |

**New feature modules (previously absent)**

Checkout with Rule 4 pricing · Course exams (4 slots) · Live-class exams (Google-Forms style) · AI writing tasks · Practice & suggestion files · Refunds · Weighted progress · Watch history · Notifications & announcements · Leaderboard · Free live classes · Compulsory onboarding form · Teacher exam grading.

---

## 1. Architecture Overview

The client follows **Uncle Bob's Clean Architecture** with three concentric layers and a strict inward-only dependency rule.

```
┌──────────────────────────────────────────────────────────────┐
│  PRESENTATION (Flutter widgets, BLoCs)                       │
│   • Pages / Widgets  → render state, dispatch events         │
│   • BLoC / Cubit     → orchestrate use cases, emit states    │
│                          │ depends on ▼                      │
├──────────────────────────────────────────────────────────────┤
│  DOMAIN (pure Dart — no Flutter, no Dio, no Hive)            │
│   • Entities         → immutable business objects            │
│   • Repository (abstract) → contracts the data layer fulfils │
│   • Use Cases        → one business action each              │
│                          ▲ implemented by                    │
├──────────────────────────────────────────────────────────────┤
│  DATA (I/O — Dio, Hive)                                      │
│   • Models           → JSON ⇄ Entity mapping                 │
│   • RemoteDataSource → Dio HTTP calls                        │
│   • LocalDataSource  → Hive boxes                            │
│   • RepositoryImpl   → failure mapping, cache strategy       │
└──────────────────────────────────────────────────────────────┘
```

**Why this matters here:** the backend contract is unstable (see `api_gap_analysis.md`). Isolating JSON parsing in `Data/Models` means a backend field rename touches one file, not the UI.

### 1.1 Error handling contract

All repository methods return `Either<Failure, T>` from the `dartz` package (functional `Left`/`Right`).

- `Left(Failure)` → something went wrong (mapped from a thrown exception).
- `Right(value)` → success.

`Failure` hierarchy (`lib/Core/Error/failures.dart`):

| Class | Meaning |
|---|---|
| `ServerFailure` | 4xx/5xx from the API, or unparseable body |
| `CacheFailure` | Hive read/write/open error |
| `NetworkFailure` | No connectivity, timeout, DNS failure |
| `AuthFailure` | 401/403, expired token, locked account |

BLoCs `fold` over the `Either` and emit either a `loaded` or `error` status — **no exceptions ever reach the widget tree**, which is the rule that keeps the app from crashing on a flaky Bangladeshi mobile connection.

---

## 2. Directory Structure

> **Important:** the codebase uses **PascalCase folder names** (`Core/`, `Data/`, `Domain/`, `Presentation/`) rather than the lowercase layout in the master prompt. This document follows the **actual** on-disk layout.

```text
lib/
├── main.dart                          # Entry point: DI init, notifications, AuthCheckRequested
│
├── Core/                              # Cross-cutting concerns (no feature logic)
│   ├── Constants/
│   │   ├── app_constants.dart         # baseUrl, asset paths, Hive box/key names
│   │   ├── api_routes.dart            # EVERY backend route in one place
│   │   └── constants.dart             # misc app-wide constants
│   ├── DI/
│   │   └── injection_container.dart   # get_it registrations (manual, not codegen)
│   ├── Error/
│   │   ├── failures.dart              # Failure classes (incl. RateLimitFailure)
│   │   └── exceptions.dart            # Data-layer exceptions + DioErrorMapper
│   ├── Navigation/
│   │   ├── app_router.dart            # GoRouter config, routes, role guards
│   │   └── router_refresh_stream.dart # Bridges AuthBloc stream → GoRouter refresh
│   ├── Network/
│   │   └── dio_client.dart            # Dio setup, JWT interceptor, token refresh
│   ├── Services/
│   │   └── notification_service.dart  # flutter_local_notifications bootstrap
│   └── Theme/
│       ├── app_colors.dart
│       └── app_theme.dart
│
├── Data/                              # I/O layer
│   ├── DataSources/
│   │   ├── auth_local_data_source.dart      # Hive: token, cached user, preferences
│   │   ├── auth_remote_data_source.dart     # /Register/*, /PasswordReset/*
│   │   ├── student_remote_data_source.dart  # /Student/me, onboarding, profile
│   │   ├── course_remote_data_source.dart   # Course, Lesson, Quiz, Enrollment, ...
│   │   ├── learning_remote_data_source.dart # Exam, LiveExam, AiWriting, Refund,
│   │   │                                    # Payment, Progress, Practice, FreeLive,
│   │   │                                    # Notification, Evaluation, PreBooking
│   │   ├── store_remote_data_source.dart    # Store items
│   │   └── video_local_data_source.dart     # Secure video token fetch
│   ├── Models/                        # JSON ⇄ Entity (extend the Entity)
│   │   ├── json_utils.dart            # Defensive coercion helpers (shared)
│   │   ├── user_model.dart
│   │   ├── student_profile_model.dart
│   │   ├── course_model.dart
│   │   ├── lesson_model.dart
│   │   ├── quiz_model.dart
│   │   ├── live_class_model.dart
│   │   ├── exam_model.dart
│   │   ├── live_exam_model.dart
│   │   ├── ai_writing_model.dart
│   │   ├── payment_model.dart
│   │   ├── refund_model.dart
│   │   ├── progress_model.dart
│   │   ├── practice_model.dart
│   │   ├── notification_model.dart
│   │   ├── teacher_evaluation_model.dart
│   │   ├── certificate_model.dart
│   │   ├── comment_model.dart
│   │   ├── rating_model.dart
│   │   ├── store_item_model.dart
│   │   └── user_preference_model.dart
│   └── Repositories/
│       ├── auth_repository_impl.dart
│       ├── course_repository_impl.dart
│       ├── learning_repository_impl.dart
│       ├── store_repository_impl.dart
│       └── video_repository_impl.dart
│
├── Domain/                            # Pure business layer
│   ├── Entities/                      # Immutable, Equatable
│   │   ├── user_entity.dart
│   │   ├── student_profile_entity.dart     # + BD mobile validation (Manual §4.1)
│   │   ├── course_entity.dart              # Rules 2, 3, 5, 6
│   │   ├── lesson_entity.dart
│   │   ├── quiz_entity.dart
│   │   ├── live_class_entity.dart
│   │   ├── exam_entity.dart                # 4 slots + lifecycle
│   │   ├── live_exam_entity.dart
│   │   ├── ai_writing_entity.dart
│   │   ├── payment_entity.dart             # Rule 4 discount model
│   │   ├── refund_entity.dart              # Rule 9
│   │   ├── progress_entity.dart            # Weighted 40/15/15/20/10
│   │   ├── practice_entity.dart
│   │   ├── notification_entity.dart
│   │   ├── teacher_evaluation_entity.dart
│   │   ├── certificate_entity.dart
│   │   ├── comment_entity.dart
│   │   ├── rating_entity.dart
│   │   ├── store_item_entity.dart
│   │   └── user_preference_entity.dart
│   ├── Repositories/                  # Abstract contracts
│   │   ├── auth_repository.dart
│   │   ├── course_repository.dart
│   │   ├── learning_repository.dart
│   │   ├── store_repository.dart
│   │   └── video_repository.dart
│   └── Usecases/
│       ├── Auth/
│       │   ├── login_usecase.dart
│       │   └── register_usecase.dart
│       └── Course/
│           ├── get_all_courses_usecase.dart
│           ├── get_course_by_id_usecase.dart
│           ├── get_my_courses_usecase.dart
│           ├── get_lessons_by_course_usecase.dart
│           ├── get_quiz_questions_usecase.dart
│           ├── get_teacher_courses_usecase.dart
│           ├── check_enrollment_usecase.dart
│           ├── enroll_in_course_usecase.dart
│           └── toggle_wishlist_usecase.dart
│
└── Presentation/                      # UI + state management
    ├── Auth/
    │   ├── Bloc/  auth_bloc.dart, auth_event.dart, auth_state.dart, preference_bloc.dart
    │   ├── Pages/ splash, login, register, signup_stepper, otp, forgot_password,
    │   │          new_password, success, pending_approval
    │   └── Widgets/ login_widgets, register_widgets, otp_widgets, ...
    ├── Checkout/                      # Rule 4 pricing + SSLCommerz
    │   ├── Bloc/  checkout_bloc, checkout_event, checkout_state
    │   └── Pages/ checkout_page.dart
    ├── Course/
    │   ├── Bloc/  course_bloc, lesson_bloc, quiz_bloc, social_bloc, video_download_bloc
    │   ├── Pages/ course_details, course_hub, enrolled_course_workspace,
    │   │          lesson_player, quiz_player, quiz_results, live_class, live_class_session
    │   └── Widgets/ hub_card.dart, course_details_widgets, lesson_list_view, ...
    ├── FreeLive/                      # Rule 12 — public, no login
    │   └── Pages/ free_live_page.dart
    ├── Learning/                      # Exams, live exams, AI writing, practice
    │   ├── Bloc/  learning_bloc, learning_event, learning_state
    │   └── Pages/ course_exams, exam_submit, exam_submissions, live_exam,
    │              ai_writing_list, ai_writing, practice_viewer,
    │              live_classes_list, recordings_list
    ├── Notifications/
    │   ├── Bloc/  notification_bloc, notification_event, notification_state
    │   └── Pages/ notifications_page.dart, announcements_page.dart
    ├── Profile/
    │   ├── Bloc/  profile_bloc, profile_event, profile_state
    │   └── Pages/ onboarding_page.dart
    ├── Progress/
    │   ├── Bloc/  progress_bloc, progress_event, progress_state
    │   └── Pages/ watch_history_page.dart, leaderboard_page.dart
    ├── Refund/                        # Rule 9
    │   ├── Bloc/  refund_bloc, refund_event, refund_state
    │   └── Pages/ refund_page.dart
    ├── Student/
    │   ├── Bloc/  store_bloc
    │   ├── Pages/ student_main, student_home, student_browse, student_courses,
    │   │          student_wishlist, student_classes, student_profile,
    │   │          student_store, student_certificates
    │   └── Widgets/ course_card, student_home_widgets, student_courses_widgets, ...
    ├── Teacher/
    │   ├── Pages/ teacher_main, teacher_home, teacher_courses, teacher_course_management,
    │   │          teacher_course_details, teacher_create_course, teacher_add_lesson,
    │   │          teacher_add_quiz, teacher_enrolled_students, teacher_student_roster,
    │   │          teacher_schedule_class, teacher_profile
    │   └── Widgets/ teacher_course_card, teacher_course_list_item, teacher_stat_card, ...
    ├── Shared Widgets/ custom_text_field.dart
    └── Widgets/ custom_text_field.dart
```

---

## 3. Dependency Injection

`lib/Core/DI/injection_container.dart` registers everything into a single `GetIt` instance exported as `sl`.

**Registration strategy:**

| Type | Lifetime | Rationale |
|---|---|---|
| `Dio`, `DioClient` | lazy singleton | one connection pool, one interceptor chain |
| Data sources | lazy singleton | stateless, cheap to share |
| Repositories | lazy singleton | hold no per-screen state |
| `AuthBloc` | **singleton** | session state must survive navigation; also read by the router guard |
| Feature BLoCs | factory | a fresh instance per screen (auto-disposed) |

**Note:** the master prompt asks for `injectable` + `build_runner` codegen. The current implementation uses **manual registration**. Manual registration is kept deliberately — it is transparent and avoids a codegen step — but if the graph grows, migrating to `@injectable` is a mechanical change (`@LazySingleton(as: X)`, `@injectable`, `@singleton`).

`init()` order matters:
1. `Hive.initFlutter()`
2. construct + `await authLocalDataSource.init()` (opens the Hive box)
3. register `Dio` → `DioClient`
4. register data sources → repositories
5. register BLoCs

---

## 4. Networking — Dio

`lib/Core/Network/dio_client.dart` builds the single `Dio` instance.

```dart
dio.options.baseUrl        = AppConstants.baseUrl;   // http://160.191.150.185:8071/api/
dio.options.connectTimeout = 30s;
dio.options.receiveTimeout = 30s;
dio.options.responseType   = ResponseType.json;
```

**Interceptor chain (in order):**
1. `LogInterceptor` — request headers/body, response body, errors. Debug aid only; **strip in release builds**.
2. `InterceptorsWrapper`
   - `onRequest` → reads the JWT from `AuthLocalDataSource` and injects `Authorization: Bearer <token>`.
   - `onError` → currently a **stub** for `401`. See §4.2.

### 4.1 Base URL and route strings

`AppConstants.baseUrl` already ends in `/api/`, and data sources call relative paths (`'Course/GetAll'`).

> ⚠️ **Known defect:** several data-source strings use the wrong case/route for the live API (e.g. `register/login` instead of `Register/Login`). Full list in `api_gap_analysis.md` §1. The fix is a central `ApiRoutes` constants class.

### 4.2 Token refresh

The `onError` interceptor now performs a **transparent refresh**:

1. On a `401` for a non-public, non-auth route, call `POST /api/Register/Refresh`.
2. On success, persist the new token and **replay the original request**.
3. On failure, invoke `onSessionExpired` (wired in DI to `AuthBloc.add(LogoutRequested())`), so the router guard sends the user to `/login` cleanly.

A `_isRefreshing` flag plus a `__retried` marker on `RequestOptions.extra`
prevents infinite loops and stops five simultaneous 401s from burning five
attempts against the Rule 13 rate limiter.

---

## 5. Local Caching — Hive

`AuthLocalDataSourceImpl` wraps a single Hive box.

| Item | Key | Notes |
|---|---|---|
| Box | `user_box` | `AppConstants.userBox` |
| JWT | `jwt_token` | `AppConstants.tokenKey` |
| User profile | `user_data` | stored as `Map` via `UserModel.toJson()` |
| Preferences | `user_preferences` | `UserPreferenceModel.toJson()` |

**Design notes:**
- The box is opened once in `init()` and lazily re-opened by `_getBox()` if it was closed — this prevents `HiveError: Box has already been closed` after a hot restart.
- **No Hive type adapters are used.** Everything is stored as plain JSON `Map`/`List`. This deliberately avoids `hive_generator`/`build_runner` and keeps cached data forward-compatible when models gain fields (unknown keys are simply ignored by `fromJson`).
- `clearCache()` calls `box.clear()` — used on logout. **Important:** logout must call this *and* reset the in-memory `AuthBloc` state, otherwise a stale token can be re-sent by the Dio interceptor.

**Caching strategy today:** only identity/session data is cached. **Course lists are not cached.** For offline resilience, add a second box (`courses_box`) with a timestamp and serve stale data on `NetworkFailure` — this is the pattern the master prompt calls a "caching strategy".

---

## 6. State Management — BLoC Flow

### 6.1 Auth flow

```
UI (LoginPage)
   │  context.read<AuthBloc>().add(LoginRequested(email, password))
   ▼
AuthBloc
   │  calls LoginUseCase → AuthRepository.login()
   ▼
AuthRepositoryImpl
   │  AuthRemoteDataSource.login()  → POST Register/Login
   │  on success: AuthLocalDataSource.cacheToken() + cacheUser()
   ▼
Either<Failure, UserEntity>
   │  fold()
   ├── Left  → emit(AuthError(message))
   └── Right → emit(Authenticated(user))
                        │
                        ▼
        GoRouterRefreshStream (listens to AuthBloc.stream)
                        │
                        ▼
        AppRouter.redirect() re-evaluates → /student or /teacher
```

**Key point:** navigation is **not** driven imperatively from the login button. The BLoC emits a new state, `GoRouterRefreshStream` notifies `GoRouter`, and the `redirect` callback performs the navigation. This is the single source of truth for "where am I allowed to be".

`AuthBloc` also handles `AuthCheckRequested`, dispatched from `main()` **before** `runApp` so the splash screen does not hang waiting for a lazy singleton to warm up.

### 6.2 Course flow (representative example)

`CourseBloc` is the largest BLoC and demonstrates the house pattern.

**Events** (`course_event.dart`) → **States** (`course_state.dart`).

| Event | Handler | Effect |
|---|---|---|
| `LoadAllCourses` | `_onLoadAllCourses` | `allCoursesStatus: loading → loaded/error`, sets `allCourses` |
| `LoadTeacherCourses` | `_onLoadTeacherCourses` | `teacherStatus`, `teacherCourses` |
| `LoadMyEnrollments` | `_onLoadMyEnrollments` | `enrolledStatus`, `enrolledCourses` |
| `LoadCourseDetails` | `_onLoadCourseDetails` | `detailsStatus`, `selectedCourse`, `lessons` |
| `EnrollInCourseEvent` | `_onEnrollInCourse` | on success re-dispatches `LoadCourseDetails` + `LoadMyEnrollments` |
| `ToggleWishlistEvent` | `_onToggleWishlist` | on success re-dispatches `LoadAllCourses` |
| `CreateCourseRequested` | `_onCreateCourse` | create → optional thumbnail upload → reload teacher list |
| `AddLessonRequested` | `_onAddLesson` | create lesson → optional video upload → reload details |
| `AddQuizQuestionRequested` | `_onAddQuizQuestion` | `quizStatus` |
| `LoadQuizQuestionsRequested` | `_onLoadQuizQuestions` | `quizStatus` |
| `SubmitQuizRequested` | `_onSubmitQuiz` | `quizStatus` |
| `LoadLiveClassesRequested` | `_onLoadLiveClasses` | `liveClasses` |
| `SaveVideoProgressRequested` | `_onSaveVideoProgress` | fire-and-forget write |

**State shape:** a **single mutable-in-spirit state object** with a `CourseStatus` enum per sub-resource (`allCoursesStatus`, `teacherStatus`, `enrolledStatus`, `detailsStatus`, `quizStatus`). `copyWith` produces the new state; `Equatable` prevents redundant rebuilds. This lets one BLoC back a screen with several independent sections (the course hub) without state races.

**Status enum:** `CourseStatus { initial, loading, loaded, error }` — every UI section renders a spinner, an error banner, or content based on its own status, so one failing section never blanks the whole screen.

### 6.3 BLoC issues found and fixed

These were real defects in the previous implementation. All are now resolved:

| Location | Was | Now |
|---|---|---|
| `CourseBloc._onLoadQuizQuestions` | `fold` branches were empty — `hasAttemptedQuiz` was fetched then discarded | Emits `hasAttemptedQuiz` into state and into `activeQuiz` |
| `CourseBloc._onSubmitQuiz` | Response map discarded; the results page had no data | Parses `score` / `totalQuestions` / `correctAnswers` (tolerant of key variants) |
| `CourseBloc._onSaveVideoProgress` | Ignored the `Either` result entirely | Deliberately still ignores it — a timer-driven save must not interrupt playback (documented) |
| `CourseBloc._onCreateCourse` | A failed thumbnail upload still reported success | Upload result is checked; a partial failure is surfaced honestly |
| `DioClient.onError` | Empty `401` handler | Transparent token refresh + replay, with a concurrency guard |
| `CheckWishlistStatus` event | Declared but never handled — the heart icon could never reflect saved state | Now handled |

---

## 10. Summary of Work Completed

### Critical fixes
1. ✅ Central `ApiRoutes` class — all hard-coded route strings removed.
2. ✅ Auth routes corrected (`Register/Login`, `verify-email`, `PasswordReset/*`).
3. ✅ Token refresh on 401 + clean logout via `onSessionExpired`.
4. ✅ Role guard on `/teacher/*` (Rule 1).
5. ✅ `isUpcoming` / `enrollmentOpensAt` / `startDate` / `endDate` / `isEnrollable` on `CourseEntity`.
6. ✅ `durationMinutes` → `durationMonths` (Rule 6).

### Features implemented
7. ✅ Checkout via `Payment/quote` + Rule 4 discount rendering.
8. ✅ Course exams (4 slots) with question download and answer upload.
9. ✅ Live-class exams (Google-Forms style builder + student sitting view).
10. ✅ AI writing tasks with image capture and attempt history.
11. ✅ Refunds with Rule 9 warnings (Rule 9).
12. ✅ Weighted progress breakdown (40/15/15/20/10).
13. ✅ `/free-live` public route (Rule 12).
14. ✅ Compulsory student onboarding form with BD mobile validation.
15. ✅ Watch history with hide/restore.
16. ✅ Notifications, announcements, leaderboard.
17. ✅ Teacher exam grading queue (with admin read-only mode).
18. ✅ Practice & suggestion file viewer.
19. ✅ Broken BLoC handlers repaired (§6.3).

### Verification
20. ✅ `flutter analyze` — 0 errors.
21. ✅ `flutter test` — 20/20 passing business-rule tests.

### Remaining / out of scope
- `/instructors` static page and `/teacher-evaluation` — not built this pass.
- `courses_box` Hive cache with stale-while-revalidate — not built; only session data is cached.
- Admin/Super-Admin panels — excluded by the master prompt.
- The backend asks in `api_gap_analysis.md` §7 (duration rename, response schemas, 429 `Retry-After`, course-hub composite) remain open on the API side.

---

*End of document.*

## 7. Routing — GoRouter

`lib/Core/Navigation/app_router.dart` defines a single `GoRouter` with:
- `initialLocation: '/'` (splash),
- `refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream)`,
- a global `redirect` guard,
- two `ShellRoute`s (student bottom-nav shell, teacher shell),
- flat routes for course detail, workspace, player, quiz, live class,
- flat routes for teacher management pages.

### 7.1 Route table

| Path | Page | Guard |
|---|---|---|
| `/` | `SplashPage` | always allowed |
| `/login`, `/signup`, `/forgot-password`, `/otp`, `/new-password` | auth pages | only when unauthenticated |
| `/pending-approval` | `PendingApprovalPage` | unapproved teachers |
| `/auth-success` | `SuccessPage` | — |
| **`/free-live`** | `FreeLivePage` | **public — Rule 12** |
| **`/announcements`** | `AnnouncementsPage` | **public** |
| `/onboarding` | `OnboardingPage` | authenticated student (compulsory) |
| `/notifications` | `NotificationsPage` | authenticated |
| `/history` | `WatchHistoryPage` | authenticated |
| `/leaderboard` | `LeaderboardPage` | authenticated |
| `/course/:id` | `CourseDetailsPage` | authenticated |
| `/hub/:id` | `CourseHubPage` | authenticated (extra: `CourseEntity`) |
| `/workspace/:id` | `EnrolledCourseWorkspace` | authenticated (extra: `CourseEntity`) |
| `/lesson-player` | `LessonPlayerPage` | authenticated (extra: `LessonEntity`) |
| `/quiz-player/:lessonId` | `QuizPlayerPage` | authenticated |
| `/quiz-results` | `QuizResultsPage` | authenticated (extra: score map) |
| `/live-class` | `LiveClassPage` | authenticated (extra: `{liveClass, user}`) |
| `/checkout/:id` | `CheckoutPage` | authenticated — Rule 4 |
| `/refund/:courseId` | `RefundPage` | authenticated — Rule 9 |
| `/course-exams/:courseId` | `CourseExamsPage` | authenticated |
| `/exam-submit/:examId` | `ExamSubmitPage` | authenticated |
| `/exam-submissions/:examId` | `ExamSubmissionsPage` | teacher (`?readOnly=true` for admin) |
| `/live-exam/:examId` | `LiveExamPage` | authenticated |
| `/ai-writing-list/:courseId` | `AiWritingListPage` | authenticated |
| `/ai-writing/:taskId` | `AiWritingPage` | authenticated |
| `/practice/:courseId` | `PracticeViewerPage` | authenticated |
| `/suggestions/:courseId` | `PracticeViewerPage` | authenticated |
| `/live-classes/:courseId` | `LiveClassesListPage` | authenticated |
| `/recordings/:courseId` | `RecordingsListPage` | authenticated |
| `/student` (shell) | Home / Browse / Wishlist / Classes / Store / Profile / Certificates | authenticated |
| `/teacher` (shell) | Home / Course Management / Profile | **teacher only** |
| `/teacher/create-course`, `/teacher/add-lesson/:courseId`, `/teacher/add-quiz/:lessonId`, `/teacher/course-details/:courseId`, `/teacher/roster/:courseId`, `/teacher/schedule-class/:courseId` | teacher pages | **teacher only** |

### 7.2 The redirect guard

```dart
redirect: (context, state) {
  final authState = sl<AuthBloc>().state;      // read the SINGLETON bloc
  final currentPath = state.uri.path;

  if (currentPath == splash) return null;      // never intercept splash

  final isAuthRoute = {login, signup, forgotPassword, otp, newPassword}.contains(currentPath);

  if (authState is Unauthenticated) {
    return isAuthRoute ? null : login;         // bounce guests to login
  }

  if (authState is Authenticated) {
    final user = authState.user;
    if (user.isTeacher && user.status != 'Approved') {
      return currentPath == pendingApproval ? null : pendingApproval;  // Rule 5.1
    }
    if (isAuthRoute) {
      return user.isStudent ? studentHome : teacherHome;  // already in, skip auth screens
    }
  }
  return null;
}
```

**Why `sl<AuthBloc>()` instead of `context.read`:** the guard runs outside the widget tree, so it must read the DI singleton. This is exactly why `AuthBloc` is registered as a singleton rather than a factory.

**`GoRouterRefreshStream`** is a `ChangeNotifier` that subscribes to the BLoC stream and calls `notifyListeners()` on every emission, which makes `GoRouter` re-run `redirect`.

### 7.3 Routing gaps vs. the User Manual

All addresses listed in the manual's Appendix §9 that fall inside the
Student/Teacher scope now exist:

| Manual route | Status |
|---|---|
| `/free-live` (public, Rule 12) | ✅ implemented, unguarded |
| `/history` | ✅ `/history` |
| `/leaderboard` | ✅ `/leaderboard` |
| `/notifications` | ✅ `/notifications` |
| `/announcements` | ✅ `/announcements` |
| `/my-courses` | ✅ `/student` (dashboard) |
| `/certificates` | ✅ `/student/certificates` |
| `/ai-writing/<taskId>` | ✅ `/ai-writing/:taskId` |
| `/live-exam/<examId>` | ✅ `/live-exam/:examId` |
| `/exam-submissions/<examId>` | ✅ `/exam-submissions/:examId` |
| `/enrolled-course/<id>` | ✅ `/hub/:id` |
| `/instructors` | ⛔ not built (out of scope this pass) |
| `/teacher-evaluation/<courseId>` | ⛔ not built (out of scope this pass) |
| `/live-exam-responses/<examId>` | ✅ folded into `/exam-submissions` |
| `/admin`, `/course-manager`, `/quiz-editor`, `/enrolled-students` | ⛔ excluded by design (admin scope) |

**Security fix (Rule 1):** the router now blocks students from every
`/teacher/*` path. Previously there was no role guard, so an authenticated
student could navigate straight to the course-authoring UI.

---

## 8. Theme & UI Conventions

- **Colors:** `Core/Theme/app_colors.dart` — `primaryBlue`, `secondaryGreen`, `errorRed`, `scaffoldBackground`.
- **Typography:** Google Fonts **Poppins** applied as the global text theme.
- **Material 3** is enabled (`useMaterial3: true`) with a `ColorScheme.fromSeed` derived from `primaryBlue`.
- **Reusable input styling:** the global `inputDecorationTheme` gives all `TextField`s the same filled/rounded look; `Presentation/Shared Widgets/custom_text_field.dart` wraps it with validation.
- **Buttons:** global `elevatedButtonTheme` forces full-width, 50px-tall, 8px-radius buttons.
- **Widgets are split from pages:** every feature has a `Pages/` folder (screen + BLoC wiring) and a `Widgets/` folder (pure, testable, stateless presentation pieces). This keeps page files small and makes widget tests trivial.

---

## 9. Running, Testing and Building

### 9.1 Prerequisites

- Flutter SDK with Dart `^3.8.1` (see `pubspec.yaml`).
- An Android emulator / iOS simulator / Chrome (for web).
- Network access to `http://160.191.150.185:8071` — **note the API is plain HTTP**, which Android blocks by default (see below).

### 9.2 Install and run

```powershell
flutter pub get
flutter run                      # pick a device when prompted
flutter run -d chrome            # web
flutter run -d <device-id>       # specific device
```

### 9.3 Android cleartext HTTP

Because `baseUrl` is `http://` (not `https://`), Android 9+ will refuse the connection unless cleartext is permitted. Ensure `android/app/src/main/AndroidManifest.xml` has:

```xml
<application android:usesCleartextTraffic="true" ... >
```

*(Not verified in this pass — check the manifest before debugging "connection failed" reports.)*

### 9.4 Build

```powershell
flutter build apk --release          # Android
flutter build appbundle --release    # Play Store
flutter build ios --release          # iOS (requires macOS)
flutter build web --release          # web
```

### 9.5 Tests

```powershell
flutter test                      # all tests
flutter test test/business_rules_test.dart
flutter analyze                   # static analysis (flutter_lints)
```

`test/business_rules_test.dart` contains **20 passing tests** covering the rules
that cannot be inferred from the UI:

- Rule 2 (enrollment closes, enrolled students keep access)
- Rule 3 (upcoming courses are never purchasable and never labelled "Free")
- Rule 4 (exactly one discount applied; losing offer retained; free skips payment)
- Rule 5 (marketing vs. real counts)
- Rule 6 (duration is months)
- Progress weighting (the five components sum to the total)
- Exam lifecycle (locked → open → closed, slot mapping)
- Rule 13 (rate-limit failure carries its wait duration)
- Rule 12 (public route contract)
- Bangladeshi mobile validation (Manual §4.1)
- Watch-history hiding preserves progress (Manual §4.3)

### 9.6 Code generation

`build_runner` and `hive_generator` are declared in `dev_dependencies`, but **the current code does not require either** (no `@HiveType` adapters, no `@injectable`). If you add them:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch
```

### 9.7 Business-rule cheat sheet (for whoever touches the UI next)

| Rule | Where it must be enforced |
|---|---|
| R1 role split | `AppRouter.redirect` + hiding teacher entry points |
| R2 course vanishes after start | server list; client must handle "enrollment closed" |
| R3 upcoming = no price, no "Free" | `CourseEntity.isUpcoming` (field **not yet added**) |
| R4 largest discount wins | `POST /api/Payment/quote` — never compute in Dart |
| R5 inflated counts | never trust `CourseModel.totalLessons` for enrollment truth |
| R6 duration is MONTHS | `CourseModel.durationMinutes` is a **misnomer** — treat as months |
| R12 `/free-live` public | needs an auth-free route + Dio interceptor bypass |
| Timezone | Bangladesh local (UTC+6) — use wall-clock, do not convert |

---

## 10. Summary of Outstanding Work

Consolidated from this document and `api_gap_analysis.md`:

**Critical (client)**
1. Central `ApiRoutes` class; fix all auth route paths/cases.
2. Token refresh on 401 + clean logout.
3. Role guard on `/teacher/*` (Rule 1).
4. Add `isUpcoming` / `enrollmentOpensAt` / `startDate` / `endDate` / `isEnrollable` to `CourseEntity`.
5. Rename `durationMinutes` → `durationMonths` (Rule 6).

**High (features not yet built)**
6. Checkout via `Payment/quote` + SSLCommerz (Rule 4).
7. Exams (`/api/Exam/*`) and live-class exams (`/api/LiveExam/*`).
8. AI writing (`/api/AiWriting/*`).
9. Refunds (`/api/Refund/*`, Rule 9).
10. Progress breakdown (`/api/Progress/my`).
11. `/free-live` public route (Rule 12).
12. Student onboarding form (`/api/Student/complete-onboarding`).
13. Course hub composite endpoint integration.

**Medium**
14. Fix the three broken BLoC handlers in `CourseBloc` (§6.3).
15. Add `courses_box` Hive cache with stale-while-revalidate.
16. Practice files, teacher evaluation, support ticket, pre-booking, store purchase.
17. Watch-history restore/delete.

**Backend asks** — see `api_gap_analysis.md` §7 for the full prioritised list (duration rename, response schemas, 429 + `Retry-After`, course hub composite, real vs. marketing counts).

---

*End of document.*