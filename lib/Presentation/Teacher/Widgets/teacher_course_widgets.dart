import 'package:flutter/material.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Core/Widgets/app_network_image.dart';

class TeacherCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onManage;

  const TeacherCourseCard({super.key, required this.course, required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: course.thumbnail,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
              errorWidget: Container(
                width: 100,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.book, size: 40),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.totalLessons} Lessons',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('24 Students', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Manage', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCourseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateCourseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: const Text('Create New Course'),
      icon: const Icon(Icons.add),
    );
  }
}
