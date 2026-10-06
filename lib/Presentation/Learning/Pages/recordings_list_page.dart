import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/live_class_entity.dart';

/// Lists the past live classes the teacher uploaded.
///
/// **User Manual §4.3:** *"Past live classes the teacher uploaded. Plays in the
/// site's own video player."*
///
/// **Rule 11 context:** these recordings exist only because the teacher pressed
/// record in their browser and uploaded the file afterwards — *"There is no
/// automatic recording."*
class RecordingsListPage extends StatelessWidget {
  final String courseId;
  final List<LiveClassEntity> recordings;

  const RecordingsListPage({
    super.key,
    required this.courseId,
    required this.recordings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordings')),
      body: recordings.isEmpty
          ? _empty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(
                      recording.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(recording.scheduledAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _play(context, recording),
                  ),
                );
              },
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
            Icon(Icons.video_library_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recordings yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Recordings appear here after your teacher uploads them. Live '
              'classes are recorded by the teacher\'s browser, not the server.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the recording in the app's own player.
  void _play(BuildContext context, LiveClassEntity recording) {
    final url = recording.roomUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This recording is not available yet.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RecordingPlayerPage(
          title: recording.title,
          url: url,
        ),
      ),
    );
  }
}

/// Minimal in-app playback surface for a recording.
class _RecordingPlayerPage extends StatelessWidget {
  final String title;
  final String url;

  const _RecordingPlayerPage({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 72, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Recording stream',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SelectableText(
                url,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}