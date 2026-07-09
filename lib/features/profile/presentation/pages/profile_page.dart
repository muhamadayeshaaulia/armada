import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import 'account_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: BlocBuilder<AuthBloc, AuthState>(
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            // Decorative Bubble 1 (Background decoration)
                            Positioned(
                              right: -40,
                              top: -40,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            // Decorative Bubble 2
                            Positioned(
                              left: -20,
                              bottom: -30,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            // Settings Button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                                onPressed: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AccountSettingsPage(
                                        uid: uid,
                                        role: role,
                                        initialData: data ?? {},
                                      ),
                                    ),
                                  );
                                  if (updated == true) {
                                    setState(() {}); // Pemicu reload data profil
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: Center(
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
                            ),
                          ],
                        ),
                      ),
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

                         if (data?['alamat'] != null) ...[
                          _buildProfileTile(
                            icon: Icons.home_rounded,
                            color: AppColors.primaryLight,
                            label: 'Alamat',
                            value: data!['alamat'],
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

                        if (data?['created_at'] != null) ...[
                          _buildProfileTile(
                            icon: Icons.calendar_today_rounded,
                            color: Colors.teal,
                            label: 'Bergabung Sejak',
                            value: _formatDate(data!['created_at']),
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
