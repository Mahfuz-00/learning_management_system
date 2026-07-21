import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class QuizPlayerPage extends StatefulWidget {
  final String lessonId;

  const QuizPlayerPage({super.key, required this.lessonId});

  @override
  State<QuizPlayerPage> createState() => _QuizPlayerPageState();
}

class _QuizPlayerPageState extends State<QuizPlayerPage> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    log('UI: Loading quiz for lesson ${widget.lessonId}');
    context.read<CourseBloc>().add(LoadQuizQuestionsRequested(widget.lessonId));
  }

  void _submitQuiz() {
    log('UI: Submitting quiz for lesson ${widget.lessonId} with answers $_answers');
    context.read<CourseBloc>().add(SubmitQuizRequested(
      lessonId: widget.lessonId,
      answers: _answers,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment')),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.quizStatus == CourseStatus.loaded && state.activeQuiz == null && state.errorMessage == null) {
            // This might be a legacy check, in unified state we use specific result data
          }
          
          if (state.quizStatus == CourseStatus.error) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          if (state.quizStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          } 
          
          final quiz = state.activeQuiz;
          if (quiz == null) {
            return const Center(child: Text('No quiz data found.'));
          }

          if (quiz.hasAttempted) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 80, color: AppColors.secondaryGreen),
                    const SizedBox(height: 24),
                    const Text(
                      'Already Attempted',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have already completed this quiz with a score of ${quiz.score ?? 0}%. Re-attempts are not allowed.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('BACK TO LESSONS'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (quiz.questions.isEmpty) {
            return const Center(child: Text('No questions available for this lesson.'));
          }

          final question = quiz.questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / quiz.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.secondaryGreen,
                ),
                const SizedBox(height: 24),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${quiz.questions.length}',
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  question.text,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected = _answers[question.id] == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[question.id] = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppColors.primaryBlue),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentQuestionIndex > 0)
                      TextButton(
                        onPressed: () => setState(() => _currentQuestionIndex--),
                        child: const Text('PREVIOUS'),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentQuestionIndex < quiz.questions.length - 1) {
                          setState(() => _currentQuestionIndex++);
                        } else {
                          if (_answers.length == quiz.questions.length) {
                            _submitQuiz();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please answer all questions before submitting.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 50),
                      ),
                      child: Text(_currentQuestionIndex < quiz.questions.length - 1 ? 'NEXT' : 'SUBMIT'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
