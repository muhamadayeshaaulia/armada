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
  bool _notifUmum = true;
  bool _notifAutentikasi = true;
  bool _notifKeamanan = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final umum = await NotificationPrefs.isUmumNotifEnabled();
    final autentikasi = await NotificationPrefs.isAutentikasiNotifEnabled();
    final keamanan = await NotificationPrefs.isKeamananNotifEnabled();

    if (mounted) {
      setState(() {
        _notifUmum = umum;
        _notifAutentikasi = autentikasi;
        _notifKeamanan = keamanan;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndPop() async {
    await NotificationPrefs.setUmumNotif(_notifUmum);
    await NotificationPrefs.setAutentikasiNotif(_notifAutentikasi);
    await NotificationPrefs.setKeamananNotif(_notifKeamanan);
    if (!mounted) return;
    Navigator.pop(context);
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
                _buildSectionTitle('Kategori Notifikasi'),
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
                        icon: Icons.notifications_active_rounded,
                        iconColor: Colors.blue,
                        title: 'Notifikasi Umum',
                        subtitle: 'Pemberitahuan tambah/edit petugas & edit profil',
                        value: _notifUmum,
                        onChanged: (v) => setState(() => _notifUmum = v),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildSwitchTile(
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.primary,
                        title: 'Notifikasi Autentikasi',
                        subtitle: 'Pemberitahuan login & registrasi akun',
                        value: _notifAutentikasi,
                        onChanged: (v) => setState(() => _notifAutentikasi = v),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildSwitchTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: Colors.orange,
                        title: 'Notifikasi Keamanan',
                        subtitle: 'Pemberitahuan perubahan kata sandi',
                        value: _notifKeamanan,
                        onChanged: (v) => setState(() => _notifKeamanan = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}
