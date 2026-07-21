import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherStudentRosterPage extends StatefulWidget {
  final String courseId;

  const TeacherStudentRosterPage({super.key, required this.courseId});

  @override
  State<TeacherStudentRosterPage> createState() => _TeacherStudentRosterPageState();
}

class _TeacherStudentRosterPageState extends State<TeacherStudentRosterPage> {
  @override
  void initState() {
    super.initState();
    log('UI: Fetching student roster for course ${widget.courseId}');
    // Ideally, dispatch a LoadRoster event here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              log('UI: Exporting student list to CSV/PDF');
            },
          ),
        ],
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          // Displaying a scannable list of students with progress tracking
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 12, // Placeholder count
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildStudentCard(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(int index) {
    final progress = (index * 8) % 100;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text('${index + 1}', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Name ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Text(
                  'SSC Exam 2024 • Dhaka Board',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$progress%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progress > 80 ? AppColors.secondaryGreen : AppColors.primaryBlue,
                ),
              ),
              const Text('Progress', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
