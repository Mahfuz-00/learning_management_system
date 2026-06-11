import 'package:flutter/material.dart';
import '../Widgets/otp_widgets.dart';
import 'dart:developer';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: OtpPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
                'Verify Email',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('We have sent a 4-digit code to your email. Please enter it below.'),
              SizedBox(height: 40),
              OtpForm(),
            ],
          ),
        ),
      ),
    );
  }
}
