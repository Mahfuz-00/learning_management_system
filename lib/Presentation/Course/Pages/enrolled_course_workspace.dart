import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../../../Core/Theme/app_colors.dart';
import '../Widgets/lesson_list_view.dart';
import '../Widgets/live_class_list_view.dart';
import '../Widgets/quiz_list_view.dart';
import 'dart:developer';

class EnrolledCourseWorkspace extends StatefulWidget {
  final String courseId;
  final CourseEntity? course;

  const EnrolledCourseWorkspace({super.key, required this.courseId, this.course});

  @override
  State<EnrolledCourseWorkspace> createState() => _EnrolledCourseWorkspaceState();
}

class _EnrolledCourseWorkspaceState extends State<EnrolledCourseWorkspace> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<CourseBloc>().add(LoadCourseDetails(widget.courseId));
    context.read<CourseBloc>().add(LoadLiveClassesRequested(widget.courseId));
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
        title: Text(widget.course?.title ?? 'Course Workspace'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.secondaryGreen,
          tabs: const [
            Tab(text: 'Lessons'),
            Tab(text: 'Live Classes'),
            Tab(text: 'Quizzes'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.detailsStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          } else if (state.detailsStatus == CourseStatus.loaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                LessonListView(lessons: state.lessons),
                _buildLiveClassesTab(state),
                QuizListView(courseId: widget.courseId, quizzes: const []), // Fetching quizzes logic can be added
                _buildCertificatesTab(),
              ],
            );
          } else if (state.detailsStatus == CourseStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error loading workspace'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLiveClassesTab(CourseState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return LiveClassListView(
            liveClasses: const [], // Map from state when implemented
            currentUser: authState.user,
          );
        }
        return const Center(child: Text('Unauthorized'));
      },
    );
  }

  Widget _buildCertificatesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Complete all lessons to earn your certificate!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: null, // Disabled until completion
            child: const Text('DOWNLOAD CERTIFICATE'),
          ),
        ],
      ),
    );
  }
}
