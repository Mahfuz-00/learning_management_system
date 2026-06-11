import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../Widgets/quiz_widgets.dart';
import 'dart:developer';

class QuizPage extends StatefulWidget {
  final String lessonId;

  const QuizPage({super.key, required this.lessonId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<String, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    log('UI: QuizPage initState for lesson ${widget.lessonId}');
    context.read<CourseBloc>().add(GetQuizRequested(widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Quiz')),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is QuizSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz submitted successfully!')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseError) {
            return Center(child: Text(state.message));
          } else if (state is QuizLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.quiz.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = state.quiz.questions[index];
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
                          quizId: state.quiz.id,
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
          }
          return const SizedBox();
        },
      ),
    );
  }
}
