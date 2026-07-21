import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherEnrolledStudentsPage extends StatefulWidget {
  final String courseId;

  const TeacherEnrolledStudentsPage({super.key, required this.courseId});

  @override
  State<TeacherEnrolledStudentsPage> createState() => _TeacherEnrolledStudentsPageState();
}

class _TeacherEnrolledStudentsPageState extends State<TeacherEnrolledStudentsPage> {
  @override
  void initState() {
    super.initState();
    log('UI: Fetching enrolled students for course ${widget.courseId}');
    // In a real app, I'd add a LoadEnrolledStudents event.
    // Reusing state for now if needed or adding specific event.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolled Students')),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          // Placeholder logic for student list
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 15,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primaryBlue),
                ),
                title: Text('Student Name ${index + 1}'),
                subtitle: const Text('student.email@example.com'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${(index * 7) % 100}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                  ],
                ),
                onTap: () {
                  // View student profile/activity details
                },
              );
            },
          );
        },
      ),
    );
  }
}
