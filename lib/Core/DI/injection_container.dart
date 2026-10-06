import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../Data/DataSources/auth_local_data_source.dart';
import '../../Data/DataSources/auth_remote_data_source.dart';
import '../../Data/DataSources/course_remote_data_source.dart';
import '../../Data/DataSources/learning_remote_data_source.dart';
import '../../Data/DataSources/store_remote_data_source.dart';
import '../../Data/DataSources/student_remote_data_source.dart';
import '../../Data/DataSources/video_local_data_source.dart';
import '../../Data/Repositories/auth_repository_impl.dart';
import '../../Data/Repositories/course_repository_impl.dart';
import '../../Data/Repositories/learning_repository_impl.dart';
import '../../Data/Repositories/store_repository_impl.dart';
import '../../Data/Repositories/video_repository_impl.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../../Domain/Repositories/course_repository.dart';
import '../../Domain/Repositories/learning_repository.dart';
import '../../Domain/Repositories/store_repository.dart';
import '../../Domain/Repositories/video_repository.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Presentation/Auth/Bloc/auth_event.dart';
import '../../Presentation/Auth/Bloc/preference_bloc.dart';
import '../../Presentation/Checkout/Bloc/checkout_bloc.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';
import '../../Presentation/Course/Bloc/lesson_bloc.dart';
import '../../Presentation/Course/Bloc/quiz_bloc.dart';
import '../../Presentation/Course/Bloc/social_bloc.dart';
import '../../Presentation/Course/Bloc/video_download_bloc.dart';
import '../../Presentation/Learning/Bloc/learning_bloc.dart';
import '../../Presentation/Notifications/Bloc/notification_bloc.dart';
import '../../Presentation/Profile/Bloc/profile_bloc.dart';
import '../../Presentation/Progress/Bloc/progress_bloc.dart';
import '../../Presentation/Refund/Bloc/refund_bloc.dart';
import '../../Presentation/Student/Bloc/store_bloc.dart';
import '../Network/dio_client.dart';

/// Global service locator.
final sl = GetIt.instance;

/// Builds the entire dependency graph.
///
/// **Registration strategy**
/// - `Dio` / `DioClient` — lazy singleton: one connection pool, one
///   interceptor chain, one token-refresh guard.
/// - Data sources & repositories — lazy singleton: stateless and cheap to share.
/// - [AuthBloc] — **singleton**, because the GoRouter redirect guard reads it
///   outside the widget tree via `sl<AuthBloc>()`.
/// - Feature BLoCs — factory: a fresh instance per screen, disposed with it.
Future<void> init() async {
  // ── Local storage ──────────────────────────────────────────────────────
  await Hive.initFlutter();

  final authLocalDataSource = AuthLocalDataSourceImpl();
  await authLocalDataSource.init();
  sl.registerLazySingleton<AuthLocalDataSource>(() => authLocalDataSource);

  // ── Network ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl(), sl()));

  // When the token cannot be refreshed, force a logout so the router guard
  // redirects the user to /login instead of showing endless error states.
  sl<DioClient>().onSessionExpired = () {
    sl<AuthBloc>().add(LogoutRequested());
  };

  // ── Data sources ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LearningRemoteDataSource>(
    () => LearningRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // ── Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      studentRemoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<LearningRepository>(
    () => LearningRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(remoteDataSource: sl()),
  );

  // ── BLoCs ──────────────────────────────────────────────────────────────

  // Session state must outlive navigation and be readable by the router guard.
  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));

  // Feature BLoCs are created per screen.
  sl.registerFactory(() => PreferenceBloc(repository: sl()));
  sl.registerFactory(() => CourseBloc(courseRepository: sl()));
  sl.registerFactory(() => LearningBloc(repository: sl()));
  sl.registerFactory(() => CheckoutBloc(repository: sl()));
  sl.registerFactory(() => ProfileBloc(repository: sl()));
  sl.registerFactory(() => ProgressBloc(repository: sl()));
  sl.registerFactory(() => RefundBloc(repository: sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl()));
  sl.registerFactory(() => LessonBloc(videoRepository: sl()));
  sl.registerFactory(() => VideoDownloadBloc(videoRepository: sl()));
  sl.registerFactory(() => QuizBloc(repository: sl()));
  sl.registerFactory(() => SocialBloc(repository: sl()));
  sl.registerFactory(() => StoreBloc(repository: sl()));
}