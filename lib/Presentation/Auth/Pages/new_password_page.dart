import 'package:flutter/material.dart';
import '../Widgets/new_password_widgets.dart';
import 'dart:developer';

class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: NewPasswordPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
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
                'Create New Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Your new password must be different from previous passwords.'),
              SizedBox(height: 40),
              NewPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}
