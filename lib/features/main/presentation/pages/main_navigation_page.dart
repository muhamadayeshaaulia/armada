import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_navigation.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../../features/info/presentation/pages/info_page.dart';
import '../../../../features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // ─── KONFIGURASI NAVIGASI ───────────────────────────────────────────────
  // Tambah tab baru? Cukup tambah NavItemData di sini.
  late final List<NavItemData> _navItems = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      page: const DashboardPage(),
    ),
    NavItemData(
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
      label: 'Info',
      page: const InfoPage(),
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
      page: const ProfilePage(),
    ),
  ];
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Logout ditangani di sini (shell) — tidak lagi di DashboardPage
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        // IndexedStack agar state setiap halaman tetap terjaga saat pindah tab
        body: IndexedStack(
          index: _currentIndex,
          children: _navItems.map((item) => item.page).toList(),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // ── Styling ──
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,

          // ── Items (dibangun otomatis dari _navItems) ──
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(item.icon),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(item.activeIcon),
                  ),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
