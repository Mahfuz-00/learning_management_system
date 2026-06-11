import 'package:flutter/material.dart';
import '../Widgets/teacher_home_widgets.dart';
import 'dart:developer';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: TeacherHomePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: TeacherStatsCard(
                    title: 'Total Students',
                    value: '128',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TeacherStatsCard(
                    title: 'Active Courses',
                    value: '5',
                    icon: Icons.book,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: TeacherStatsCard(
                    title: 'Revenue',
                    value: '\$1,250',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TeacherStatsCard(
                    title: 'Rating',
                    value: '4.8',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Upcoming Classes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const UpcomingActivitiesList(),
          ],
        ),
      ),
    );
  }
}
