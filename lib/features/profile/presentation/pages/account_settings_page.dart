import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_prefs.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'notification_settings_page.dart';

class AccountSettingsPage extends StatefulWidget {
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
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _profileData = Map<String, dynamic>.from(widget.initialData);
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final enabled = await NotificationPrefs.isBiometricEnabled();
    if (_profileData.isEmpty) {
      final table = widget.role == 'admin' ? 'admins' : 'dokters';
      try {
        final response = await Supabase.instance.client
            .from(table)
            .select()
            .eq('id', widget.uid)
            .maybeSingle();
        if (response != null) {
          _profileData = response;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

        if (!canAuthenticate) {
          _showErrorDialog('Perangkat Anda tidak mendukung autentikasi biometrik.');
          return;
        }

        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Pindai sidik jari atau wajah Anda untuk mengaktifkan biometrik',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          await NotificationPrefs.setBiometricEnabled(true);
          setState(() => _biometricEnabled = true);

          final enabled = await NotificationPrefs.isKeamananNotifEnabled();
          if (enabled) {
            await NotificationService().showNotification(
              id: 21,
              title: 'Biometrik Diaktifkan',
              body: 'Autentikasi biometrik berhasil diaktifkan untuk akun Anda.',
            );
          }
        }
      } catch (e) {
        _showErrorDialog('Gagal mengaktifkan biometrik: ${e.toString()}');
      }
    } else {
      await NotificationPrefs.setBiometricEnabled(false);
      setState(() => _biometricEnabled = false);

      final enabled = await NotificationPrefs.isKeamananNotifEnabled();
      if (enabled) {
        await NotificationService().showNotification(
          id: 22,
          title: 'Biometrik Dinonaktifkan',
          body: 'Autentikasi biometrik telah dinonaktifkan.',
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Biometrik tidak tersedia'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
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
        title: const Text('Pengaturan Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                              uid: widget.uid,
                              role: widget.role,
                              initialData: _profileData,
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
                    const SizedBox(height: 16),
                    _buildSettingsSwitchTile(
                      icon: Icons.fingerprint_rounded,
                      color: Colors.teal,
                      title: 'Autentikasi Biometrik',
                      subtitle: 'Gunakan sidik jari/wajah saat membuka aplikasi',
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
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

  Widget _buildSettingsSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
