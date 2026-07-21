import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../Bloc/lesson_bloc.dart';
import '../Bloc/lesson_event.dart';
import '../Bloc/lesson_state.dart';
import '../Widgets/secure_recorded_player.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Constants/app_constants.dart';

class LessonPlayerPage extends StatefulWidget {
  final LessonEntity lesson;

  const LessonPlayerPage({super.key, required this.lesson});

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  @override
  void initState() {
    super.initState();
    context.read<LessonBloc>().add(CheckVideoDownloadStatus(widget.lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          if (widget.lesson.hasVideo && !widget.lesson.isYoutube)
            _buildDownloadAction(),
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            onPressed: () => context.push('/quiz-player/${widget.lesson.id}'),
            tooltip: 'Take Quiz',
          ),
        ],
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          String? videoSource;
          bool isLocal = false;

          if (state is VideoDownloaded) {
            videoSource = state.localPath;
            isLocal = true;
          } else {
            videoSource = widget.lesson.isYoutube
                ? widget.lesson.youtubeUrl
                : (widget.lesson.videoUrl != null ? '${AppConstants.videosBaseUrl}${widget.lesson.videoUrl}' : null);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.lesson.hasVideo && videoSource != null)
                SecureRecordedPlayer(
                  videoSource: videoSource,
                  lessonId: widget.lesson.id,
                  isLocal: isLocal,
                )
              else if (!widget.lesson.hasVideo)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Reading Material', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.lesson.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildCompletionToggle(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        widget.lesson.content ?? 'No additional description for this lesson.',
                        style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDownloadAction() {
    return BlocBuilder<LessonBloc, LessonState>(
      builder: (context, state) {
        if (state is VideoDownloadInProgress) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        } else if (state is VideoDownloaded) {
          return IconButton(
            icon: const Icon(Icons.check_circle, color: AppColors.secondaryGreen),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video is available offline')),
              );
            },
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: () {
              final url = '${AppConstants.videosBaseUrl}${widget.lesson.videoUrl}';
              context.read<LessonBloc>().add(DownloadVideoRequested(
                    videoUrl: url,
                    lessonId: widget.lesson.id,
                  ));
            },
          );
        }
      },
    );
  }

  Widget _buildCompletionToggle() {
    return OutlinedButton.icon(
      onPressed: () {
        // Mark as completed logic
      },
      icon: Icon(
        widget.lesson.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: widget.lesson.isCompleted ? AppColors.secondaryGreen : Colors.grey,
      ),
      label: Text(
        widget.lesson.isCompleted ? 'COMPLETED' : 'MARK AS DONE',
        style: TextStyle(
          color: widget.lesson.isCompleted ? AppColors.secondaryGreen : Colors.grey,
          fontSize: 12,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: widget.lesson.isCompleted ? AppColors.secondaryGreen : Colors.grey),
      ),
    );
  }
}
