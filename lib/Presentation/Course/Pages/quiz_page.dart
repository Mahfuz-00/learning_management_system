import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../Widgets/quiz_widgets.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class QuizPage extends StatefulWidget {
  final String lessonId;

  const QuizPage({super.key, required this.lessonId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<String, dynamic> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    log('UI: QuizPage initState for lesson ${widget.lessonId}');
    context.read<CourseBloc>().add(LoadQuizQuestionsRequested(widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Quiz')),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.quizStatus == CourseStatus.loaded && state.activeQuiz == null && state.errorMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz submitted successfully!'), backgroundColor: AppColors.secondaryGreen),
            );
            Navigator.pop(context);
          }
          if (state.quizStatus == CourseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          if (state.quizStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          final quiz = state.activeQuiz;
          if (quiz == null) {
            return const Center(child: Text('No quiz found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment for Lesson',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: QuestionWidget(
                        question: question,
                        selectedOptionIndex: _selectedAnswers[question.id],
                        onOptionSelected: (optionIndex) {
                          setState(() {
                            _selectedAnswers[question.id] = optionIndex;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    log('UI: Submitting quiz attempt');
                    context.read<CourseBloc>().add(
                      SubmitQuizRequested(
                        lessonId: widget.lessonId,
                        answers: _selectedAnswers,
                      ),
                    );
                  },
                  child: const Text('Submit Quiz'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
