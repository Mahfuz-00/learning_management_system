import 'package:flutter/material.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../Widgets/lesson_player_widgets.dart';
import 'dart:developer';

class LessonPlayerPage extends StatelessWidget {
  final LessonEntity lesson;

  const LessonPlayerPage({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    log('UI: LessonPlayerPage build for ${lesson.title}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.isVideo)
              VideoPlayerWidget(
                videoUrl: lesson.youtubeUrl ?? lesson.videoUrl ?? '',
                isYoutube: lesson.youtubeUrl != null,
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.description, size: 64, color: Colors.grey),
              ),
            LessonContentWidget(lesson: lesson),
          ],
        ),
      ),
    );
  }
}
