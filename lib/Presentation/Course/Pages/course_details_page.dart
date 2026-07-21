import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Constants/app_constants.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    context.read<CourseBloc>().add(LoadCourseDetails(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          if (state.detailsStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state.detailsStatus == CourseStatus.loaded && state.selectedCourse != null) {
            final course = state.selectedCourse!;
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(course),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseHeader(course),
                        const SizedBox(height: 24),
                        const Text(
                          'Course Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description ?? 'No description provided.',
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        _buildCurriculumPreview(state.lessons),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          if (state.detailsStatus == CourseStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load course details'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadDetails, child: const Text('Retry')),
                ],
              ),
            );
          }
          
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      bottomSheet: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.detailsStatus == CourseStatus.loaded && state.selectedCourse != null) {
            final course = state.selectedCourse!;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text(
                            course.price == 0 ? 'Free' : '৳${course.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (course.isEnrolled) {
                            context.push('/workspace/${course.id}', extra: course);
                          } else {
                            context.read<CourseBloc>().add(EnrollInCourseEvent(course.id));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: course.isEnrolled ? AppColors.secondaryGreen : AppColors.primaryBlue,
                        ),
                        child: Text(course.isEnrolled ? 'GO TO WORKSPACE' : 'ENROLL NOW'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSliverAppBar(CourseEntity course) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: '${AppConstants.imagesBaseUrl}${course.thumbnail}',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(CourseEntity course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'BESTSELLER',
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(
                course.isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: course.isWishlisted ? AppColors.errorRed : Colors.grey,
              ),
              onPressed: () {
                context.read<CourseBloc>().add(ToggleWishlistEvent(course.id));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          course.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              'By ${course.instructorName ?? "Expert Instructor"}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurriculumPreview(List<LessonEntity> lessons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Content (${lessons.length} Lessons)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: lessons.length > 5 ? 5 : lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                lesson.hasVideo ? Icons.play_circle_fill : Icons.description,
                color: AppColors.primaryBlue,
              ),
              title: Text(lesson.title),
              trailing: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
            );
          },
        ),
        if (lessons.length > 5)
          TextButton(
            onPressed: () {},
            child: const Text('View all lessons'),
          ),
      ],
    );
  }
}
