import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/course_card.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    log('UI: StudentHomePage initState');
    _loadData();
  }

  void _loadData() {
    context.read<CourseBloc>().add(LoadMyEnrollments());
    context.read<CourseBloc>().add(LoadAllCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              _buildSectionTitle(context, 'Continue Learning', onSeeAll: () {
                 context.go('/student/classes');
              }),
              _buildMyEnrollments(),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Recommended Courses', onSeeAll: () {
                context.go('/student/browse');
              }),
              _buildAllCourses(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Student!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
          ),
          const Text(
            'Let\'s learn something new today.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }

  Widget _buildMyEnrollments() {
    return BlocBuilder<CourseBloc, CourseState>(
      buildWhen: (previous, current) => previous.enrolledStatus != current.enrolledStatus || previous.enrolledCourses != current.enrolledCourses,
      builder: (context, state) {
        if (state.enrolledStatus == CourseStatus.loading) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        
        if (state.enrolledCourses.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('You have not enrolled in any courses yet.'),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = state.enrolledCourses[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () => context.push('/workspace/${course.id}', extra: course),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            'http://160.191.150.185:8071/uploads/Images/${course.thumbnail}',
                            height: 100,
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey, height: 100),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAllCourses() {
    return BlocBuilder<CourseBloc, CourseState>(
      buildWhen: (previous, current) => previous.allCoursesStatus != current.allCoursesStatus || previous.allCourses != current.allCourses,
      builder: (context, state) {
        if (state.allCoursesStatus == CourseStatus.loading) {
          return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
        } else if (state.allCoursesStatus == CourseStatus.loaded) {
          return SizedBox(
            height: 240,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: state.allCourses.length,
              itemBuilder: (context, index) {
                final course = state.allCourses[index];
                return CourseCard(
                  course: course,
                  onTap: () {
                    context.push('/course/${course.id}');
                  },
                  onWishlistToggle: () {
                    context.read<CourseBloc>().add(ToggleWishlistEvent(course.id));
                  },
                );
              },
            ),
          );
        } else if (state.allCoursesStatus == CourseStatus.error) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(state.errorMessage ?? 'Error loading courses'),
          );
        }
        return const SizedBox();
      },
    );
  }
}
