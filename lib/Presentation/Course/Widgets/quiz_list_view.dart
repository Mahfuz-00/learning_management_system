import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Domain/Entities/quiz_entity.dart';
import '../../../Core/Theme/app_colors.dart';

class QuizListView extends StatelessWidget {
  final String courseId;
  // In a real app, you'd probably fetch these or pass them from the workspace state
  final List<QuizEntity> quizzes; 

  const QuizListView({
    super.key,
    required this.courseId,
    required this.quizzes,
  });

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No quizzes available for this course.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: quiz.hasAttempted ? AppColors.secondaryGreen : AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(
                quiz.hasAttempted ? Icons.check : Icons.assignment_outlined,
                color: quiz.hasAttempted ? Colors.white : AppColors.primaryBlue,
              ),
            ),
            title: Text('Quiz for Lesson ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(quiz.hasAttempted ? 'Score: ${quiz.score}%' : '${quiz.questions.length} Questions'),
            trailing: ElevatedButton(
              onPressed: () => context.push('/quiz-player/${quiz.lessonId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: quiz.hasAttempted ? Colors.grey : AppColors.primaryBlue,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(quiz.hasAttempted ? 'VIEW' : 'START', style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}
