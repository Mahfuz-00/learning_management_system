import 'package:flutter/material.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Core/DI/injection_container.dart';
import '../../../Domain/Repositories/learning_repository.dart';

/// The public `/free-live` page.
///
/// **Rule 12 (User Manual):** *"`/free-live` is fully public. Anyone can watch
/// without logging in or registering. This is the marketing entry point."*
///
/// Therefore this page:
/// - must be reachable while unauthenticated (the router does not guard it),
/// - must not require the Dio auth interceptor to attach a token (handled in
///   `DioClient._isPublicRoute`),
/// - must degrade gracefully if the request fails, since a first-time visitor
///   has no session to recover.
class FreeLivePage extends StatefulWidget {
  const FreeLivePage({super.key});

  @override
  State<FreeLivePage> createState() => _FreeLivePageState();
}

class _FreeLivePageState extends State<FreeLivePage> {
  final LearningRepository _repository = sl<LearningRepository>();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _classes = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repository.getActiveFreeLiveClasses();
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (classes) => setState(() {
        _loading = false;
        _classes = classes;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Live Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _load,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (_classes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.live_tv_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No free live classes right now.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back soon — free classes need no account at all.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final item = _classes[index];
        final title = (item['title'] ?? 'Free Live Class').toString();
        final teacher = (item['teacherName'] ?? item['instructorName'] ?? '')
            .toString();
        final isLive = (item['status']?.toString().toLowerCase() ?? '') == 'live';
        final courseTitle = (item['courseTitle'] ?? '').toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (courseTitle.isNotEmpty)
                  Text(courseTitle, style: const TextStyle(fontSize: 12)),
                if (teacher.isNotEmpty)
                  Text(
                    'By $teacher',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                const SizedBox(height: 4),
                Text(
                  isLive ? 'LIVE NOW — no login needed' : 'Upcoming free class',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLive ? AppColors.errorRed : Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 36),
                backgroundColor: isLive ? AppColors.errorRed : AppColors.primaryBlue,
              ),
              onPressed: () => _showJoinInfo(item),
              child: Text(isLive ? 'Join' : 'Details'),
            ),
          ),
        );
      },
    );
  }

  /// Shows the join details for a free class.
  ///
  /// Kept as a dialog because a public visitor has no enrollment context and
  /// the join payload for the free namespace is not schema-documented.
  void _showJoinInfo(Map<String, dynamic> item) {
    final roomUrl = (item['roomUrl'] ?? item['jitsiRoom'] ?? '').toString();
    final title = (item['title'] ?? 'Free Live Class').toString();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is a free public class. No account or enrollment is '
              'required.',
              style: TextStyle(fontSize: 13),
            ),
            if (roomUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Room link:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(
                roomUrl,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}