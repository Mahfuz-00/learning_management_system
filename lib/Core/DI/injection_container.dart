import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Network/dio_client.dart';
import '../../Data/DataSources/auth_local_data_source.dart';
import '../../Data/DataSources/auth_remote_data_source.dart';
import '../../Data/DataSources/course_remote_data_source.dart';
import '../../Data/DataSources/video_local_data_source.dart';
import '../../Data/DataSources/store_remote_data_source.dart';
import '../../Data/Repositories/auth_repository_impl.dart';
import '../../Data/Repositories/course_repository_impl.dart';
import '../../Data/Repositories/video_repository_impl.dart';
import '../../Data/Repositories/store_repository_impl.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../../Domain/Repositories/course_repository.dart';
import '../../Domain/Repositories/video_repository.dart';
import '../../Domain/Repositories/store_repository.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Presentation/Auth/Bloc/preference_bloc.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';
import '../../Presentation/Course/Bloc/lesson_bloc.dart';
import '../../Presentation/Course/Bloc/video_download_bloc.dart';
import '../../Presentation/Course/Bloc/quiz_bloc.dart';
import '../../Presentation/Course/Bloc/social_bloc.dart';
import '../../Presentation/Student/Bloc/store_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Hive.initFlutter();
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl()));

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(remoteDataSource: sl()),
  );

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );
  sl.registerFactory(
    () => PreferenceBloc(repository: sl()),
  );
  sl.registerFactory(
    () => CourseBloc(courseRepository: sl()),
  );
  sl.registerFactory(
    () => LessonBloc(videoRepository: sl()),
  );
  sl.registerFactory(
    () => VideoDownloadBloc(videoRepository: sl()),
  );
  sl.registerFactory(
    () => QuizBloc(repository: sl()),
  );
  sl.registerFactory(
    () => SocialBloc(repository: sl()),
  );
  sl.registerFactory(
    () => StoreBloc(repository: sl()),
  );
}
