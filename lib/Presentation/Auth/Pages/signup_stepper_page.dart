import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_event.dart';
import '../Bloc/auth_state.dart';
import '../../Shared Widgets/custom_text_field.dart';

class SignupStepperPage extends StatefulWidget {
  const SignupStepperPage({super.key});

  @override
  State<SignupStepperPage> createState() => _SignupStepperPageState();
}

class _SignupStepperPageState extends State<SignupStepperPage> {
  int _currentStep = 0;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Global Keys for Isolated Step Validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Controllers Step 01: Personal Info
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  String _gender = 'Male';

  // Controllers Step 02: Academic Info
  final _boardController = TextEditingController();
  final _instituteController = TextEditingController();
  final _sscYearController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController();

  // Controllers Step 03: Account & Final
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _parentMobileController = TextEditingController();
  String _marketingChannel = 'Facebook';
  bool _agreementAccepted = false;
  int _role = 0; // 0: Student, 1: Teacher

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _boardController.dispose();
    _instituteController.dispose();
    _sscYearController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parentMobileController.dispose();
    super.dispose();
  }

  // --- Pickers ---

  Future<void> _selectDatePicker(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final formattedMonth = pickedDate.month.toString().padLeft(2, '0');
      final formattedDay = pickedDate.day.toString().padLeft(2, '0');

      setState(() {
        controller.text = '${pickedDate.year}-$formattedMonth-$formattedDay';
      });
    }
  }

  Future<void> _selectYearPicker(TextEditingController controller) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select SSC Exam Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1980),
              lastDate: DateTime.now(),
              selectedDate: DateTime.now(),
              onChanged: (DateTime dateTime) {
                setState(() {
                  controller.text = dateTime.year.toString();
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  // --- Strict Validators ---

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String?_validateMobile(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Mobile number is required';
    }
    if (text.length != 11) {
      return 'Mobile number must be exactly 11 digits';
    }
    if (!text.startsWith('01')) {
      return 'Mobile number must start with 01';
    }
    final mobileRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!mobileRegex.hasMatch(text)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  // --- Step Continuation Logic ---

  void _onStepContinue() {
    bool isValid = false;

    if (_currentStep == 0) {
      isValid = _step1FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isValid = _step2FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isValid = _step3FormKey.currentState?.validate() ?? false;
    }

    if (!isValid) {
      // Enable validation error messages only after clicking continue
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _autovalidateMode = AutovalidateMode.disabled;
        _currentStep++;
      });
    } else {
      if (_agreementAccepted) {
        final signupData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': _role,
          'personalInfo': {
            'fullName': _fullNameController.text.trim(),
            'dateOfBirth': _dobController.text,
            'gender': _gender,
            'mobileNumber': _mobileController.text.trim(),
            'fatherName': _fatherNameController.text.trim(),
            'motherName': _motherNameController.text.trim(),
          },
          'academicInfo': {
            'board': _boardController.text.trim(),
            'instituteName': _instituteController.text.trim(),
            'sscExamYear': _sscYearController.text,
            'thana': _thanaController.text.trim(),
            'district': _districtController.text.trim(),
          },
          'parentInfo': {
            'parentMobile': _parentMobileController.text.trim(),
          },
          'marketingChannel': _marketingChannel,
        };
        context.read<AuthBloc>().add(SignupRequested(signupData));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the agreement to continue')),
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
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) {
            if (step < _currentStep) {
              setState(() {
                _autovalidateMode = AutovalidateMode.disabled;
                _currentStep = step;
              });
            } else {
              _onStepContinue();
            }
          },
          onStepContinue: _onStepContinue,
          onStepCancel: _currentStep > 0
              ? () {
            setState(() {
              _autovalidateMode = AutovalidateMode.disabled;
              _currentStep--;
            });
          }
              : null,
          steps: [
            _buildStep01Personal(),
            _buildStep02Academic(),
            _buildStep03AccountAndFinal(),
          ],
        ),
      ),
    );
  }

  Step _buildStep01Personal() {
    return Step(
      title: const Text('Personal Details'),
      isActive: _currentStep >= 0,
      content: Form(
        key: _step1FormKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          children: [
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Full Name',
              hintText: 'Enter your name',
              validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDatePicker(_dobController),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _dobController,
                  labelText: 'Date of Birth',
                  hintText: 'Select Date of Birth',
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Date of Birth is required'
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _mobileController,
              labelText: 'Mobile Number',
              hintText: '01XXXXXXXXX',
              keyboardType: TextInputType.phone,
              validator: _validateMobile,
            ),
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
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fatherNameController,
              labelText: 'Father/Guardian Name',
              hintText: 'Enter father\'s name',
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Father\'s name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _motherNameController,
              labelText: 'Mother\'s Name',
              hintText: 'Enter mother\'s name',
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Mother\'s name is required'
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep02Academic() {
    return Step(
      title: const Text('Academic Details'),
      isActive: _currentStep >= 1,
      content: Form(
        key: _step2FormKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          children: [
            CustomTextField(
              controller: _boardController,
              labelText: 'Board',
              hintText: 'Education Board',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _instituteController,
              labelText: 'Institute Name',
              hintText: 'School/College name',
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectYearPicker(_sscYearController),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _sscYearController,
                  labelText: 'SSC Exam Year',
                  hintText: 'Select Year',
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _thanaController,
              labelText: 'Thana/Upazila',
              hintText: 'Enter Thana',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _districtController,
              labelText: 'District',
              hintText: 'Enter District',
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep03AccountAndFinal() {
    return Step(
      title: const Text('Account & Confirmation'),
      isActive: _currentStep >= 2,
      content: Form(
        key: _step3FormKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter email',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter password',
              isPassword: true,
              validator: (val) =>
              (val == null || val.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Re-enter password',
              isPassword: true,
              validator: (val) => val != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
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
            const SizedBox(height: 16),
            CustomTextField(
              controller: _parentMobileController,
              labelText: 'Parent\'s Mobile (Optional)',
              hintText: '01XXXXXXXXX',
              keyboardType: TextInputType.phone,
              validator: _validateMobile,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _marketingChannel,
              decoration: const InputDecoration(
                labelText: 'How did you hear about us?',
              ),
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
              title: const Text(
                'I agree to the Data Storage and Notification policies.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}