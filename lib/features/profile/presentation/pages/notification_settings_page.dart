import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/notification_prefs.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notifLogin = true;
  bool _notifRegister = true;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final login = await NotificationPrefs.isLoginNotifEnabled();
    final register = await NotificationPrefs.isRegisterNotifEnabled();
    if (mounted) {
      setState(() {
        _notifLogin = login;
        _notifRegister = register;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndPop() async {
    await NotificationPrefs.setLoginNotif(_notifLogin);
    await NotificationPrefs.setRegisterNotif(_notifRegister);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preferensi notifikasi disimpan!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildSectionTitle('Notifikasi Aktif'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.login_rounded,
                        iconColor: AppColors.primary,
                        title: 'Notifikasi Login',
                        subtitle: 'Tampilkan pemberitahuan saat Anda berhasil masuk',
                        value: _notifLogin,
                        onChanged: (val) => setState(() {
                          _notifLogin = val;
                          _hasChanges = true;
                        }),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildSwitchTile(
                        icon: Icons.person_add_rounded,
                        iconColor: Colors.teal,
                        title: 'Notifikasi Registrasi',
                        subtitle: 'Tampilkan pemberitahuan saat akun baru dibuat',
                        value: _notifRegister,
                        onChanged: (val) => setState(() {
                          _notifRegister = val;
                          _hasChanges = true;
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifikasi lainnya akan tersedia seiring berkembangnya fitur aplikasi.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _saveAndPop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      activeColor: AppColors.primary,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}
