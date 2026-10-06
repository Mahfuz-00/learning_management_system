import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/ai_writing_entity.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// The AI writing task screen (Manual §4.4).
///
/// *"Student uploads a handwritten answer photo. The AI reads the handwriting
/// and gives a mark out of 100 with feedback... Multiple attempts allowed — the
/// last one counts."*
class AiWritingPage extends StatefulWidget {
  final String taskId;

  const AiWritingPage({super.key, required this.taskId});

  @override
  State<AiWritingPage> createState() => _AiWritingPageState();
}

class _AiWritingPageState extends State<AiWritingPage> {
  final _picker = ImagePicker();
  File? _photo;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(LoadAiWritingTask(widget.taskId));
  }

  /// Captures or selects the handwritten answer photo.
  Future<void> _pickImage(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (picked != null) {
        setState(() => _photo = File(picked.path));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    if (_photo == null) return;
    context.read<LearningBloc>().add(
          SubmitAiWritingRequested(taskId: widget.taskId, photo: _photo!),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LearningBloc, LearningState>(
      listener: (context, state) {
        if (state.actionSucceeded && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submitted. The AI is marking your handwriting…'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          setState(() => _photo = null);
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
        final task = state.activeAiTask;

        if (state.aiWritingStatus == LoadStatus.loading && task == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('AI Writing')),
            body: const Center(child: Text('This task is no longer available.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(task.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskCard(task),
                const SizedBox(height: 16),
                if (task.hasSubmitted) _buildLatestResult(task),
                const SizedBox(height: 16),
                _buildUploadCard(state),
                const SizedBox(height: 20),
                _buildAttemptHistory(state),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(AiWritingTaskEntity task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  '${task.maxMarks} marks',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (task.instructions != null && task.instructions!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(task.instructions!, style: const TextStyle(fontSize: 13)),
            ],
            if (task.topics.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Choose one topic:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...task.topics.map(
                (topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(topic, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Shows the mark for the latest attempt — the one that counts.
  Widget _buildLatestResult(AiWritingTaskEntity task) {
    final mark = task.latestMark;
    if (mark == null) return const SizedBox.shrink();

    final percentage = task.maxMarks > 0 ? (mark / task.maxMarks) : 0.0;
    final color = percentage >= 0.6 ? AppColors.secondaryGreen : Colors.orange;

    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest mark',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$mark / ${task.maxMarks}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            if (task.latestFeedback != null && task.latestFeedback!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.latestFeedback!,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Attempt ${task.attemptCount} • the last attempt counts',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(LearningState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload your handwritten answer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Take a clear photo of your handwriting. The AI will read it and '
              'give a mark with feedback.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            if (_photo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: AppColors.secondaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _photo!.path.split(RegExp(r'[/\\]')).last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _photo = null),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    onPressed:
                        _picking ? null : () => _pickImage(ImageSource.camera),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    onPressed:
                        _picking ? null : () => _pickImage(ImageSource.gallery),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                    : const Icon(Icons.send_rounded),
                onPressed:
                    (_photo == null || state.isSubmitting) ? null : _submit,
                label: Text(state.isSubmitting ? 'Uploading…' : 'Submit for marking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Attempt history — "Multiple attempts allowed — the last one counts."
  Widget _buildAttemptHistory(LearningState state) {
    if (state.aiSubmissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your attempts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...state.aiSubmissions.map((submission) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: submission.isLatest
                    ? AppColors.secondaryGreen.withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                child: Text(
                  '#${submission.attemptNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: submission.isLatest
                        ? AppColors.secondaryGreen
                        : Colors.grey,
                  ),
                ),
              ),
              title: Text(
                submission.displayMark != null
                    ? 'Mark: ${submission.displayMark}'
                    : 'Awaiting mark',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                submission.submittedAt != null
                    ? DateFormat('dd MMM yyyy, hh:mm a')
                        .format(submission.submittedAt!)
                    : '',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: submission.isLatest
                  ? const Chip(
                      label: Text('Counts', style: TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }
}