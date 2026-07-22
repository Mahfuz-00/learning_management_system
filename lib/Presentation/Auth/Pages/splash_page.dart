import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../Core/Navigation/app_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_state.dart';
import '../../../Core/Theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // 1. Give the splash screen a minimum display duration (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Evaluate Auth state and navigate to destination
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      final user = authState.user;
      if (user.isTeacher && user.status != 'Approved') {
        context.go(AppRouter.pendingApproval);
      } else if (user.isStudent) {
        context.go(AppRouter.studentHome);
      } else {
        context.go(AppRouter.teacherHome);
      }
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Main Branding Section
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nirvoor-icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nirvoor e-Learning',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom Indicator Section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final String statusText =
                state is Authenticated ? 'Logging in...' : 'Checking authentication...';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}