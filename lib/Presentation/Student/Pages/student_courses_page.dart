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
    context.read<CourseBloc>().add(GetAllCoursesRequested());
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
                if (state is CourseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CoursesLoaded) {
                  log('UI: CoursesLoaded with ${state.courses.length} courses for browsing');
                  if (state.courses.isEmpty) {
                    return const Center(child: Text('No courses available.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.courses.length,
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      return CourseListItem(
                        course: course,
                        onTap: () {
                          log('UI: Tapped browse course ${course.title}');
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
          ),
        ],
      ),
    );
  }
}
