import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Domain/Entities/comment_entity.dart';
import '../../../Core/Theme/app_colors.dart';

class CourseRatingWidget extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onAddRating;

  const CourseRatingWidget({
    super.key,
    required this.summary,
    required this.onAddRating,
  });

  @override
  Widget build(BuildContext context) {
    final double average = (summary['averageRating'] ?? 0).toDouble();
    final int total = summary['totalRatings'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                _buildStars(average),
                const SizedBox(height: 4),
                Text('$total Ratings', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildDistributionBars(summary['distribution'] ?? {}),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onAddRating,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('WRITE A REVIEW'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildDistributionBars(Map<String, dynamic> dist) {
    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        final double percent = (dist[star.toString()] ?? 0).toDouble() / 100; // Simplified
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$star', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.amber,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CommentListItem extends StatelessWidget {
  final CommentEntity comment;

  const CommentListItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            backgroundImage: comment.userProfilePicture != null ? NetworkImage(comment.userProfilePicture!) : null,
            child: comment.userProfilePicture == null ? Text(comment.userName[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      DateFormat('MMM dd, yyyy').format(comment.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
