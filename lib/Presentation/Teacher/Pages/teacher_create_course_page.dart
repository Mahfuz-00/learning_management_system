import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class TeacherCreateCoursePage extends StatefulWidget {
  const TeacherCreateCoursePage({super.key});

  @override
  State<TeacherCreateCoursePage> createState() => _TeacherCreateCoursePageState();
}

class _TeacherCreateCoursePageState extends State<TeacherCreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _thumbnailFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _thumbnailFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: BlocListener<CourseBloc, CourseState>(
        listenWhen: (prev, curr) => prev.teacherStatus != curr.teacherStatus,
        listener: (context, state) {
          if (state.teacherStatus == CourseStatus.loaded) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course created successfully!'), backgroundColor: AppColors.secondaryGreen),
            );
            context.pop();
          } else if (state.teacherStatus == CourseStatus.error) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to create course'), backgroundColor: AppColors.errorRed),
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
                _buildThumbnailPicker(),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Course Title',
                  hintText: 'Enter course name',
                  validator: (v) => v!.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Enter course details',
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Price (৳)',
                  hintText: '0 for Free',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Price required' : null,
                ),
                const SizedBox(height: 40),
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state.teacherStatus == CourseStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final data = {
                            'title': _titleController.text.trim(),
                            'description': _descriptionController.text.trim(),
                            'price': double.tryParse(_priceController.text) ?? 0.0,
                          };
                          context.read<CourseBloc>().add(CreateCourseRequested(
                            data: data,
                            thumbnail: _thumbnailFile,
                          ));
                        }
                      },
                      child: const Text('CREATE COURSE'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          image: _thumbnailFile != null 
              ? DecorationImage(image: FileImage(_thumbnailFile!), fit: BoxFit.cover)
              : null,
        ),
        child: _thumbnailFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primaryBlue),
                  SizedBox(height: 8),
                  Text('Upload Course Thumbnail', style: TextStyle(color: AppColors.textSecondary)),
                ],
              )
            : null,
      ),
    );
  }
}
