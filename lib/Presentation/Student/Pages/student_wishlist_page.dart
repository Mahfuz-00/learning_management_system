import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';
import '../Widgets/course_card.dart';
import '../../../Core/Theme/app_colors.dart';

class StudentWishlistPage extends StatefulWidget {
  const StudentWishlistPage({super.key});

  @override
  State<StudentWishlistPage> createState() => _StudentWishlistPageState();
}

class _StudentWishlistPageState extends State<StudentWishlistPage> {
  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    context.read<CourseBloc>().add(LoadAllCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.allCoursesStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.allCoursesStatus == CourseStatus.loaded) {
            final wishlist = state.allCourses.where((c) => c.isWishlisted).toList();

            if (wishlist.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Your wishlist is empty',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => context.go('/student/browse'),
                      child: const Text('Explore Courses'),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final course = wishlist[index];
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
            return Center(child: Text(state.errorMessage ?? 'Error loading wishlist'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
