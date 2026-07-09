import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'edit_staff_page.dart';
import 'add_staff_page.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  String _selectedRole = 'admin';

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(LoadStaffEvent());
  }

  void _showDeleteDialog(StaffEntity staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Petugas'),
        content: Text(
          'Yakin ingin menghapus ${staff.namaLengkap}? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<StaffBloc>()
                  .add(DeleteStaffEvent(staff.id, staff.role));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(StaffEntity staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<StaffBloc>(),
          child: EditStaffPage(staff: staff),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data Petugas', style: AppTextStyles.headerTitle),
                  const SizedBox(height: 4),
                  Text('Kelola admin & dokter praktik',
                      style: AppTextStyles.headerSubtitle),
                  const SizedBox(height: 20),
                  // Toggle Slider Role
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background slider animasi
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          alignment: _selectedRole == 'dokter'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Lapisan tombol
                        SizedBox.expand(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Tombol Admin
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedRole = 'admin'),
                                  behavior: HitTestBehavior.opaque,
                                  child: TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      begin: _selectedRole == 'admin' ? Colors.white : AppColors.primary,
                                      end: _selectedRole == 'admin' ? AppColors.primary : Colors.white,
                                    ),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, color, _) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.admin_panel_settings_rounded, color: color, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Tombol Dokter
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedRole = 'dokter'),
                                  behavior: HitTestBehavior.opaque,
                                  child: TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      begin: _selectedRole == 'dokter' ? Colors.white : AppColors.primary,
                                      end: _selectedRole == 'dokter' ? AppColors.primary : Colors.white,
                                    ),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, color, _) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.medical_services_rounded, color: color, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Dokter',
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT ─────────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<StaffBloc, StaffState>(
                listener: (context, state) {
                  if (state is StaffActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  } else if (state is StaffError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StaffLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state is StaffError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(state.message,
                              style: AppTextStyles.labelBold,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<StaffBloc>()
                                .add(LoadStaffEvent()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is StaffLoaded) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (child, animation) {
                        final slideAnimation = Tween<Offset>(
                          begin: Offset(_selectedRole == 'admin' ? -0.2 : 0.2, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: _selectedRole == 'admin'
                          ? _buildStaffList(state.admins, 'admin', key: const ValueKey('admin'))
                          : _buildStaffList(state.doctors, 'dokter', key: const ValueKey('dokter')),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<StaffBloc>(),
                child: const AddStaffPage(),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Petugas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStaffList(List<StaffEntity> staffList, String role, {Key? key}) {
    if (staffList.isEmpty) {
      return Center(
        key: key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == 'admin'
                  ? Icons.admin_panel_settings_outlined
                  : Icons.medical_services_outlined,
              size: 72,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data ${role == 'admin' ? 'Admin' : 'Dokter'}',
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: key,
      onRefresh: () async =>
          context.read<StaffBloc>().add(LoadStaffEvent()),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return _buildStaffCard(staff);
        },
      ),
    );
  }

  Widget _buildStaffCard(StaffEntity staff) {
    final isAdmin = staff.role == 'admin';
    final color = isAdmin ? AppColors.menuReport : AppColors.info;
    final initials = staff.namaLengkap.isNotEmpty
        ? staff.namaLengkap
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.namaLengkap,
                      style: AppTextStyles.labelBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAdmin
                              ? 'Admin'
                              : staff.spesialis ?? 'Dokter',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (staff.noTelp != null &&
                          staff.noTelp!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.phone,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          staff.noTelp!,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  if (staff.alamat != null && staff.alamat!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              staff.alamat!,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textHint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Actions
            Column(
              children: [
                InkWell(
                  onTap: () => _navigateToEdit(staff),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showDeleteDialog(staff),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
