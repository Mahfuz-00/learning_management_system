import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

class StudentMainPage extends StatelessWidget {
  final Widget child;
  const StudentMainPage({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/student-home')) return 0;
    if (location.startsWith('/student-courses')) return 1;
    if (location.startsWith('/student-classes')) return 2;
    if (location.startsWith('/student-store')) return 3;
    if (location.startsWith('/student-profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    log('UI: Student BottomNav tapped: $index');
    switch (index) {
      case 0:
        context.go('/student-home');
        break;
      case 1:
        context.go('/student-courses');
        break;
      case 2:
        context.go('/student-classes');
        break;
      case 3:
        context.go('/student-store');
        break;
      case 4:
        context.go('/student-profile');
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
