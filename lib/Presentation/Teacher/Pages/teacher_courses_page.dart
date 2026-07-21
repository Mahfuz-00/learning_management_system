import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/teacher_course_widgets.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class TeacherCoursesPage extends StatefulWidget {
  const TeacherCoursesPage({super.key});

  @override
  State<TeacherCoursesPage> createState() => _TeacherCoursesPageState();
}

class _TeacherCoursesPageState extends State<TeacherCoursesPage> {
  @override
  void initState() {
    super.initState();
    log('UI: TeacherCoursesPage initState - fetching courses for teacher');
    context.read<CourseBloc>().add(LoadTeacherCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.teacherStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.teacherStatus == CourseStatus.loaded) {
            log('UI: CoursesLoaded for teacher: ${state.teacherCourses.length}');
            if (state.teacherCourses.isEmpty) {
              return const Center(child: Text('You haven\'t created any courses yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.teacherCourses.length,
              itemBuilder: (context, index) {
                final course = state.teacherCourses[index];
                return TeacherCourseCard(
                  course: course,
                  onManage: () {
                    context.push('/teacher/course-details/${course.id}');
                  },
                );
              },
            );
          } else if (state.teacherStatus == CourseStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error loading courses'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: CreateCourseButton(
        onPressed: () {
          context.push(AppRouter.teacherCreateCourse);
        },
      ),
    );
  }
}
