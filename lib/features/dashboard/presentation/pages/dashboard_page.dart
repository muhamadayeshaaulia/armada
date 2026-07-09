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
import '../../../../features/medicine/domain/entities/medicine_entity.dart';
import '../../../../features/medicine/presentation/bloc/medicine_bloc.dart';
import '../../../../features/medicine/presentation/bloc/medicine_event.dart';
import '../../../../features/medicine/presentation/bloc/medicine_state.dart';
import '../../../../features/rekam_medis/presentation/pages/laporan_page.dart';
import '../../../../features/rekam_medis/presentation/pages/resep_obat_page.dart';
import '../../../../features/rekam_medis/domain/entities/rekam_medis_entity.dart';
import '../../../../features/rekam_medis/presentation/bloc/rekam_medis_bloc.dart';
import '../../../../features/rekam_medis/presentation/bloc/rekam_medis_event.dart';
import '../../../../features/rekam_medis/presentation/bloc/rekam_medis_state.dart';
import '../../../../features/profile/presentation/pages/account_settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch events to fetch latest data for medicines and rekam medis
    context.read<MedicineBloc>().add(LoadMedicinesEvent());
    context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
  }

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
        ).then((_) {
          context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
        });
      },
      onMedicine: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicinePage()),
        ).then((_) {
          context.read<MedicineBloc>().add(LoadMedicinesEvent());
        });
      },
      onReport: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPage(title: 'Laporan Rekam Medis')),
        ).then((_) {
          context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
        });
      },
      onRekamMedis: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPage(title: 'Rekam Medis')),
        ).then((_) {
          context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
        });
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
          children: [
            // ── HEADER (Sticky at the top!) ──────────────────────────────────
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String email = 'Memuat...';
                String roleName = 'Memuat...';
                String name = 'Pengguna';

                if (state is AuthAuthenticated) {
                  email = state.user.email;
                  roleName = state.user.role.toUpperCase();
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
                            name.isNotEmpty ? name[0] : 'U',
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
                                  child: Text(roleName, style: AppTextStyles.labelSmall),
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
                    ],
                  ),
                );
              },
            ),

            // ── SCROLLABLE CONTENT ──────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<MedicineBloc>().add(LoadMedicinesEvent());
                  context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100), // Prevent overlap with bottom nav bar
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menu Utama', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        
                        // GridView Menu Utama
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                          children: menus
                              .map((menu) => _buildMenuCard(menu))
                              .toList(),
                        ),
                        
                        const SizedBox(height: 32),

                        // ── SECTION 1: STOK OBAT TERSEDIA ────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Stok Obat Tersedia', style: AppTextStyles.heading3),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MedicinePage()),
                                ).then((_) {
                                  context.read<MedicineBloc>().add(LoadMedicinesEvent());
                                });
                              },
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        BlocBuilder<MedicineBloc, MedicineState>(
                          builder: (context, state) {
                            if (state is MedicineLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (state is MedicineLoaded) {
                              final medicines = state.medicines;
                              if (medicines.isEmpty) {
                                return _buildEmptyCard('Belum ada data obat.');
                              }
                              return SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: medicines.length,
                                  itemBuilder: (context, index) {
                                    final medicine = medicines[index];
                                    return _buildMedicineStockCard(medicine);
                                  },
                                ),
                              );
                            }
                            return _buildEmptyCard('Gagal memuat data obat.');
                          },
                        ),

                        const SizedBox(height: 32),

                        // ── SECTION 2: PASIEN REKAM MEDIS ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pasien Sudah Rekam Medis', style: AppTextStyles.heading3),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LaporanPage(title: 'Rekam Medis')),
                                ).then((_) {
                                  context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
                                });
                              },
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        BlocBuilder<RekamMedisBloc, RekamMedisState>(
                          builder: (context, state) {
                            if (state is RekamMedisLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (state is RekamMedisLoaded) {
                              final records = state.records;
                              if (records.isEmpty) {
                                return _buildEmptyCard('Belum ada pasien rekam medis.');
                              }
                              
                              // Ambil 5 rekam medis terbaru
                              final recentRecords = records.take(5).toList();

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentRecords.length,
                                itemBuilder: (context, index) {
                                  final record = recentRecords[index];
                                  return _buildRecentPatientCard(record);
                                },
                              );
                            }
                            return _buildEmptyCard('Gagal memuat data rekam medis.');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Horizontal Medicine Card
  Widget _buildMedicineStockCard(MedicineEntity medicine) {
    Color statusColor = Colors.green;
    String statusText = 'Tersedia';

    if (medicine.stok == 0) {
      statusColor = Colors.red;
      statusText = 'Habis';
    } else if (medicine.stok <= 10) {
      statusColor = Colors.orange;
      statusText = 'Menipis';
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            medicine.namaObat,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${medicine.stok} ${medicine.satuan}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Recent Patient Record Card
  Widget _buildRecentPatientCard(RekamMedisEntity record) {
    final dateStr = record.createdAt != null
        ? '${record.createdAt!.day}/${record.createdAt!.month}/${record.createdAt!.year}'
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.namaPasien ?? 'Nama Pasien',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Diagnosis: ${record.diagnosis}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Oleh: ${record.namaDokter ?? "Dokter"}',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateStr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget empty state card
  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Widget kartu menu
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