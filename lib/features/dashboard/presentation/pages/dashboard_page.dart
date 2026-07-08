import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_menus.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

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
    // Ambil daftar menu dari AppMenus (tambah navigasi di sini nanti)
    final menus = AppMenus.getDashboardMenus(
      onPatient: () {}, // TODO: Navigator ke halaman pasien
      onMedicine: () {}, // TODO: Navigator ke halaman obat
      onReport: () {}, // TODO: Navigator ke halaman laporan
      onSettings: () {}, // TODO: Navigator ke halaman pengaturan
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

                      // Tombol Logout
                      IconButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        icon: const Icon(Icons.logout, color: AppColors.white),
                        tooltip: 'Keluar',
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
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Tinggal loop dari AppMenus — tidak ada hardcode di sini
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: menu.color.withOpacity(0.12),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: menu.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(menu.icon, size: 36, color: menu.color),
            ),
            const SizedBox(height: 12),
            Text(
              menu.title,
              style: AppTextStyles.labelBold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}