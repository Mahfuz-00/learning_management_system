import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/course_entity.dart';
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
    context.read<CourseBloc>().add(LoadMyEnrollments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Live Classes'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.enrolledStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.enrolledStatus == CourseStatus.loaded) {
            if (state.enrolledCourses.isEmpty) {
              return const Center(child: Text('No enrolled courses with live classes.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.enrolledCourses.length,
              itemBuilder: (context, index) {
                final course = state.enrolledCourses[index];
                return _buildLiveClassCard(context, course);
              },
            );
          } else if (state.enrolledStatus == CourseStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error loading classes'));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLiveClassCard(BuildContext context, CourseEntity course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE NOW',
                    style: TextStyle(color: AppColors.secondaryGreen, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Interactive Q&A - ${course.title}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Instructor: ${course.instructorName ?? "Expert"}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  '05:00 PM',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                log('UI: Joining Live Class for course ${course.id}');
                // Navigate to Jitsi Meet screen or trigger join
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('JOIN CLASS'),
            ),
          ],
        ),
      ),
    );
  }
}
