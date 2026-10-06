import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Core/Theme/app_colors.dart';
import '../Bloc/notification_bloc.dart';
import '../Bloc/notification_event.dart';
import '../Bloc/notification_state.dart';

/// All notifications, under the bell icon.
///
/// **User Manual §4.5:** *"Refreshes every 30 seconds. These are in-app only —
/// **no email or phone push is sent** for live classes."*
///
/// The page states that limitation explicitly so a student does not assume they
/// will be alerted elsewhere.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (!state.hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context
                    .read<NotificationBloc>()
                    .add(const MarkAllNotificationsRead()),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<NotificationBloc>().add(const LoadNotifications()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Card(
                  color: notification.isRead
                      ? null
                      : AppColors.primaryBlue.withValues(alpha: 0.05),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.message != null)
                          Text(
                            notification.message!,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          notification.relativeTime,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () => context
                        .read<NotificationBloc>()
                        .add(MarkNotificationRead(notification.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.notifications_none_rounded, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'No notifications',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Live-class alerts and announcements appear here. They are in-app '
          'only — no email or phone notification is sent.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12.5),
        ),
      ],
    );
  }
}