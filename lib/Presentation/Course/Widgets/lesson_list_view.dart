import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Constants/app_constants.dart';
import '../Bloc/video_download_bloc.dart';
import 'dart:developer';

class LessonListView extends StatelessWidget {
  final List<LessonEntity> lessons;

  const LessonListView({super.key, required this.lessons});

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(child: Text('No lessons found in this course.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return BlocProvider(
          create: (context) => context.read<VideoDownloadBloc>()..add(CheckDownloadStatus(lesson.id)),
          child: _LessonTile(lesson: lesson),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonEntity lesson;

  const _LessonTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lesson.isCompleted ? AppColors.secondaryGreen : AppColors.primaryBlue.withOpacity(0.1),
          child: Icon(
            lesson.isCompleted ? Icons.check : (lesson.hasVideo ? Icons.play_arrow_rounded : Icons.description),
            color: lesson.isCompleted ? Colors.white : AppColors.primaryBlue,
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: lesson.isCompleted ? Colors.grey : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          lesson.hasVideo ? 'Video Lesson' : 'Reading Material',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: _buildTrailing(context),
        onTap: () {
          log('UI: Navigating to Lesson Player for ${lesson.title}');
          context.push('/lesson-player', extra: lesson);
        },
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (!lesson.hasVideo || lesson.isYoutube) {
      return const Icon(Icons.chevron_right, size: 20);
    }

    return BlocBuilder<VideoDownloadBloc, VideoDownloadState>(
      builder: (context, state) {
        if (state is VideoDownloading && state.videoId == lesson.id) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          );
        } else if (state is VideoDownloadedState && state.videoId == lesson.id) {
          return const Icon(Icons.offline_pin_rounded, color: AppColors.secondaryGreen, size: 24);
        } else {
          return IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue, size: 22),
            onPressed: () {
              final url = '${AppConstants.videosPath}${lesson.videoUrl}';
              context.read<VideoDownloadBloc>().add(StartVideoDownload(
                videoUrl: url,
                videoId: lesson.id,
              ));
            },
          );
        }
      },
    );
  }
}
