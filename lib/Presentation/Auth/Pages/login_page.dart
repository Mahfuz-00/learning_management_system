import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_state.dart';
import '../Widgets/login_widgets.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            log('UI: Authenticated, navigating to home');
            if (state.user.role == 'Teacher') {
              context.go(AppRouter.teacherHome);
            } else {
              context.go(AppRouter.studentHome);
            }
          } else if (state is AuthError) {
            log('UI Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text('Login to continue your learning journey'),
                SizedBox(height: 40),
                LoginForm(),
                SizedBox(height: 20),
                LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => context.push(AppRouter.register),
          child: const Text('Register'),
        ),
      ],
    );
  }
}
