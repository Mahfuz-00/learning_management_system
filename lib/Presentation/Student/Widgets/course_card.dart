import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Core/Constants/app_constants.dart';
import '../../../Core/Theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final VoidCallback? onWishlistToggle;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: '${AppConstants.imagesPath}${course.thumbnail}',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        course.isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: course.isWishlisted ? AppColors.errorRed : Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Rule 3: an Upcoming course is badged "Coming soon" and is
                // kept out of "Most popular" (handled by the parent list).
                if (course.isComingSoon)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (course.isEnrolled)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ENROLLED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructorName ?? 'Instructor',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rule 3: an Upcoming course shows NO price and the word
                      // "Free" is never displayed for it.
                      Text(
                        course.isComingSoon
                            ? 'Coming soon'
                            : (course.isFree
                                ? 'Free'
                                : '৳${course.price.toStringAsFixed(0)}'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: course.isComingSoon
                              ? Colors.orange
                              : AppColors.primaryBlue,
                          fontSize: course.isComingSoon ? 12.5 : 14,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 14, color: AppColors.secondaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            // Rule 5: this may be marketing text, not a real
                            // count. Never use it to verify an enrollment.
                            course.marketingVideoText ?? '${course.totalLessons} Lessons',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
