import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>?> _fetchUserDetails(String uid, String role) async {
    final table = role == 'admin' ? 'admins' : 'dokters';
    try {
      final response = await Supabase.instance.client
          .from(table)
          .select()
          .eq('id', uid)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String uid = '';
            String email = '-';
            String role = '-';
            String name = 'Pengguna';

            if (state is AuthAuthenticated) {
              uid = state.user.uid;
              email = state.user.email;
              role = state.user.role;
            }

            if (uid.isEmpty) return const SizedBox.shrink();

            return FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserDetails(uid, role),
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data != null && data['nama_lengkap'] != null) {
                  name = data['nama_lengkap'];
                } else if (email.isNotEmpty && email != '-') {
                  final parts = email.split('@');
                  name = parts[0][0].toUpperCase() + parts[0].substring(1);
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
                                name[0].toUpperCase(),
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
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 100, // Memberikan ruang agar tombol logout tidak tertutup bottom nav
                        ),
                        children: [
                          _buildSectionTitle('Informasi Akun'),
                          const SizedBox(height: 12),
                          _buildProfileTile(
                            icon: Icons.email_rounded,
                            color: AppColors.info,
                            label: 'Email',
                            value: email,
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('Identitas Personal'),
                          const SizedBox(height: 12),

                          if (role == 'dokter' && data?['spesialis'] != null) ...[
                            _buildProfileTile(
                              icon: Icons.medical_services_rounded,
                              color: AppColors.success,
                              label: 'Spesialis',
                              value: data!['spesialis'],
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (data?['no_telp'] != null) ...[
                            _buildProfileTile(
                              icon: Icons.phone_rounded,
                              color: Colors.orange,
                              label: 'Nomor Telepon',
                              value: data!['no_telp'],
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (data?['tempat_lahir'] != null || data?['tanggal_lahir'] != null) ...[
                            _buildProfileTile(
                              icon: Icons.cake_rounded,
                              color: Colors.pink,
                              label: 'Tempat & Tanggal Lahir',
                              value: '${data?['tempat_lahir'] ?? '-'}, ${data?['tanggal_lahir'] ?? '-'}',
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (data?['alamat'] != null) ...[
                            _buildProfileTile(
                              icon: Icons.home_rounded,
                              color: AppColors.primaryLight,
                              label: 'Alamat',
                              value: data!['alamat'],
                            ),
                            const SizedBox(height: 12),
                          ],

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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16,
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
