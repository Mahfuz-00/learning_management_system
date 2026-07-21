import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/course_card.dart';
import '../../../Core/Theme/app_colors.dart';

class StudentBrowsePage extends StatefulWidget {
  const StudentBrowsePage({super.key});

  @override
  State<StudentBrowsePage> createState() => _StudentBrowsePageState();
}

class _StudentBrowsePageState extends State<StudentBrowsePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadAllCourses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Courses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                ),
              ),
              onChanged: (value) {
                // Implement local filtering or trigger search event
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                if (state.allCoursesStatus == CourseStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.allCoursesStatus == CourseStatus.loaded) {
                  if (state.allCourses.isEmpty) {
                    return const Center(child: Text('No courses found.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.allCourses.length,
                    itemBuilder: (context, index) {
                      final course = state.allCourses[index];
                      return CourseCard(
                        course: course,
                        onTap: () => context.push('/course/${course.id}'),
                        onWishlistToggle: () {
                          context.read<CourseBloc>().add(ToggleWishlistEvent(course.id));
                        },
                      );
                    },
                  );
                } else if (state.allCoursesStatus == CourseStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Error loading courses'));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
