import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/teacher_course_list_item.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class TeacherCourseManagementPage extends StatefulWidget {
  const TeacherCourseManagementPage({super.key});

  @override
  State<TeacherCourseManagementPage> createState() => _TeacherCourseManagementPageState();
}

class _TeacherCourseManagementPageState extends State<TeacherCourseManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadTeacherCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.teacherStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.teacherStatus == CourseStatus.loaded) {
            if (state.teacherCourses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('You haven\'t created any courses yet.', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRouter.teacherCreateCourse);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('CREATE FIRST COURSE'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.teacherCourses.length,
              itemBuilder: (context, index) {
                final course = state.teacherCourses[index];
                return TeacherCourseListItem(
                  course: course,
                  onEdit: () {
                    context.push('/teacher/course-details/${course.id}');
                  },
                );
              },
            );
          } else if (state.teacherStatus == CourseStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error loading courses'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           context.push(AppRouter.teacherCreateCourse);
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW COURSE', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
