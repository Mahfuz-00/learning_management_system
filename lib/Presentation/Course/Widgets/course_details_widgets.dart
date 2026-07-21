import 'package:flutter/material.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Core/Constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourseHeader extends StatelessWidget {
  final CourseEntity course;

  const CourseHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: '${AppConstants.imagesPath}${course.thumbnail}',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Instructor: ${course.instructorName ?? "Unknown"}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                course.description ?? 'No description available.',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LessonList extends StatelessWidget {
  final List<LessonEntity> lessons;
  final Function(LessonEntity) onLessonTap;

  const LessonList({super.key, required this.lessons, required this.onLessonTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text(lesson.title),
          subtitle: Text(lesson.hasVideo ? 'Video Lesson' : 'Text Lesson'),
          trailing: const Icon(Icons.play_circle_outline),
          onTap: () => onLessonTap(lesson),
        );
      },
    );
  }
}
