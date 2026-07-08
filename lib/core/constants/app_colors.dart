import 'package:flutter/material.dart';

/// Semua warna utama aplikasi ARMADA.
/// Gunakan kelas ini agar warna konsisten di seluruh aplikasi.
class AppColors {
  AppColors._(); // Prevent instantiation

  // === WARNA UTAMA (Primary) ===
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryLight = Color(0xFF1A6BB5);
  static const Color primaryDark = Color(0xFF0A3560);

  // === GRADIENT PRIMARY ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // === WARNA AKSEN PER MENU ===
  static const Color menuPatient = Color(0xFF2196F3);  // Biru - Pasien
  static const Color menuMedicine = Color(0xFF4CAF50); // Hijau - Obat
  static const Color menuReport = Color(0xFFFF9800);   // Orange - Laporan
  static const Color menuSettings = Color(0xFF9E9E9E); // Abu - Pengaturan

  // === WARNA STATUS ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // === WARNA NETRAL ===
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color backgroundPage = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // === WARNA OVERLAY ===
  static const Color overlayLight = Color(0x33FFFFFF); // putih 20% opacity
}
