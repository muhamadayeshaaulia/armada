import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_menus.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/staff/presentation/pages/staff_page.dart';
import '../../../../features/patient/presentation/pages/patient_page.dart';
import '../../../../features/medicine/presentation/pages/medicine_page.dart';
import '../../../../features/rekam_medis/presentation/pages/laporan_page.dart';
import '../../../../features/rekam_medis/presentation/pages/resep_obat_page.dart';
import '../../../../features/profile/presentation/pages/account_settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) return 'Selamat Pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat Siang,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

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
    final authState = context.read<AuthBloc>().state;
    String uid = '';
    String role = '';
    if (authState is AuthAuthenticated) {
      uid = authState.user.uid;
      role = authState.user.role;
    }

    final menus = AppMenus.getDashboardMenus(
      onPatient: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientPage()),
        );
      },
      onMedicine: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicinePage()),
        );
      },
      onReport: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPage(title: 'Laporan Rekam Medis')),
        );
      },
      onRekamMedis: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPage(title: 'Rekam Medis')),
        );
      },
      onResepObat: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResepObatPage()),
        );
      },
      onStaff: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StaffPage()),
        );
      },
    );

    return Scaffold(
        backgroundColor: AppColors.backgroundPage,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────────────────
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String email = 'Memuat...';
                  String role = 'Memuat...';
                  String name = 'Pengguna';

                  if (state is AuthAuthenticated) {
                    email = state.user.email;
                    role = state.user.role.toUpperCase();
                    name = _extractNameFromEmail(email);
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20,
                    ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            name[0],
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info User
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getGreeting(), style: AppTextStyles.headerSubtitle),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: AppTextStyles.headerTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Badge Role
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.overlayLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(role, style: AppTextStyles.labelSmall),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: AppTextStyles.headerSubtitle.copyWith(
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tombol Notifikasi
                      IconButton(
                        onPressed: () {
                          // TODO: Navigasi ke halaman notifikasi
                        },
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.white),
                        tooltip: 'Notifikasi',
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── MENU UTAMA ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menu Utama', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                        children: menus
                            .map((menu) => _buildMenuCard(menu))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kartu menu — menerima MenuItemData, bukan parameter satu-satu
  Widget _buildMenuCard(MenuItemData menu) {
    return InkWell(
      onTap: menu.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: menu.color.withOpacity(0.06),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: menu.color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(menu.icon, size: 24, color: menu.color),
            ),
            const SizedBox(height: 8),
            Text(
              menu.title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}