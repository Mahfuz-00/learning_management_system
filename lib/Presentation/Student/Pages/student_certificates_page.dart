import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../../../Domain/Entities/certificate_entity.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class StudentCertificatesPage extends StatelessWidget {
  const StudentCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: StudentCertificatesPage build');
    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Placeholder for certificates list - in real app would be fetched via a BLoC
          final List<CertificateEntity> certificates = []; 

          if (certificates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No certificates earned yet.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('Complete courses to unlock your achievements!'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go('/student/browse'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    child: const Text('EXPLORE COURSES'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: certificates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cert = certificates[index];
              return _buildCertificateCard(context, cert);
            },
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateEntity cert) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.secondaryGreen, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.secondaryGreen, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.courseTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Issued on ${DateFormat('MMM dd, yyyy').format(cert.issuedAt)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      log('UI: Viewing certificate for ${cert.courseId}');
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('VIEW'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      log('UI: Downloading certificate for ${cert.courseId}');
                    },
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('DOWNLOAD'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
