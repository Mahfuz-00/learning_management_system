import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../Widgets/course_details_widgets.dart';
import 'dart:developer';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    log('UI: CourseDetailsPage initState for ${widget.courseId}');
    context.read<CourseBloc>().add(GetCourseDetailsRequested(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is EnrollmentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enrolled successfully!')),
            );
            // Refresh to show lessons if they were hidden before enrollment
            context.read<CourseBloc>().add(GetCourseDetailsRequested(widget.courseId));
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseError) {
            log('UI Error: ${state.message}');
            return Center(child: Text(state.message));
          } else if (state is CourseDetailLoaded) {
            log('UI: CourseDetailLoaded for ${state.course.title} with ${state.lessons.length} lessons');
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseHeader(course: state.course),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Course Content',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (state.lessons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No lessons available for this course yet.'),
                    )
                  else
                    LessonList(
                      lessons: state.lessons,
                      onLessonTap: (lesson) {
                        log('UI: Navigating to lesson: ${lesson.title}');
                        context.push('/lesson-player', extra: lesson);
                      },
                    ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      bottomSheet: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseDetailLoaded) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    log('UI: Requesting Enrollment for ${widget.courseId}');
                    context.read<CourseBloc>().add(EnrollRequested(widget.courseId));
                  },
                  child: const Text('Enroll Now'),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
