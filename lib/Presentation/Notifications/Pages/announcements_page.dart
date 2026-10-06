import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../Bloc/notification_bloc.dart';
import '../Bloc/notification_event.dart';
import '../Bloc/notification_state.dart';

/// Public announcements page.
///
/// **User Manual §4.5:** *"Public notices from admin. They expire
/// automatically on a date admin sets."*
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadAnnouncements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final announcements = state.activeAnnouncements;

          if (announcements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.campaign_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No announcements',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'There are no active notices right now.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<NotificationBloc>().add(const LoadAnnouncements()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.campaign_rounded,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (announcement.body != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            announcement.body!,
                            style: const TextStyle(fontSize: 13.5, height: 1.4),
                          ),
                        ],
                        if (announcement.publishedAt != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Published ${DateFormat('dd MMM yyyy').format(announcement.publishedAt!)}'
                            '${announcement.expiresAt != null ? ' • Expires ${DateFormat('dd MMM yyyy').format(announcement.expiresAt!)}' : ''}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}