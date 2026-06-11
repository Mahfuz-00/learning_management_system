import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Navigation/app_router.dart';

class NewPasswordForm extends StatefulWidget {
  const NewPasswordForm({super.key});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _passwordController,
            labelText: 'New Password',
            hintText: 'Enter new password',
            isPassword: true,
            validator: (value) => value!.length < 6 ? 'Password too short' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter new password',
            isPassword: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.go(AppRouter.authSuccess, extra: 'Password reset successful!');
              }
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }
}
