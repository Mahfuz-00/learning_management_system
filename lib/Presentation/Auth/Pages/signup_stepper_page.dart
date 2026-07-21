import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_event.dart';
import '../Bloc/auth_state.dart';
import '../../Shared Widgets/custom_text_field.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class SignupStepperPage extends StatefulWidget {
  const SignupStepperPage({super.key});

  @override
  State<SignupStepperPage> createState() => _SignupStepperPageState();
}

class _SignupStepperPageState extends State<SignupStepperPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers Step 01
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers Step 02
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  String _gender = 'Male';

  // Controllers Step 03
  final _boardController = TextEditingController();
  final _instituteController = TextEditingController();
  final _sscYearController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController();

  // Controllers Step 04
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _parentMobileController = TextEditingController();
  String _marketingChannel = 'Facebook';
  bool _agreementAccepted = false;
  int _role = 0; // 0: Student, 1: Teacher

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _boardController.dispose();
    _instituteController.dispose();
    _sscYearController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _parentMobileController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      if (_agreementAccepted) {
        final signupData = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _role,
          'personalInfo': {
            'fullName': _fullNameController.text,
            'dateOfBirth': _dobController.text,
            'gender': _gender,
            'mobileNumber': _mobileController.text,
          },
          'academicInfo': {
            'board': _boardController.text,
            'instituteName': _instituteController.text,
            'sscExamYear': _sscYearController.text,
            'thana': _thanaController.text,
            'district': _districtController.text,
          },
          'parentInfo': {
            'fatherName': _fatherNameController.text,
            'motherName': _motherNameController.text,
            'parentMobile': _parentMobileController.text,
          },
          'marketingChannel': _marketingChannel,
        };
        context.read<AuthBloc>().add(SignupRequested(signupData));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the agreement')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup successful! Please login.')),
            );
            context.go('/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: _onStepContinue,
          onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
          steps: [
            _buildStep01(),
            _buildStep02(),
            _buildStep03(),
            _buildStep04(),
          ],
        ),
      ),
    );
  }

  Step _buildStep01() {
    return Step(
      title: const Text('Account'),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          CustomTextField(controller: _emailController, labelText: 'Email', hintText: 'Enter email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextField(controller: _passwordController, labelText: 'Password', hintText: 'Enter password', isPassword: true),
          const SizedBox(height: 16),
          CustomTextField(controller: _confirmPasswordController, labelText: 'Confirm Password', hintText: 'Re-enter password', isPassword: true),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Register as'),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Student')),
              DropdownMenuItem(value: 1, child: Text('Teacher')),
            ],
            onChanged: (val) => setState(() => _role = val!),
          ),
        ],
      ),
    );
  }

  Step _buildStep02() {
    return Step(
      title: const Text('Personal'),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          CustomTextField(controller: _fullNameController, labelText: 'Full Name', hintText: 'Enter your name'),
          const SizedBox(height: 16),
          CustomTextField(controller: _dobController, labelText: 'Date of Birth', hintText: 'YYYY-MM-DD', keyboardType: TextInputType.datetime),
          const SizedBox(height: 16),
          CustomTextField(controller: _mobileController, labelText: 'Mobile Number', hintText: 'Enter mobile', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (val) => setState(() => _gender = val!),
          ),
        ],
      ),
    );
  }

  Step _buildStep03() {
    return Step(
      title: const Text('Academic'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          CustomTextField(controller: _boardController, labelText: 'Board', hintText: 'Education Board'),
          const SizedBox(height: 16),
          CustomTextField(controller: _instituteController, labelText: 'Institute Name', hintText: 'School/College name'),
          const SizedBox(height: 16),
          CustomTextField(controller: _sscYearController, labelText: 'SSC Exam Year', hintText: 'e.g. 2024', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          CustomTextField(controller: _thanaController, labelText: 'Thana/Upazila', hintText: 'Enter Thana'),
          const SizedBox(height: 16),
          CustomTextField(controller: _districtController, labelText: 'District', hintText: 'Enter District'),
        ],
      ),
    );
  }

  Step _buildStep04() {
    return Step(
      title: const Text('Final'),
      isActive: _currentStep >= 3,
      content: Column(
        children: [
          CustomTextField(controller: _fatherNameController, labelText: 'Father/Guardian Name', hintText: 'Enter name'),
          const SizedBox(height: 16),
          CustomTextField(controller: _motherNameController, labelText: 'Mother\'s Name', hintText: 'Enter name'),
          const SizedBox(height: 16),
          CustomTextField(controller: _parentMobileController, labelText: 'Parent\'s Mobile', hintText: 'Enter mobile', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _marketingChannel,
            decoration: const InputDecoration(labelText: 'How did you hear about us?'),
            items: const [
              DropdownMenuItem(value: 'Facebook', child: Text('Facebook')),
              DropdownMenuItem(value: 'YouTube', child: Text('YouTube')),
              DropdownMenuItem(value: 'Friends', child: Text('Friends')),
              DropdownMenuItem(value: 'Ad', child: Text('Advertisement')),
            ],
            onChanged: (val) => setState(() => _marketingChannel = val!),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _agreementAccepted,
            onChanged: (val) => setState(() => _agreementAccepted = val!),
            title: const Text('I agree to the Data Storage and Notification policies.'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
