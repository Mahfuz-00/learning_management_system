import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../Core/Theme/app_colors.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// Submit an answer file for a course exam.
///
/// **User Manual §4.4:** *"Download the question, write the answer, upload your
/// answer file before the deadline."*
class ExamSubmitPage extends StatefulWidget {
  final String examId;

  const ExamSubmitPage({super.key, required this.examId});

  @override
  State<ExamSubmitPage> createState() => _ExamSubmitPageState();
}

class _ExamSubmitPageState extends State<ExamSubmitPage> {
  File? _answerFile;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(LoadExamQuestion(widget.examId));
  }

  /// Picks the student's answer file (photo or PDF of handwritten work).
  Future<void> _pickAnswerFile() async {
    setState(() => _picking = true);
    try {
      // file_picker v13 returns List<PlatformFile> directly for pickFiles()
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (files.isNotEmpty && files.first.path != null) {
        setState(() => _answerFile = File(files.first.path!));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    if (_answerFile == null) return;
    context.read<LearningBloc>().add(
      SubmitExamAnswer(examId: widget.examId, file: _answerFile!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LearningBloc, LearningState>(
      listener: (context, state) {
        if (state.actionSucceeded && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Answer submitted successfully.'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          Navigator.of(context).pop();
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
        return Scaffold(
          appBar: AppBar(title: const Text('Exam')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionCard(state),
                const SizedBox(height: 20),
                _buildAnswerCard(state),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: state.isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.upload_file),
                    onPressed:
                    (_answerFile == null || state.isSubmitting) ? null : _submit,
                    label: Text(state.isSubmitting ? 'Uploading…' : 'Submit Answer'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload before the deadline. Late submissions are not accepted.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(LearningState state) {
    final question = state.examQuestion;
    final fileUrl = (question?['questionFileUrl'] ?? question?['fileUrl'] ?? '')
        .toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Question paper',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.examStatus == LoadStatus.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (fileUrl.isEmpty)
              const Text(
                'The question paper has not been attached to this exam yet.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Download the question paper, write your answer, then '
                        'upload it below.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () => _showUrlDialog('Question paper', fileUrl),
                      label: const Text('View question paper'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerCard(LearningState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file_outlined, color: AppColors.secondaryGreen),
                SizedBox(width: 8),
                Text(
                  'Your answer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Accepted formats: PDF, JPG, PNG',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (_answerFile != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.secondaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _answerFile!.path.split(RegExp(r'[/\\]')).last,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _answerFile = null),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                onPressed: _picking ? null : _pickAnswerFile,
                label: Text(
                  _picking
                      ? 'Opening…'
                      : (_answerFile == null ? 'Choose file' : 'Replace file'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog(String title, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(
          url,
          style: const TextStyle(fontSize: 12),
        ),
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