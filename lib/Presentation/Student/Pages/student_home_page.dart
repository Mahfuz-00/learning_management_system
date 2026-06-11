import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/student_home_widgets.dart';
import 'dart:developer';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    log('UI: StudentHomePage initState - fetching enrolled courses');
    context.read<CourseBloc>().add(GetMyCoursesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CourseBloc>().add(GetMyCoursesRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue Learning',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  } else if (state is CoursesLoaded) {
                    log('UI: CoursesLoaded with ${state.courses.length} courses');
                    return EnrolledCoursesSection(
                      courses: state.courses,
                      onCourseTap: (course) {
                        log('UI: Tapped course ${course.title}');
                        context.push('/course-details/${course.id}');
                      },
                    );
                  } else if (state is CourseError) {
                    log('UI Error: ${state.message}');
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Quick Access',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const QuickLinksGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
