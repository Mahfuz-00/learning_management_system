import 'package:flutter/material.dart';
import '../../../Domain/Entities/quiz_entity.dart';

class QuestionWidget extends StatelessWidget {
  final QuestionEntity question;
  final int? selectedOptionIndex;
  final Function(int) onOptionSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...List.generate(question.options.length, (index) {
          final option = question.options[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedOptionIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
                width: 2,
              ),
              color: selectedOptionIndex == index
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.white,
            ),
            child: ListTile(
              title: Text(option),
              leading: Radio<int>(
                value: index,
                groupValue: selectedOptionIndex,
                onChanged: (value) => onOptionSelected(value!),
              ),
              onTap: () => onOptionSelected(index),
            ),
          );
        }),
      ],
    );
  }
}

class QuizTimer extends StatelessWidget {
  final int remainingSeconds;

  const QuizTimer({super.key, required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return Row(
      children: [
        const Icon(Icons.timer, color: Colors.red),
        const SizedBox(width: 8),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ],
    );
  }
}
