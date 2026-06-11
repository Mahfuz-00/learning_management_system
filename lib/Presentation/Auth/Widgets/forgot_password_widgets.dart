import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Navigation/app_router.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Navigate to OTP Screen
                context.push(AppRouter.otp);
              }
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }
}
