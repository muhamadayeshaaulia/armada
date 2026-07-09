import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Simpan state secara statis/in-memory agar persisten selama aplikasi berjalan
  static bool _allNotifications = true;
  static bool _patientUpdates = true;
  static bool _medicineReminders = true;
  static bool _systemAlerts = false;
  static bool _soundEnabled = true;
  static bool _vibrateEnabled = true;

  void _toggleAll(bool value) {
    setState(() {
      _allNotifications = value;
      if (!value) {
        _patientUpdates = false;
        _medicineReminders = false;
        _systemAlerts = false;
        _soundEnabled = false;
        _vibrateEnabled = false;
      } else {
        _patientUpdates = true;
        _medicineReminders = true;
        _soundEnabled = true;
        _vibrateEnabled = true;
      }
    });
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Utama
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: SwitchListTile(
              activeColor: AppColors.primary,
              value: _allNotifications,
              onChanged: _toggleAll,
              title: const Text('Izinkan Semua Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              subtitle: const Text('Aktifkan atau matikan seluruh pemberitahuan', style: TextStyle(fontSize: 12)),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Kategori Pemberitahuan'),
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
                  title: 'Pembaruan Data Pasien',
                  subtitle: 'Notifikasi saat ada pasien baru terdaftar atau diubah',
                  value: _patientUpdates,
                  onChanged: _allNotifications
                      ? (val) => setState(() => _patientUpdates = val)
                      : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  title: 'Peringatan Stok Obat',
                  subtitle: 'Notifikasi jika ada stok obat yang hampir habis',
                  value: _medicineReminders,
                  onChanged: _allNotifications
                      ? (val) => setState(() => _medicineReminders = val)
                      : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  title: 'Informasi & Info Kesehatan',
                  subtitle: 'Tips kesehatan atau pembaruan sistem berkala',
                  value: _systemAlerts,
                  onChanged: _allNotifications
                      ? (val) => setState(() => _systemAlerts = val)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Metode Pemberitahuan'),
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
                  title: 'Suara Notifikasi',
                  subtitle: 'Mainkan suara saat notifikasi masuk',
                  value: _soundEnabled,
                  onChanged: _allNotifications
                      ? (val) => setState(() => _soundEnabled = val)
                      : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  title: 'Getaran',
                  subtitle: 'Getarkan perangkat saat notifikasi masuk',
                  value: _vibrateEnabled,
                  onChanged: _allNotifications
                      ? (val) => setState(() => _vibrateEnabled = val)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Preferensi notifikasi disimpan!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
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
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}
