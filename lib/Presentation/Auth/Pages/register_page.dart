import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_state.dart';
import '../Widgets/register_widgets.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            log('UI: Registration success, navigating');
            context.go(state.user.role == 'Teacher' ? AppRouter.teacherHome : AppRouter.studentHome);
          } else if (state is AuthError) {
            log('UI Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Us',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text('Start your learning or teaching journey today'),
                SizedBox(height: 30),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
