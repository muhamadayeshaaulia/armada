import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi', style: AppTextStyles.headerTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Seputar aplikasi ARMADA',
                    style: AppTextStyles.headerSubtitle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Konten
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildInfoCard(
                    icon: Icons.info_rounded,
                    color: AppColors.info,
                    title: 'Tentang ARMADA',
                    subtitle: 'Aplikasi manajemen rekam medis dan data administrasi klinik.',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.update_rounded,
                    color: AppColors.success,
                    title: 'Versi Aplikasi',
                    subtitle: 'v1.0.0 — Rilis perdana',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.support_agent_rounded,
                    color: AppColors.warning,
                    title: 'Hubungi Support',
                    subtitle: 'support@armada.app',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelBold),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
