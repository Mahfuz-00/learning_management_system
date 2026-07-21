import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherScheduleClassPage extends StatefulWidget {
  final String courseId;

  const TeacherScheduleClassPage({super.key, required this.courseId});

  @override
  State<TeacherScheduleClassPage> createState() => _TeacherScheduleClassPageState();
}

class _TeacherScheduleClassPageState extends State<TeacherScheduleClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeCheck.nextHour();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Live Class')),
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          // Add success handling
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Class Title',
                  hintText: 'e.g. Weekly doubt clearing session',
                  validator: (v) => v!.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 24),
                const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final scheduledAt = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      log('UI: Scheduling class for $scheduledAt');
                      // context.read<CourseBloc>().add(CreateLiveClassRequested(...));
                    }
                  },
                  child: const Text('SCHEDULE CLASS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeCheck {
  static TimeOfDay nextHour() {
    final now = DateTime.now();
    return TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
  }
}
