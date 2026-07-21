import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Navigation/app_router.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import 'dart:developer';

class TeacherCourseDetailsPage extends StatefulWidget {
  final String courseId;

  const TeacherCourseDetailsPage({super.key, required this.courseId});

  @override
  State<TeacherCourseDetailsPage> createState() => _TeacherCourseDetailsPageState();
}

class _TeacherCourseDetailsPageState extends State<TeacherCourseDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<CourseBloc>().add(LoadCourseDetails(widget.courseId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Course'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryGreen,
          tabs: const [
            Tab(text: 'Curriculum'),
            Tab(text: 'Students'),
            Tab(text: 'Live Classes'),
          ],
        ),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.detailsStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.detailsStatus == CourseStatus.loaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildCurriculumTab(state.lessons),
                _buildStudentsTab(),
                _buildLiveClassesTab(),
              ],
            );
          } else if (state.detailsStatus == CourseStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error loading details'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            context.push('/teacher/add-lesson/${widget.courseId}');
          } else if (_tabController.index == 2) {
             // context.push('/teacher/schedule-live/${widget.courseId}');
          }
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCurriculumTab(List<LessonEntity> lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(lesson.hasVideo ? Icons.play_circle_fill : Icons.description, color: AppColors.primaryBlue),
            title: Text(lesson.title),
            subtitle: Text(lesson.hasVideo ? 'Video' : 'Text'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Lesson')),
                const PopupMenuItem(value: 'quiz', child: Text('Manage Quiz')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (val) {
                if (val == 'quiz') {
                  context.push('/teacher/add-quiz/${lesson.id}');
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Total Students: 42'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/teacher/roster/${widget.courseId}'),
            child: const Text('VIEW FULL ROSTER'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassesTab() {
    return const Center(child: Text('No live classes scheduled.'));
  }
}
