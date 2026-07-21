import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Core/Theme/app_colors.dart';

class QuizResultsPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResultsPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPassed = score >= 80;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPassed ? Icons.emoji_events_outlined : Icons.assignment_late_outlined,
              size: 100,
              color: isPassed ? AppColors.secondaryGreen : AppColors.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              isPassed ? 'Congratulations!' : 'Keep Practicing!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              isPassed 
                ? 'You have successfully completed the assessment.' 
                : 'You need at least 80% to pass this assessment.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            _buildScoreCard(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('CONTINUE TO LESSONS'),
            ),
            if (!isPassed)
              TextButton(
                onPressed: () => context.pop(), // Or retry if API allows
                child: const Text('RETRY QUIZ', style: TextStyle(color: AppColors.primaryBlue)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('SCORE', '$score%'),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStat('CORRECT', '$correctAnswers/$totalQuestions'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }
}
