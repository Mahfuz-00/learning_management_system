import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/progress_entity.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../../Learning/Bloc/learning_bloc.dart';
import '../../Learning/Bloc/learning_event.dart';
import '../../Learning/Bloc/learning_state.dart';
import '../../Progress/Bloc/progress_bloc.dart';
import '../../Progress/Bloc/progress_event.dart';
import '../../Progress/Bloc/progress_state.dart';
import '../Widgets/hub_card.dart';

/// The enrolled-course hub.
///
/// **User Manual §4.3:** *"You land on the course hub — five big cards:
/// Practice, Live Class, Recordings, Exam, Suggestion."*
///
/// Video lessons, quizzes and the combined progress bar live on the same page:
/// *"One combined number: video 40%, quiz 15%, exam 15%, live exam 20%,
/// attendance 10%."*
class CourseHubPage extends StatefulWidget {
  final String courseId;
  final CourseEntity? course;

  const CourseHubPage({super.key, required this.courseId, this.course});

  @override
  State<CourseHubPage> createState() => _CourseHubPageState();
}

class _CourseHubPageState extends State<CourseHubPage> {
  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  /// Loads every section the hub needs.
  ///
  /// Each BLoC owns one slice: [CourseBloc] owns the course, lessons, live
  /// classes and recordings; [LearningBloc] owns exams, practice files and AI
  /// writing tasks; [ProgressBloc] owns the weighted progress figure.
  void _loadEverything() {
    context.read<CourseBloc>().add(LoadCourseDetails(widget.courseId));
    context.read<CourseBloc>().add(LoadLiveClassesRequested(widget.courseId));
    context.read<CourseBloc>().add(LoadRecordingsRequested(widget.courseId));
    context.read<LearningBloc>().add(LoadCourseHub(widget.courseId));
    context.read<ProgressBloc>().add(const LoadMyProgress());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course?.title ?? 'Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEverything,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadEverything(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSection(),
              const SizedBox(height: 20),
              const Text(
                'Course Hub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildHubGrid(),
              const SizedBox(height: 24),
              _buildLessonsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress (Manual §4.3) ─────────────────────────────────────────────

  Widget _buildProgressSection() {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, progressState) {
        final progress = progressState.courseProgress
            .where((p) => p.courseId == widget.courseId)
            .firstOrNull;

        if (progressState.status == ProgressStatus.loading && progress == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return _ProgressCard(progress: progress);
      },
    );
  }

  // ── The five hub cards ─────────────────────────────────────────────────

  Widget _buildHubGrid() {
    return BlocBuilder<LearningBloc, LearningState>(
      builder: (context, learningState) {
        return BlocBuilder<CourseBloc, CourseState>(
          builder: (context, courseState) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: HubCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Practice',
                        subtitle: '${learningState.practiceOnly.length} files',
                        color: AppColors.primaryBlue,
                        onTap: () => context.push(
                          '/practice/${widget.courseId}',
                          extra: learningState.practiceOnly,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HubCard(
                        icon: Icons.live_tv_rounded,
                        title: 'Live Class',
                        subtitle: courseState.liveClasses.isEmpty
                            ? 'None scheduled'
                            : '${courseState.liveClasses.length} classes',
                        color: AppColors.errorRed,
                        onTap: () => context.push(
                          '/live-classes/${widget.courseId}',
                          extra: courseState.liveClasses,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: HubCard(
                        icon: Icons.video_library_rounded,
                        title: 'Recordings',
                        subtitle: courseState.recordings.isEmpty
                            ? 'No recordings'
                            : '${courseState.recordings.length} videos',
                        color: Colors.purple,
                        onTap: () => context.push(
                          '/recordings/${widget.courseId}',
                          extra: courseState.recordings,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HubCard(
                        icon: Icons.assignment_rounded,
                        title: 'Exam',
                        subtitle: learningState.exams.isEmpty
                            ? 'Not open yet'
                            : '${learningState.openExams.length} open',
                        color: AppColors.secondaryGreen,
                        onTap: () => context.push(
                          '/course-exams/${widget.courseId}',
                          extra: learningState.exams,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: HubCard(
                        icon: Icons.lightbulb_rounded,
                        title: 'Suggestion',
                        subtitle: '${learningState.suggestionsOnly.length} files',
                        color: Colors.orange,
                        onTap: () => context.push(
                          '/suggestions/${widget.courseId}',
                          extra: learningState.suggestionsOnly,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HubCard(
                        icon: Icons.edit_note_rounded,
                        title: 'AI Writing',
                        subtitle: learningState.aiWritingTasks.isEmpty
                            ? 'No tasks'
                            : '${learningState.aiWritingTasks.length} tasks',
                        color: Colors.teal,
                        onTap: () => context.push(
                          '/ai-writing-list/${widget.courseId}',
                          extra: learningState.aiWritingTasks,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Lessons + quizzes ──────────────────────────────────────────────────

  Widget _buildLessonsSection() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state.detailsStatus == CourseStatus.loading && state.lessons.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ));
        }

        if (state.lessons.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(child: Text('No lessons have been published yet.')),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Lessons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...state.lessons.asMap().entries.map((entry) {
              final index = entry.key;
              final lesson = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(lesson.title),
                  subtitle: Text(
                    lesson.hasVideo ? 'Video lesson' : 'Reading',
                  ),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () => context.push('/lesson-player', extra: lesson),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// The combined progress card.
///
/// Shows the total **and** the five weighted components, because the manual
/// defines the number as a specific blend the student is entitled to see.
class _ProgressCard extends StatelessWidget {
  final CourseProgressEntity? progress;

  const _ProgressCard({this.progress});

  @override
  Widget build(BuildContext context) {
    final value = progress?.effectiveOverall ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${value.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1),
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 14),
            // The five weighted components, per Manual §4.3.
            _componentRow('Video', progress?.videoProgress ?? 0, 40),
            _componentRow('Quiz', progress?.quizProgress ?? 0, 15),
            _componentRow('Exam', progress?.examProgress ?? 0, 15),
            _componentRow('Live Exam', progress?.liveExamProgress ?? 0, 20),
            _componentRow('Attendance', progress?.attendanceProgress ?? 0, 10),
          ],
        ),
      ),
    );
  }

  /// One weighted progress row, e.g. "Video  12 / 40".
  Widget _componentRow(String label, double value, double max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: max <= 0 ? 0 : (value / max).clamp(0, 1),
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppColors.secondaryGreen),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Text(
              '${value.toStringAsFixed(0)}/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}