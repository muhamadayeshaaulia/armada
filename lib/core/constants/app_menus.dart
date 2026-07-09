import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Model data untuk setiap item menu di Dashboard.
class MenuItemData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const MenuItemData({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });
}

/// Daftar menu utama Dashboard ARMADA.
/// Tambah / edit menu di sini, tidak perlu ubah UI sama sekali.
class AppMenus {
  AppMenus._(); // Prevent instantiation

  static List<MenuItemData> getDashboardMenus({
    VoidCallback? onPatient,
    VoidCallback? onMedicine,
    VoidCallback? onReport,
    VoidCallback? onRekamMedis,
    VoidCallback? onResepObat,
    VoidCallback? onStaff,
  }) {
    return [
      MenuItemData(
        icon: Icons.people_alt_rounded,
        title: 'Data Pasien',
        color: AppColors.menuPatient,
        onTap: onPatient,
      ),
      MenuItemData(
        icon: Icons.medication_rounded,
        title: 'Data Obat',
        color: AppColors.menuMedicine,
        onTap: onMedicine,
      ),
      MenuItemData(
        icon: Icons.analytics_rounded,
        title: 'Laporan',
        color: AppColors.menuReport,
        onTap: onReport,
      ),
      MenuItemData(
        icon: Icons.assignment_outlined,
        title: 'Rekam Medis',
        color: Colors.teal,
        onTap: onRekamMedis,
      ),
      MenuItemData(
        icon: Icons.receipt_long_rounded,
        title: 'Resep Obat',
        color: Colors.amber,
        onTap: onResepObat,
      ),
      MenuItemData(
        icon: Icons.badge_rounded,
        title: 'Data Petugas',
        color: const Color(0xFF9C27B0),
        onTap: onStaff,
      ),
    ];
  }
}
