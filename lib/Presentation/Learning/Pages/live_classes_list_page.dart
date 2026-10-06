import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/live_class_entity.dart';

/// Lists the live classes for a course.
///
/// **User Manual §4.3:** *"Upcoming and running live classes. Click Join to
/// enter. Attendance is recorded."* Attendance feeds 10% of the progress score
/// (§5.2), so joining matters.
class LiveClassesListPage extends StatelessWidget {
  final String courseId;
  final List<LiveClassEntity> liveClasses;

  const LiveClassesListPage({
    super.key,
    required this.courseId,
    required this.liveClasses,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = liveClasses.where((c) => !c.isEnded).toList();
    final past = liveClasses.where((c) => c.isEnded).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Live Classes')),
      body: liveClasses.isEmpty
          ? _empty()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const Text(
                    'Upcoming & Live',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...upcoming.map((c) => _card(context, c)),
                  const SizedBox(height: 16),
                ],
                if (past.isNotEmpty) ...[
                  const Text(
                    'Past classes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...past.map((c) => _card(context, c)),
                ],
              ],
            ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.live_tv_rounded, size: 56, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No live classes scheduled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your teacher has not scheduled a live class for this course yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, LiveClassEntity liveClass) {
    final isLive = liveClass.isLive;
    final isEnded = liveClass.isEnded;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: (isLive ? AppColors.errorRed : AppColors.primaryBlue)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isLive ? Icons.sensors : Icons.event_available,
            color: isLive ? AppColors.errorRed : AppColors.primaryBlue,
          ),
        ),
        title: Text(
          liveClass.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(liveClass.scheduledAt),
              style: const TextStyle(fontSize: 12),
            ),
            if (isLive)
              const Text(
                'LIVE NOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorRed,
                ),
              )
            else if (isEnded)
              const Text(
                'Ended',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        trailing: isEnded
            ? null
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(70, 36),
                  backgroundColor:
                      isLive ? AppColors.errorRed : AppColors.primaryBlue,
                ),
                onPressed: () => context.push(
                  '/live-class',
                  extra: {'liveClass': liveClass, 'user': null},
                ),
                child: const Text('Join'),
              ),
      ),
    );
  }
}

/// Helper extension for the "Ended" state.
extension LiveClassEnded on LiveClassEntity {
  /// True once the class has finished.
  bool get isEnded {
    final status = this.status.toLowerCase();
    return status == 'ended' || status == 'completed' || status == 'cancelled';
  }
}