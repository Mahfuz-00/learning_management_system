import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/exam_entity.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// Teacher: mark the students' exam answer files.
///
/// **User Manual §5.2:** *"Download each student's answer file, type a mark and
/// feedback. Admin can open this page but only to read."* — the read-only admin
/// case is handled by the router, which only grants teachers write access.
class ExamSubmissionsPage extends StatefulWidget {
  final String examId;
  final bool readOnly;

  const ExamSubmissionsPage({
    super.key,
    required this.examId,
    this.readOnly = false,
  });

  @override
  State<ExamSubmissionsPage> createState() => _ExamSubmissionsPageState();
}

class _ExamSubmissionsPageState extends State<ExamSubmissionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(LoadExamSubmissions(widget.examId));
  }

  /// Opens the grading dialog for one submission.
  Future<void> _grade(ExamSubmissionEntity submission) async {
    final marksController =
        TextEditingController(text: submission.marks?.toString() ?? '');
    final feedbackController = TextEditingController(text: submission.feedback ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark — ${submission.studentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mark',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback (optional)',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save mark'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final marks = int.tryParse(marksController.text.trim());
    if (marks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid numeric mark.')),
      );
      return;
    }

    context.read<LearningBloc>().add(
          GradeExamSubmissionRequested(
            submissionId: submission.id,
            marks: marks,
            feedback: feedbackController.text.trim().isEmpty
                ? null
                : feedbackController.text.trim(),
          ),
        );

    // Reload so the list reflects the new mark.
    context.read<LearningBloc>().add(LoadExamSubmissions(widget.examId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Exam Answers (read only)' : 'Mark Exam Answers'),
      ),
      body: BlocConsumer<LearningBloc, LearningState>(
        listener: (context, state) {
          if (state.actionSucceeded && !state.isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mark saved.'),
                backgroundColor: AppColors.secondaryGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.examStatus == LoadStatus.loading &&
              state.examSubmissions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.examSubmissions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No submissions yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Student answers will appear here once they are uploaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final graded = state.examSubmissions.where((s) => s.isGraded).length;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                child: Text(
                  '$graded of ${state.examSubmissions.length} submissions marked',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.examSubmissions.length,
                  itemBuilder: (context, index) =>
                      _card(state.examSubmissions[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(ExamSubmissionEntity submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                  child: Text(
                    submission.studentName.isNotEmpty
                        ? submission.studentName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (submission.studentEmail != null)
                        Text(
                          submission.studentEmail!,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (submission.isGraded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${submission.marks}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryGreen,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Not marked',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (submission.submittedAt != null)
              Text(
                'Submitted ${DateFormat('dd MMM yyyy, hh:mm a').format(submission.submittedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Feedback: ${submission.feedback}',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (submission.answerFileUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_outlined, size: 17),
                      onPressed: () => _showFile(submission.answerFileUrl!),
                      label: const Text('Answer file'),
                    ),
                  ),
                if (!widget.readOnly) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      onPressed: () => _grade(submission),
                      label: Text(submission.isGraded ? 'Update' : 'Mark'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFile(String url) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student answer file'),
        content: SelectableText(url, style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}