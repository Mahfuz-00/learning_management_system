import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Widgets/teacher_stat_card.dart';
import '../Widgets/teacher_course_card.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import 'dart:developer';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadTeacherCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/teacher/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CourseBloc>().add(LoadTeacherCourses());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              const Text(
                'Assigned Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildTeacherCourses(),
              const SizedBox(height: 24),
              const Text(
                'Performance Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = "Instructor";
        if (state is Authenticated) {
          name = state.user.fullName;
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/teacher/create-course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGreen,
                  minimumSize: const Size(150, 40),
                ),
                child: const Text('CREATE NEW COURSE'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeacherCourses() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state.teacherStatus == CourseStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.teacherStatus == CourseStatus.loaded) {
          if (state.teacherCourses.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('No courses assigned yet.')),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.teacherCourses.length,
            itemBuilder: (context, index) {
              return TeacherCourseCard(
                course: state.teacherCourses[index],
                onTap: () => context.push('/teacher/course-details/${state.teacherCourses[index].id}'),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: const [
        TeacherStatCard(
          title: 'Total Students',
          value: '450',
          icon: Icons.people_outline,
          color: AppColors.primaryBlue,
        ),
        TeacherStatCard(
          title: 'Revenue',
          value: '৳12.5k',
          icon: Icons.payments_outlined,
          color: AppColors.secondaryGreen,
        ),
        TeacherStatCard(
          title: 'Classes Today',
          value: '02',
          icon: Icons.video_camera_front_outlined,
          color: AppColors.deepPurple,
        ),
        TeacherStatCard(
          title: 'Course Rating',
          value: '4.9',
          icon: Icons.star_border_rounded,
          color: Colors.amber,
        ),
      ],
    );
  }
}
