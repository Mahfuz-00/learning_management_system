import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_event.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../../../Core/Navigation/app_router.dart';
import 'dart:developer';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: StudentProfilePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              log('UI: Logout button pressed');
              context.read<AuthBloc>().add(LogoutRequested());
              context.go(AppRouter.login);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.user.name ?? 'Student Name',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(state.user.email, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 32),
                  const ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Profile'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const ListTile(
                    leading: Icon(Icons.history),
                    title: Text('My Learning History'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Payment Methods'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Please login to view profile'));
        },
      ),
    );
  }
}
