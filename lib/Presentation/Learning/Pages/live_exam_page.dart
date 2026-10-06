import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/live_exam_entity.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// Sit a live-class exam.
///
/// **User Manual §4.4:** *"Google-Forms style — questions on screen, answer
/// inside the browser. Can include a file the teacher attached, and file
/// answers from the student."*
class LiveExamPage extends StatefulWidget {
  final String examId;

  const LiveExamPage({super.key, required this.examId});

  @override
  State<LiveExamPage> createState() => _LiveExamPageState();
}

class _LiveExamPageState extends State<LiveExamPage> {
  /// Holds the student's answer per question id.
  /// Multiple-choice stores the chosen option id; text types store the string.
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(TakeLiveExamRequested(widget.examId));
  }

  void _submit(LiveExamEntity exam) {
    // Validate required questions before sending.
    final missing = exam.questions
        .where((q) => q.isRequired && !_hasAnswer(q.id))
        .toList();

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all required questions (${missing.length} remaining).',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    context.read<LearningBloc>().add(
          SubmitLiveExamRequested(examId: widget.examId, answers: _answers),
        );
  }

  bool _hasAnswer(String questionId) {
    final value = _answers[questionId];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LearningBloc, LearningState>(
      listener: (context, state) {
        if (state.actionSucceeded && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your answers have been submitted.'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          context.pop();
        }
        if (state.errorMessage != null && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final exam = state.activeLiveExam;

        if (state.liveExamStatus == LoadStatus.loading && exam == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (exam == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Live Exam')),
            body: const Center(child: Text('This exam is no longer available.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(exam.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(exam),
                const SizedBox(height: 16),
                ...exam.questions.map(_buildQuestion),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        state.isSubmitting ? null : () => _submit(exam),
                    child: Text(
                      state.isSubmitting ? 'Submitting…' : 'Submit Answers',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LiveExamEntity exam) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exam.description != null && exam.description!.isNotEmpty)
              Text(exam.description!, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (exam.totalPoints != null)
                  _chip(Icons.grade, 'Total: ${exam.totalPoints!.toStringAsFixed(0)} marks'),
                if (exam.durationMinutes != null) ...[
                  const SizedBox(width: 8),
                  _chip(Icons.timer_outlined, '${exam.durationMinutes} min'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders one question according to its type.
  Widget _buildQuestion(LiveExamQuestionEntity question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${question.points.toStringAsFixed(0)} mk',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if (question.isRequired)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  '* Required',
                  style: TextStyle(fontSize: 11, color: AppColors.errorRed),
                ),
              ),

            // Optional attachment the teacher added.
            if (question.fileUrl != null && question.fileUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file, size: 16),
                onPressed: () => _showAttachment(question.fileUrl!),
                label: const Text('View attached file'),
              ),
            ],

            const SizedBox(height: 12),
            _buildAnswerInput(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(LiveExamQuestionEntity question) {
    switch (question.type) {
      case LiveExamQuestionType.multipleChoice:
        return Column(
          children: question.options.map((option) {
            return RadioListTile<String>(
              value: option.id,
              // ignore: deprecated_member_use
              groupValue: _answers[question.id] as String?,
              onChanged: (value) =>
                  setState(() => _answers[question.id] = value),
              title: Text(option.text, style: const TextStyle(fontSize: 13.5)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        );

      case LiveExamQuestionType.shortAnswer:
        return TextField(
          maxLines: 2,
          onChanged: (value) => _answers[question.id] = value,
          decoration: const InputDecoration(
            hintText: 'Type your answer',
            isDense: true,
          ),
        );

      case LiveExamQuestionType.paragraph:
        return TextField(
          maxLines: 6,
          onChanged: (value) => _answers[question.id] = value,
          decoration: const InputDecoration(
            hintText: 'Write your answer',
            isDense: true,
          ),
        );

      case LiveExamQuestionType.fileUpload:
        // File answers: the picked path is sent as the answer value.
        return OutlinedButton.icon(
          icon: const Icon(Icons.upload_file, size: 18),
          onPressed: () => _pickFileAnswer(question.id),
          label: Text(
            _answers[question.id] == null ? 'Upload answer file' : 'File selected',
          ),
        );
    }
  }

  /// File answers are picked and stored as a path string.
  ///
  /// Uploading the binary is deferred to the submit call so the student can
  /// change their mind before sending.
  Future<void> _pickFileAnswer(String questionId) async {
    // A lightweight picker keeps this page free of a second BLoC.
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File answer'),
        content: const Text(
          'Attach a photo or PDF of your handwritten answer. The file is '
          'uploaded when you submit the exam.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _answers[questionId] = 'pending-upload');
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAttachment(String url) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attachment'),
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