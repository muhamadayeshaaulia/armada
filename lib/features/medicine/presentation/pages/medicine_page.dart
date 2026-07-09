import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_prefs.dart';
import '../../domain/entities/medicine_entity.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<MedicineBloc>().add(LoadMedicinesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(MedicineEntity medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Obat'),
        content: Text('Yakin ingin menghapus ${medicine.namaObat}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MedicineBloc>().add(DeleteMedicineEvent(medicine.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showFormBottomSheet({MedicineEntity? medicine}) {
    final isEdit = medicine != null;
    final nameController = TextEditingController(text: medicine?.namaObat ?? '');
    final categoryController = TextEditingController(text: medicine?.kategori ?? '');
    final unitController = TextEditingController(text: medicine?.satuan ?? '');
    final stockController = TextEditingController(text: medicine?.stok.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Data Obat' : 'Tambah Obat Baru',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: nameController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama obat wajib diisi' : null,
                  decoration: InputDecoration(
                    labelText: 'Nama Obat',
                    prefixIcon: const Icon(Icons.medication_rounded, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Kategori (contoh: Antibiotik, Analgesik)',
                    prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Satuan wajib' : null,
                        decoration: InputDecoration(
                          labelText: 'Satuan (misal: Tablet, Botol)',
                          prefixIcon: const Icon(Icons.ad_units_rounded, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Stok wajib';
                          if (int.tryParse(v) == null) return 'Harus angka';
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Jumlah Stok',
                          prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final newMedicine = MedicineEntity(
                      id: medicine?.id ?? '',
                      namaObat: nameController.text.trim(),
                      kategori: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : null,
                      satuan: unitController.text.trim(),
                      stok: int.parse(stockController.text.trim()),
                    );

                    if (isEdit) {
                      context.read<MedicineBloc>().add(UpdateMedicineEvent(newMedicine));
                    } else {
                      context.read<MedicineBloc>().add(AddMedicineEvent(newMedicine));
                    }

                    // Notifikasi Kategori Umum
                    final notifEnabled = await NotificationPrefs.isUmumNotifEnabled();
                    if (notifEnabled) {
                      await NotificationService().showNotification(
                        id: 50,
                        title: isEdit ? 'Data Obat Diubah' : 'Obat Baru Terdaftar',
                        body: 'Data obat ${nameController.text.trim()} berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}.',
                      );
                    }

                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Obat', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Obat', style: AppTextStyles.headerTitle),
                    const SizedBox(height: 4),
                    Text('Kelola inventaris dan stok apotek', style: AppTextStyles.headerSubtitle),
                  ],
                ),
              ),
            ),
          ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari obat berdasarkan nama atau kategori...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),

            // Medicine List
            Expanded(
              child: BlocBuilder<MedicineBloc, MedicineState>(
                builder: (context, state) {
                  if (state is MedicineLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MedicineError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                        ),
                      ),
                    );
                  }

                  if (state is MedicineLoaded) {
                    final filtered = state.medicines.where((o) {
                      final nameMatch = o.namaObat.toLowerCase().contains(_searchQuery);
                      final catMatch = o.kategori?.toLowerCase().contains(_searchQuery) ?? false;
                      return nameMatch || catMatch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_liquid_rounded, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'Belum ada data obat' : 'Obat tidak ditemukan',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final o = filtered[index];
                        final isLowStock = o.stok <= 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon Obat
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isLowStock ? AppColors.error : AppColors.primary).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded,
                                    color: isLowStock ? AppColors.error : AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Info Obat
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        o.namaObat,
                                        style: AppTextStyles.labelBold.copyWith(
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (o.kategori != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            o.kategori!,
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Text('Stok: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          Text(
                                            '${o.stok} ${o.satuan}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isLowStock ? AppColors.error : AppColors.textPrimary,
                                            ),
                                          ),
                                          if (isLowStock) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                                            const SizedBox(width: 2),
                                            const Text(
                                              'Hampir Habis',
                                              style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                  onPressed: () => _showFormBottomSheet(medicine: o),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  onPressed: () => _showDeleteDialog(o),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showFormBottomSheet(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
