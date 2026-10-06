import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/ai_writing_entity.dart';
import '../Bloc/learning_bloc.dart';
import '../Bloc/learning_event.dart';
import '../Bloc/learning_state.dart';

/// Lists the AI writing tasks available in a course (Manual §4.4).
class AiWritingListPage extends StatefulWidget {
  final String courseId;
  final List<AiWritingTaskEntity>? initialTasks;

  const AiWritingListPage({
    super.key,
    required this.courseId,
    this.initialTasks,
  });

  @override
  State<AiWritingListPage> createState() => _AiWritingListPageState();
}

class _AiWritingListPageState extends State<AiWritingListPage> {
  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(LoadAiWritingTasks(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Writing Tasks')),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state.aiWritingStatus == LoadStatus.loading &&
              state.aiWritingTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.aiWritingTasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 56, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No AI writing tasks yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your teacher has not published any handwriting tasks '
                      'for this course.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context
                .read<LearningBloc>()
                .add(LoadAiWritingTasks(widget.courseId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.aiWritingTasks.length,
              itemBuilder: (context, index) {
                final task = state.aiWritingTasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: Colors.teal),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          '${task.maxMarks} marks'
                          '${task.attemptCount > 0 ? ' • ${task.attemptCount} attempt(s)' : ''}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                        if (task.latestMark != null)
                          Text(
                            'Latest mark: ${task.latestMark}/${task.maxMarks}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/ai-writing/${task.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}