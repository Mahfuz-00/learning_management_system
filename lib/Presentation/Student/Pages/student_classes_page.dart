import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/student_classes_widgets.dart';
import 'dart:developer';

class StudentClassesPage extends StatefulWidget {
  const StudentClassesPage({super.key});

  @override
  State<StudentClassesPage> createState() => _StudentClassesPageState();
}

class _StudentClassesPageState extends State<StudentClassesPage> {
  @override
  void initState() {
    super.initState();
    log('UI: StudentClassesPage initState - fetching my courses');
    context.read<CourseBloc>().add(GetMyCoursesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            log('UI: CoursesLoaded with ${state.courses.length} courses for classes view');
            if (state.courses.isEmpty) {
              return const Center(child: Text('You are not enrolled in any classes.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return EnrolledClassCard(
                  course: course,
                  onTap: () {
                    log('UI: Tapped class ${course.title}');
                    context.push('/course-details/${course.id}');
                  },
                );
              },
            );
          } else if (state is CourseError) {
            log('UI Error: ${state.message}');
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
