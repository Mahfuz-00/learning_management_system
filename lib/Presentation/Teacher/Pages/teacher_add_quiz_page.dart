import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherAddQuizPage extends StatefulWidget {
  final String lessonId;

  const TeacherAddQuizPage({super.key, required this.lessonId});

  @override
  State<TeacherAddQuizPage> createState() => _TeacherAddQuizPageState();
}

class _TeacherAddQuizPageState extends State<TeacherAddQuizPage> {
  final _titleController = TextEditingController();
  final List<QuestionInput> _questions = [];

  @override
  void initState() {
    super.initState();
    _addQuestion(); // Start with one question
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionInput());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    }
  }

  void _submitQuiz() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a quiz title')));
      return;
    }

    final List<Map<String, dynamic>> questionsData = _questions.map((q) {
      return {
        'question': q.textController.text,
        'options': q.optionControllers.map((c) => c.text).toList(),
        'correctAnswer': q.optionControllers[q.correctOptionIndex].text,
      };
    }).toList();

    context.read<CourseBloc>().add(AddQuizQuestionRequested(
      lessonId: widget.lessonId,
      quizData: {
        'title': _titleController.text,
        'questions': questionsData,
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Quiz')),
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.quizStatus == CourseStatus.loaded && state.errorMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz published successfully!'), backgroundColor: AppColors.secondaryGreen));
            context.pop();
          } else if (state.quizStatus == CourseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: AppColors.errorRed));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Quiz Title',
                hintText: 'e.g. Final Assessment',
              ),
              const SizedBox(height: 24),
              const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(index);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('ADD ANOTHER QUESTION'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 40),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state.quizStatus == CourseStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _submitQuiz,
                    child: const Text('PUBLISH QUIZ'),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  onPressed: () => _removeQuestion(index),
                ),
              ],
            ),
            CustomTextField(
              controller: q.textController,
              labelText: 'Question Text',
              hintText: 'Enter your question here',
            ),
            const SizedBox(height: 16),
            const Text('Options (Mark the correct one)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...List.generate(4, (oIndex) {
              return Row(
                children: [
                  Radio<int>(
                    value: oIndex,
                    groupValue: q.correctOptionIndex,
                    onChanged: (val) => setState(() => q.correctOptionIndex = val!),
                  ),
                  Expanded(
                    child: TextField(
                      controller: q.optionControllers[oIndex],
                      decoration: InputDecoration(
                        hintText: 'Option ${oIndex + 1}',
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class QuestionInput {
  final textController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctOptionIndex = 0;
}
