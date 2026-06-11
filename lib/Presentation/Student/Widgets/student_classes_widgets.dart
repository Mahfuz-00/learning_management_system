import 'package:flutter/material.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Core/Constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EnrolledClassCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const EnrolledClassCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: '${AppConstants.imagesUrl}${course.thumbnail}',
            width: 80,
            height: 60,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(Icons.video_library, size: 40),
          ),
        ),
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.instructorName ?? 'Instructor'),
            const SizedBox(height: 4),
            const LinearProgressIndicator(value: 0.4), // Placeholder progress
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
