import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'notification_settings_page.dart';

class AccountSettingsPage extends StatelessWidget {
  final String uid;
  final String role;
  final Map<String, dynamic> initialData;

  const AccountSettingsPage({
    super.key,
    required this.uid,
    required this.role,
    required this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSettingsSection(
            title: 'Pengaturan Utama',
            items: [
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                title: 'Edit Profil',
                subtitle: 'Ubah nama, nomor telepon, alamat, dan info lainnya',
                onTap: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        uid: uid,
                        role: role,
                        initialData: initialData,
                      ),
                    ),
                  );
                  if (updated == true && context.mounted) {
                    Navigator.pop(context, true); // Pop back to profile to trigger reload
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
                icon: Icons.lock_outline_rounded,
                color: Colors.orange,
                title: 'Perbarui Kata Sandi',
                subtitle: 'Ganti kata sandi lama dengan yang baru demi keamanan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSettingsSection(
            title: 'Fitur Lainnya (Akan Datang)',
            items: [
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                color: Colors.blue,
                title: 'Pengaturan Notifikasi',
                subtitle: 'Atur preferensi pemberitahuan aplikasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                color: Colors.teal,
                title: 'Tema Aplikasi',
                subtitle: 'Pilih tampilan mode gelap atau terang',
                onTap: null, // Placeholder
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                        Text(
                          title,
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEnabled)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textHint,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
