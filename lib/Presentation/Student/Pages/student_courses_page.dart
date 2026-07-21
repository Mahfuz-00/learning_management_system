import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/student_courses_widgets.dart';
import 'dart:developer';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('UI: StudentCoursesPage initState - fetching all courses');
    context.read<CourseBloc>().add(LoadAllCourses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              onSearch: (query) {
                log('UI: Searching for $query');
                // Implement local search or trigger API search
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                if (state.allCoursesStatus == CourseStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.allCoursesStatus == CourseStatus.loaded) {
                  log('UI: CoursesLoaded with ${state.allCourses.length} courses for browsing');
                  if (state.allCourses.isEmpty) {
                    return const Center(child: Text('No courses available.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.allCourses.length,
                    itemBuilder: (context, index) {
                      final course = state.allCourses[index];
                      return CourseListItem(
                        course: course,
                        onTap: () {
                          log('UI: Tapped browse course ${course.title}');
                          context.push('/course/${course.id}');
                        },
                      );
                    },
                  );
                } else if (state.allCoursesStatus == CourseStatus.error) {
                  log('UI Error: ${state.errorMessage}');
                  return Center(child: Text(state.errorMessage ?? 'Error'));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
