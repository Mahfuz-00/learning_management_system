import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Constants/app_constants.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/course_state.dart';

/// One course, shown to anyone (Manual §9: `/course-details/<id>`).
///
/// *"Description, price, teacher, what you get. One single layout for every
/// course."*
///
/// This page is where **Rule 2** and **Rule 3** become visible:
/// - **Rule 3** — an Upcoming course shows a "Coming soon" badge, **no price**
///   and **never the word "Free"**, and its Buy button is disabled.
/// - **Rule 2** — a course whose start date has passed and which the student was
///   never enrolled in shows an "enrollment closed" state rather than a bare
///   error.
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

  /// Sends the student to checkout.
  ///
  /// A free course still goes through checkout, because the server is the
  /// authority on whether anything is payable after discounts (Rule 4) — it
  /// simply skips the payment page when the amount is zero.
  void _startCheckout(CourseEntity course) {
    context.push(
      '/checkout/${course.id}',
      extra: {'title': course.title, 'price': course.price},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          // A successful direct enrollment (free course) refreshes the page.
          if (state.actionSucceeded && !state.isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are enrolled! Open My Courses to start.'),
                backgroundColor: AppColors.secondaryGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.detailsStatus == CourseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.detailsStatus == CourseStatus.error) {
            return _errorState(state.errorMessage);
          }

          final course = state.selectedCourse;
          if (course == null) {
            return const Center(child: Text('Course not found.'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(course),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseHeader(course),
                      const SizedBox(height: 16),
                      _buildRuleNotice(course),
                      const SizedBox(height: 20),
                      const Text(
                        'Course Description',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description ?? 'No description provided.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCourseFacts(course),
                      const SizedBox(height: 24),
                      _buildCurriculumPreview(state.lessons),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          final course = state.selectedCourse;
          if (state.detailsStatus != CourseStatus.loaded || course == null) {
            return const SizedBox.shrink();
          }
          return _buildBottomBar(course, state.isSubmitting);
        },
      ),
    );
  }

  // ── Rule 2 & 3 notices ─────────────────────────────────────────────────

  /// Surfaces the two rules that are invisible without being told about them.
  Widget _buildRuleNotice(CourseEntity course) {
    // Rule 3: Upcoming courses are visible but not buyable.
    if (course.isComingSoon) {
      return _notice(
        icon: Icons.schedule_rounded,
        color: Colors.orange,
        title: 'Coming soon',
        body: 'This course is not open for enrollment yet. '
            '${course.enrollmentOpensAt != null ? 'Enrollment opens on ${_formatDate(course.enrollmentOpensAt!)}. ' : ''}'
            'The price and a Buy button will appear on that day.',
      );
    }

    // Rule 2: the start date is also the last day to enrol.
    if (course.isEnrollmentClosed) {
      return _notice(
        icon: Icons.lock_outline,
        color: Colors.grey.shade700,
        title: 'Enrollment closed',
        body: 'The start date has passed, so this course is no longer open to '
            'new students.',
      );
    }

    if (course.isEnrolled) {
      return _notice(
        icon: Icons.check_circle_outline,
        color: AppColors.secondaryGreen,
        title: 'You are enrolled',
        body: 'Open the course hub to access lessons, live classes, exams and '
            'practice material.',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _notice({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header, facts, curriculum ──────────────────────────────────────────

  Widget _buildSliverAppBar(CourseEntity course) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: '${AppConstants.imagesPath}${course.thumbnail}',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(CourseEntity course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Rule 3: an Upcoming course is badged "Coming soon", never
            // "BESTSELLER" and never priced.
            if (course.isComingSoon)
              _badge('COMING SOON', Colors.orange)
            else if (course.isEnrolled)
              _badge('ENROLLED', AppColors.secondaryGreen)
            else
              _badge('AVAILABLE', AppColors.primaryBlue),
            const Spacer(),
            IconButton(
              icon: Icon(
                course.isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: course.isWishlisted ? AppColors.errorRed : Colors.grey,
              ),
              onPressed: () => context
                  .read<CourseBloc>()
                  .add(ToggleWishlistEvent(course.id)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          course.title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'By ${course.instructorName ?? "Expert Instructor"}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            if (course.rating != null) ...[
              const Icon(Icons.star_rounded, size: 17, color: Colors.amber),
              const SizedBox(width: 3),
              Text(
                course.rating!.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Key facts about the course.
  ///
  /// **Rule 6** is applied here: the duration is shown in **months**, even
  /// though the backend field is named `durationMinutes`.
  Widget _buildCourseFacts(CourseEntity course) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _factRow(
              Icons.video_library_outlined,
              'Video lessons',
              '${course.totalLessons}',
            ),
            if (course.durationMonths > 0)
              _factRow(
                Icons.calendar_month_outlined,
                'Duration',
                // Rule 6: MONTHS, not minutes.
                '${course.durationMonths} month${course.durationMonths == 1 ? '' : 's'}',
              ),
            if (course.startDate != null)
              _factRow(
                Icons.event_outlined,
                'Starts',
                _formatDate(course.startDate!),
              ),
            if (course.category != null)
              _factRow(Icons.category_outlined, 'Category', course.category!),
            if (course.level != null)
              _factRow(Icons.signal_cellular_alt, 'Level', course.level!),
          ],
        ),
      ),
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13.5)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
        if (lessons.isEmpty)
          const Text(
            'Lesson list will appear here once the course is published.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          )
        else
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
                title: Text(lesson.title, style: const TextStyle(fontSize: 14)),
                trailing: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.grey,
                ),
              );
            },
          ),
        if (lessons.length > 5)
          TextButton(
            onPressed: () {},
            child: Text('View all ${lessons.length} lessons'),
          ),
      ],
    );
  }

  // ── Bottom action bar ──────────────────────────────────────────────────

  Widget _buildBottomBar(CourseEntity course, bool busy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
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
                  const Text(
                    'Price',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  // Rule 3: an Upcoming course shows NO price and never the
                  // word "Free".
                  if (course.isComingSoon)
                    const Text(
                      'To be announced',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  else
                    Text(
                      course.isFree
                          ? 'Free'
                          : '৳${course.price.toStringAsFixed(0)}',
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
              child: _buildPrimaryAction(course, busy),
            ),
          ],
        ),
      ),
    );
  }

  /// The single primary action, which changes meaning per Rule 2 / Rule 3.
  Widget _buildPrimaryAction(CourseEntity course, bool busy) {
    // Rule 3 — visible but not buyable.
    if (course.isComingSoon) {
      return ElevatedButton.icon(
        onPressed: () => _showPreBookSheet(course),
        icon: const Icon(Icons.notifications_active_outlined, size: 18),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        label: const Text('NOTIFY ME'),
      );
    }

    // Rule 2 — enrollment closed.
    if (course.isEnrollmentClosed) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text('ENROLLMENT CLOSED'),
      );
    }

    if (course.isEnrolled) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/hub/${course.id}', extra: course),
        icon: const Icon(Icons.school_rounded, size: 18),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryGreen),
        label: const Text('GO TO COURSE HUB'),
      );
    }

    return ElevatedButton(
      onPressed: busy ? null : () => _startCheckout(course),
      child: Text(busy ? 'PLEASE WAIT…' : 'ENROLL / BUY'),
    );
  }

  /// Rule 3 — the natural CTA for an Upcoming course is to register interest.
  void _showPreBookSheet(CourseEntity course) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get notified',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We will let you know when "${course.title}" opens for '
              'enrollment${course.enrollmentOpensAt != null ? ' on ${_formatDate(course.enrollmentOpensAt!)}' : ''}.',
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              // Rule 2 context: a course can legitimately disappear, so the
              // message avoids sounding like a crash.
              message ?? 'This course is not available right now.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetails, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  /// Formats a date without pulling in a locale-aware converter, because all
  /// times are Bangladesh local and must be shown verbatim.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}