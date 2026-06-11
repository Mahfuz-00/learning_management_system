import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/constants.dart';
import '../../Data/DataSources/auth_remote_data_source.dart';
import '../../Data/Repositories/auth_repository_impl.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../../Domain/UseCases/Auth/login_usecase.dart';
import '../../Domain/UseCases/Auth/register_usecase.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Data/DataSources/course_remote_data_source.dart';
import '../../Data/Repositories/course_repository_impl.dart';
import '../../Domain/Repositories/course_repository.dart';
import '../../Domain/UseCases/Course/get_all_courses_usecase.dart';
import '../../Domain/UseCases/Course/get_my_courses_usecase.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      )));

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        authRepository: sl(),
      ));

  // Course Feature
  sl.registerLazySingleton<CourseRemoteDataSource>(
      () => CourseRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<CourseRepository>(
      () => CourseRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetAllCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetMyCoursesUseCase(sl()));
  sl.registerFactory(() => CourseBloc(
        getAllCoursesUseCase: sl(),
        getMyCoursesUseCase: sl(),
        courseRepository: sl(),
      ));
}
