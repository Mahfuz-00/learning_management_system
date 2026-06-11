import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Widgets/forgot_password_widgets.dart';
import 'dart:developer';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: ForgotPasswordPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Enter your email address to receive an OTP to reset your password.'),
              SizedBox(height: 40),
              ForgotPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}
