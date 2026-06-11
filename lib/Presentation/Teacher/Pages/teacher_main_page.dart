import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

class TeacherMainPage extends StatelessWidget {
  final Widget child;
  const TeacherMainPage({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/teacher-home')) return 0;
    if (location.startsWith('/teacher-courses')) return 1;
    if (location.startsWith('/teacher-profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    log('UI: Teacher BottomNav tapped: $index');
    switch (index) {
      case 0:
        context.go('/teacher-home');
        break;
      case 1:
        context.go('/teacher-courses');
        break;
      case 2:
        context.go('/teacher-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
