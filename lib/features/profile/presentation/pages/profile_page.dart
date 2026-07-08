import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      final name = parts[0];
      return name[0].toUpperCase() + name.substring(1);
    }
    return 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String email = '-';
            String role = '-';
            String name = 'Pengguna';

            if (state is AuthAuthenticated) {
              email = state.user.email;
              role = state.user.role;
              name = _extractNameFromEmail(email);
            }

            return Column(
              children: [
                // Header Profil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            name[0],
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 36,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: AppTextStyles.headerTitle),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: AppTextStyles.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Detail Profil
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildProfileTile(
                        icon: Icons.email_rounded,
                        color: AppColors.info,
                        label: 'Email',
                        value: email,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileTile(
                        icon: Icons.badge_rounded,
                        color: AppColors.primaryLight,
                        label: 'Role',
                        value: role[0].toUpperCase() + role.substring(1),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Logout
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
