import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../Core/DI/injection_container.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/progress_entity.dart';
import '../../../Domain/Entities/user_entity.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../Bloc/progress_bloc.dart';
import '../Bloc/progress_event.dart';
import '../Bloc/progress_state.dart';

/// Watch history — *"Everything watched, newest first, like YouTube history."*
///
/// **User Manual §4.3:** *"Removing an item only hides it — it does not delete
/// the progress."* The page therefore offers a "Show removed" toggle and a
/// restore action, because hiding is reversible by design.
class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({super.key});

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  bool _showHidden = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final authState = sl<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      context.read<ProgressBloc>().add(LoadWatchHistory(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        actions: [
          IconButton(
            tooltip: _showHidden ? 'Hide removed items' : 'Show removed items',
            icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showHidden = !_showHidden),
          ),
        ],
      ),
      body: BlocConsumer<ProgressBloc, ProgressState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProgressStatus.loading && state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items =
              _showHidden ? state.history : state.visibleHistory;

          if (items.isEmpty) {
            return _emptyState(state);
          }

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => _historyCard(context, state, items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(ProgressState state) {
    final hasHidden = state.hiddenHistory.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.history_rounded, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Nothing watched yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          hasHidden
              ? 'You have removed some items. Tap the eye icon above to show them.'
              : 'Videos you watch will appear here, newest first.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _historyCard(
    BuildContext context,
    ProgressState state,
    WatchHistoryItemEntity item,
  ) {
    final user = _currentUser();
    if (user == null) return const SizedBox.shrink();

    final isRecording = item.contentType != 'lesson';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: item.isHidden ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRecording ? Icons.video_library_rounded : Icons.play_arrow_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.courseTitle.isNotEmpty)
                      Text(
                        item.courseTitle,
                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.percentComplete / 100,
                        minHeight: 4,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.percentComplete.toStringAsFixed(0)}% watched'
                      '${item.lastWatchedAt != null ? ' • ${DateFormat('dd MMM').format(item.lastWatchedAt!)}' : ''}',
                      style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: item.isHidden ? 'Restore' : 'Remove from history',
                icon: Icon(
                  item.isHidden ? Icons.restore : Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () {
                  if (item.isHidden) {
                    context.read<ProgressBloc>().add(
                          RestoreHistoryItem(
                            userId: user.id,
                            contentId: item.contentId,
                            isRecording: isRecording,
                          ),
                        );
                  } else {
                    context.read<ProgressBloc>().add(
                          HideHistoryItem(
                            userId: user.id,
                            contentId: item.contentId,
                            isRecording: isRecording,
                          ),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Removed from history. Your progress is kept.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reads the signed-in user from the auth singleton.
  UserEntity? _currentUser() {
    final authState = sl<AuthBloc>().state;
    if (authState is Authenticated) return authState.user;
    return null;
  }
}