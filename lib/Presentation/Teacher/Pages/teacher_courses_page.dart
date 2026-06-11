import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/teacher_course_widgets.dart';
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
    // Assuming we use the same CourseBloc but might need a "GetInstructorCourses" event later.
    // For now, let's use GetAllCourses as a placeholder or MyCourses if they are mapped to instructor.
    context.read<CourseBloc>().add(GetAllCoursesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            log('UI: CoursesLoaded for teacher: ${state.courses.length}');
            if (state.courses.isEmpty) {
              return const Center(child: Text('You haven\'t created any courses yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return TeacherCourseCard(
                  course: course,
                  onManage: () {
                    log('UI: Managing course ${course.title}');
                    // Navigate to course management page
                  },
                );
              },
            );
          } else if (state is CourseError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: CreateCourseButton(
        onPressed: () {
          log('UI: Create New Course pressed');
          // Navigate to create course page
        },
      ),
    );
  }
}
