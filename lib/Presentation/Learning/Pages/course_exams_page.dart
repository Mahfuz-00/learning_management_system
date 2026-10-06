import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/exam_entity.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// The four course-exam slots for one course.
///
/// **User Manual §4.4:** *"Four slots: 1st, 2nd, 3rd, Final. The exam window
/// **opens when the teacher uploads the question file**, and everyone gets the
/// same clock. Download the question, write the answer, upload your answer file
/// before the deadline."*
class CourseExamsPage extends StatefulWidget {
  final String courseId;
  final List<ExamEntity>? initialExams;

  const CourseExamsPage({super.key, required this.courseId, this.initialExams});

  @override
  State<CourseExamsPage> createState() => _CourseExamsPageState();
}

class _CourseExamsPageState extends State<CourseExamsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(LoadCourseExams(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Exams')),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state.examStatus == LoadStatus.loading && state.exams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final exams = state.sortedExams;
          if (exams.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<LearningBloc>().add(LoadCourseExams(widget.courseId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) => _examCard(exams[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'No exams yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your teacher has not published any of the four exams '
          '(1st, 2nd, 3rd, Final) for this course yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _examCard(ExamEntity exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exam.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusChip(exam.status),
              ],
            ),
            const SizedBox(height: 8),

            if (exam.instruction != null && exam.instruction!.isNotEmpty)
              Text(
                exam.instruction!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

            const SizedBox(height: 10),

            if (exam.deadline != null)
              _infoRow(
                Icons.schedule,
                'Deadline: ${DateFormat('dd MMM yyyy, hh:mm a').format(exam.deadline!)}',
              ),
            if (exam.durationMinutes != null)
              _infoRow(Icons.timer_outlined, 'Duration: ${exam.durationMinutes} minutes'),
            if (exam.totalMarks != null)
              _infoRow(Icons.grade_outlined, 'Total marks: ${exam.totalMarks}'),

            if (exam.hasSubmitted && exam.awardedMarks != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your mark: ${exam.awardedMarks}'
                  '${exam.totalMarks != null ? ' / ${exam.totalMarks}' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            _actionRow(exam),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ExamStatus status) {
    late final Color color;
    late final String label;

    switch (status) {
      case ExamStatus.open:
        color = AppColors.secondaryGreen;
        label = 'OPEN';
      case ExamStatus.closed:
        color = Colors.grey;
        label = 'CLOSED';
      case ExamStatus.locked:
        color = Colors.orange;
        label = 'NOT OPEN YET';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(ExamEntity exam) {
    // Locked: the teacher has not uploaded the question file yet.
    if (exam.isLocked) {
      return const Text(
        'This exam opens automatically once your teacher uploads the question paper.',
        style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
      );
    }

    if (exam.isClosed && !exam.hasSubmitted) {
      return const Text(
        'The deadline has passed and no answer was submitted.',
        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    if (exam.hasSubmitted) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.secondaryGreen),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Answer submitted',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryGreen),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/exam-submit/${exam.id}'),
            child: const Text('View'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download_outlined, size: 18),
            onPressed: () => context.push('/exam-submit/${exam.id}'),
            label: const Text('Question paper'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.upload_file, size: 18),
            onPressed: () => context.push('/exam-submit/${exam.id}'),
            label: const Text('Submit answer'),
          ),
        ),
      ],
    );
  }
}