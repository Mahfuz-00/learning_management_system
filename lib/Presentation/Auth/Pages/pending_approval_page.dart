import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_event.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Navigation/app_router.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 100,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 32),
              Text(
                'Approval Pending',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your teacher account is currently under review by our administrators. You will gain access to the dashboard once your profile is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Re-check status or logout
                  context.read<AuthBloc>().add(AuthCheckRequested());
                },
                child: const Text('CHECK STATUS'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go(AppRouter.login);
                },
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
