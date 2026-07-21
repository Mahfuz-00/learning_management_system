import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../Domain/Entities/live_class_entity.dart';
import '../../../Domain/Entities/user_entity.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class LiveClassListView extends StatelessWidget {
  final List<LiveClassEntity> liveClasses;
  final UserEntity currentUser;

  const LiveClassListView({
    super.key,
    required this.liveClasses,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (liveClasses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No live classes scheduled for this course.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        final liveClass = liveClasses[index];
        final bool isLive = liveClass.status == 'Live';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLive ? AppColors.secondaryGreen : Colors.grey.shade200, width: isLive ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(liveClass),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(liveClass.scheduledAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  liveClass.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLive
                      ? () {
                          log('UI: Joining Live Class ${liveClass.id}');
                          context.push('/live-class', extra: {
                            'liveClass': liveClass,
                            'user': currentUser,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive ? AppColors.primaryBlue : Colors.grey.shade400,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isLive ? 'JOIN CLASS NOW' : 'NOT STARTED',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(LiveClassEntity liveClass) {
    Color color;
    String text;
    if (liveClass.status == 'Live') {
      color = AppColors.secondaryGreen;
      text = 'LIVE';
    } else if (liveClass.status == 'Ended') {
      color = AppColors.errorRed;
      text = 'ENDED';
    } else {
      color = AppColors.primaryBlue;
      text = 'UPCOMING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (liveClass.status == 'Live')
            Container(
              margin: const EdgeInsets.only(right: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.secondaryGreen, shape: BoxShape.circle),
            ),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
