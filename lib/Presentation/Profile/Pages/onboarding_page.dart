import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/student_profile_entity.dart';
import '../Bloc/profile_bloc.dart';
import '../Bloc/profile_event.dart';
import '../Bloc/profile_state.dart';

/// The compulsory student profile form.
///
/// **User Manual §4.1:** *"Profile form — Pops up automatically after
/// verification. A short compulsory form (school, batch, guardian details).
/// **Cannot be skipped.**"*
///
/// The form collects exactly the fields the live
/// `CompleteStudentOnboardingDTO` expects, validates the Bangladeshi mobile
/// number, and requires all three consent checkboxes before submitting.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _institutionController = TextEditingController();
  final _boardController = TextEditingController();
  final _sscYearController = TextEditingController();
  final _districtController = TextEditingController();
  final _thanaController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();

  String? _gender;
  bool _agreedInfoCorrect = false;
  bool _agreedDataStorage = false;
  bool _agreedNotifications = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _institutionController.dispose();
    _boardController.dispose();
    _sscYearController.dispose();
    _districtController.dispose();
    _thanaController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final profile = StudentProfileEntity(
      fullName: _fullNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      gender: _gender,
      institution: _institutionController.text.trim(),
      board: _boardController.text.trim(),
      sscExamYear: _sscYearController.text.trim(),
      district: _districtController.text.trim(),
      thana: _thanaController.text.trim(),
      guardianName: _guardianNameController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      parentEmail: _parentEmailController.text.trim(),
      agreedInfoCorrect: _agreedInfoCorrect,
      agreedDataStorage: _agreedDataStorage,
      agreedNotifications: _agreedNotifications,
    );

    context.read<ProfileBloc>().add(CompleteOnboardingRequested(profile));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.actionSucceeded != current.actionSucceeded,
      listener: (context, state) {
        if (state.actionSucceeded && !state.needsOnboarding) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile complete. Welcome to Nirvoor!'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          context.go('/student');
        }
        if (state.status == ProfileStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      child: Builder(
        builder: (context) {
          final saving =
              context.select((ProfileBloc bloc) => bloc.state.status) ==
                  ProfileStatus.saving;

          return Scaffold(
          appBar: AppBar(
            title: const Text('Complete Your Profile'),
            automaticallyImplyLeading: false,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro(),
                  const SizedBox(height: 20),

                  _sectionTitle('Student details'),
                  _field(
                    controller: _fullNameController,
                    label: 'Full name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  _field(
                    controller: _mobileController,
                    label: 'Mobile number',
                    hint: '01XXXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    // Manual §4.1: must be a real Bangladeshi number
                    // (11 digits starting 01, or +880…).
                    validator: (v) => StudentProfileEntity.isValidBdMobile(v)
                        ? null
                        : 'Enter a valid Bangladeshi number (01XXXXXXXXX)',
                  ),
                  _genderField(),
                  _field(
                    controller: _institutionController,
                    label: 'School / College',
                    icon: Icons.school_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Institution is required' : null,
                  ),
                  _field(
                    controller: _boardController,
                    label: 'Education board (optional)',
                    icon: Icons.account_balance_outlined,
                  ),
                  _field(
                    controller: _sscYearController,
                    label: 'SSC exam year (optional)',
                    hint: 'e.g. 2027',
                    icon: Icons.event_outlined,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _districtController,
                          label: 'District (optional)',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _thanaController,
                          label: 'Thana (optional)',
                          icon: Icons.map_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  _sectionTitle('Guardian details'),
                  _field(
                    controller: _guardianNameController,
                    label: 'Guardian name',
                    icon: Icons.family_restroom_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Guardian name is required' : null,
                  ),
                  _field(
                    controller: _guardianPhoneController,
                    label: 'Guardian phone',
                    hint: '01XXXXXXXXX',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => StudentProfileEntity.isValidBdMobile(v)
                        ? null
                        : 'Enter a valid Bangladeshi number',
                  ),
                  _field(
                    controller: _parentEmailController,
                    label: 'Parent e-mail (optional)',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 8),
                  _sectionTitle('Consent'),
                  _consentTile(
                    'The information I have given is correct',
                    _agreedInfoCorrect,
                    (v) => setState(() => _agreedInfoCorrect = v),
                  ),
                  _consentTile(
                    'I agree to Nirvoor storing my data',
                    _agreedDataStorage,
                    (v) => setState(() => _agreedDataStorage = v),
                  ),
                  _consentTile(
                    'I would like to receive notifications',
                    _agreedNotifications,
                    (v) => setState(() => _agreedNotifications = v),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : _submit,
                      child: saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save and Continue'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This step cannot be skipped.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tell us a little about yourself so your teachers and guardians '
              'can be connected to your progress.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _gender,
        decoration: const InputDecoration(
          labelText: 'Gender (optional)',
          prefixIcon: Icon(Icons.wc_outlined),
        ),
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _gender = v),
      ),
    );
  }

  Widget _consentTile(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}