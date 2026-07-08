import 'package:flutter/material.dart';

/// Model data untuk satu item di Bottom Navigation Bar.
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}
