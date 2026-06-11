import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class SuccessPage extends StatelessWidget {
  final String message;

  const SuccessPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    log('UI: SuccessPage build with message: $message');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.login),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
