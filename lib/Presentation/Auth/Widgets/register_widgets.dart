import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_event.dart';
import '../Bloc/auth_state.dart';
import '../../Shared Widgets/custom_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            validator: (value) => value!.isEmpty ? 'Enter name' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            isPassword: true,
            validator: (value) => value!.length < 6 ? 'Password too short' : null,
          ),
          const SizedBox(height: 20),
          const Text(
            'Register as',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ['Student', 'Teacher'].map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
          const SizedBox(height: 40),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                          RegisterRequested(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            name: _nameController.text.trim(),
                            role: _selectedRole,
                          ),
                        );
                  }
                },
                child: const Text('Register'),
              );
            },
          ),
        ],
      ),
    );
  }
}
