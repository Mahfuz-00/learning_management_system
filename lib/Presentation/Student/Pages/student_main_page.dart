import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Core/Theme/app_colors.dart';

class StudentMainPage extends StatelessWidget {
  final Widget child;
  const StudentMainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    int getIndex() {
      if (location.startsWith('/student/home')) return 0;
      if (location.startsWith('/student/browse')) return 1;
      if (location.startsWith('/student/wishlist')) return 2;
      if (location.startsWith('/student/profile')) return 3;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getIndex(),
        onTap: (index) {
          switch (index) {
            case 0: context.go('/student'); break;
            case 1: context.go('/student/browse'); break;
            case 2: context.go('/student/wishlist'); break;
            case 3: context.go('/student/profile'); break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search_rounded), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
