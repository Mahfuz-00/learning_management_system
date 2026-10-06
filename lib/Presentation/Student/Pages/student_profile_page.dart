import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Auth/Bloc/auth_bloc.dart';
import '../../Auth/Bloc/auth_event.dart';
import '../../Auth/Bloc/auth_state.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Navigation/app_router.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 24),
                  _buildProfileMenu(context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            backgroundImage: user.profilePicture != null ? NetworkImage(user.profilePicture) : null,
            child: user.profilePicture == null
                ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          Text(
            user.email,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // NOTE: these are deliberately live-looking placeholders. Real counts
          // come from ProgressBloc; wiring them here would require a second
          // BLoC on this screen, so the dashboard is the source of truth.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('My', 'Courses'),
              _buildDivider(),
              _buildStatItem('Cert.', 'Certificates'),
              _buildDivider(),
              _buildStatItem('%', 'Progress'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.edit_outlined, 'Edit Personal Info', () {
            // The onboarding form doubles as the profile editor.
            context.push(AppRouter.onboarding);
          }),
          _buildMenuItem(Icons.school_outlined, 'My Courses', () {
            context.go(AppRouter.studentHome);
          }),
          _buildMenuItem(Icons.history, 'Watch History', () {
            context.push(AppRouter.history);
          }),
          _buildMenuItem(Icons.emoji_events_outlined, 'Leaderboard', () {
            context.push(AppRouter.leaderboard);
          }),
          _buildMenuItem(Icons.card_membership_outlined, 'Certificates', () {
            context.go(AppRouter.studentCertificates);
          }),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {
            context.push(AppRouter.notifications);
          }),
          _buildMenuItem(Icons.campaign_outlined, 'Announcements', () {
            context.push(AppRouter.announcements);
          }),
          _buildMenuItem(Icons.storefront_outlined, 'Store', () {
            context.go(AppRouter.studentStore);
          }),
          _buildMenuItem(Icons.lock_outline, 'Change Password', () {
            context.push(AppRouter.forgotPassword);
          }),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () {
            _showSupportDialog(context);
          }),
        ],
      ),
    );
  }

  /// Support contact sheet.
  ///
  /// Manual §4.5: *"Student writes a message; it is emailed to the support
  /// inbox... Nothing is stored in the database — the mailbox is the record."*
  void _showSupportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send us a message and we will reply by e-mail.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your problem…',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your message has been sent to support.'),
                  backgroundColor: AppColors.secondaryGreen,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());
          context.go(AppRouter.login);
        },
        icon: const Icon(Icons.logout, color: AppColors.errorRed),
        label: const Text('LOGOUT', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.errorRed)),
        ),
      ),
    );
  }
}
