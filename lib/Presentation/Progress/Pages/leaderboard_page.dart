import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../Course/Bloc/course_bloc.dart';
import '../../Course/Bloc/course_event.dart';
import '../../Course/Bloc/course_state.dart';

/// Student ranking leaderboard.
///
/// **User Manual §4.4:** *"Student ranking. Admin can switch the whole
/// leaderboard on or off for everyone."* So an empty result is a normal state,
/// not an error — it may simply mean admin disabled the feature.
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const LoadQuizLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state.quizStatus == CourseStatus.loading && state.leaderboard.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.leaderboard.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Leaderboard unavailable',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The leaderboard may be switched off, or no results have '
                      'been recorded yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<CourseBloc>().add(const LoadQuizLeaderboard()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.leaderboard.length,
              itemBuilder: (context, index) => _row(state.leaderboard[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _row(dynamic raw, int index) {
    final rank = index + 1;
    final name = _read(raw, ['studentName', 'fullName', 'name'], 'Student');
    final score = _read(raw, ['score', 'totalScore', 'marks'], '0');
    final isTopThree = rank <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isTopThree ? _medalColor(rank).withValues(alpha: 0.08) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTopThree
              ? _medalColor(rank)
              : AppColors.primaryBlue.withValues(alpha: 0.12),
          child: isTopThree
              ? const Icon(Icons.emoji_events, color: Colors.white, size: 20)
              : Text(
                  '$rank',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          score,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryGreen,
          ),
        ),
      ),
    );
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD4AF37); // gold
      case 2:
        return const Color(0xFFA8A8A8); // silver
      default:
        return const Color(0xFFCD7F32); // bronze
    }
  }

  /// Reads the first present key from a loosely-typed leaderboard row.
  String _read(dynamic raw, List<String> keys, String fallback) {
    if (raw is Map) {
      for (final key in keys) {
        final value = raw[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return fallback;
  }
}