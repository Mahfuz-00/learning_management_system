import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherAddLessonPage extends StatefulWidget {
  final String courseId;

  const TeacherAddLessonPage({super.key, required this.courseId});

  @override
  State<TeacherAddLessonPage> createState() => _TeacherAddLessonPageState();
}

class _TeacherAddLessonPageState extends State<TeacherAddLessonPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  bool _isYoutube = true;
  File? _videoFile;
  String? _videoFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      // Using explicit prefix to ensure we are calling the correct FilePicker class
      // and its static platform getter from the file_picker package.
      final fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final size = await file.length();
        if (size > 500 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video size must be less than 500MB')),
          );
          return;
        }
        setState(() {
          _videoFile = file;
          _videoFileName = result.files.single.name;
        });
      }
    } catch (e) {
      log('Error picking video: $e');
    }
  }

  void _onSaveLesson() {
    if (_formKey.currentState!.validate()) {
      if (!_isYoutube && _videoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a video file or provide a YouTube URL')),
        );
        return;
      }

      final data = {
        'courseId': widget.courseId,
        'title': _titleController.text.trim(),
        'description': _contentController.text.trim(),
        'videoUrl': _isYoutube ? _youtubeUrlController.text.trim() : null,
        'videoType': _isYoutube ? 'YouTube' : 'Upload',
      };

      context.read<CourseBloc>().add(AddLessonRequested(
            data: data,
            video: !_isYoutube ? _videoFile : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Lesson')),
      body: BlocListener<CourseBloc, CourseState>(
        listenWhen: (prev, curr) => prev.detailsStatus != curr.detailsStatus,
        listener: (context, state) {
          if (state.detailsStatus == CourseStatus.loaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lesson added successfully!'), backgroundColor: AppColors.secondaryGreen),
            );
            context.pop();
          } else if (state.detailsStatus == CourseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to add lesson'), backgroundColor: AppColors.errorRed),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Lesson Title',
                  hintText: 'e.g. Introduction to Physics',
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _contentController,
                  labelText: 'Lesson Content (Text)',
                  hintText: 'Enter lesson description or notes',
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Lesson Media',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('YouTube Link'),
                        selected: _isYoutube,
                        onSelected: (val) => setState(() => _isYoutube = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Video Upload'),
                        selected: !_isYoutube,
                        onSelected: (val) => setState(() => _isYoutube = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isYoutube)
                  CustomTextField(
                    controller: _youtubeUrlController,
                    labelText: 'YouTube URL',
                    hintText: 'https://youtube.com/watch?v=...',
                    prefixIcon: Icons.link,
                    validator: (v) => _isYoutube && v!.isEmpty ? 'YouTube URL is required' : null,
                  )
                else
                  _buildVideoPicker(),
                const SizedBox(height: 48),
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state.detailsStatus == CourseStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _onSaveLesson,
                      child: const Text('SAVE LESSON'),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickVideo,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primaryBlue),
                const SizedBox(height: 12),
                Text(
                  _videoFileName ?? 'Select Video File (Max 500MB)',
                  style: TextStyle(color: _videoFileName != null ? AppColors.textPrimary : AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (_videoFileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () => setState(() {
                _videoFile = null;
                _videoFileName = null;
              }),
              icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
              label: const Text('Remove file', style: TextStyle(color: AppColors.errorRed, fontSize: 12)),
            ),
          ),
      ],
    );
  }
}
