import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_prefs.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/presentation/bloc/medicine_bloc.dart';
import '../../../medicine/presentation/bloc/medicine_event.dart';
import '../../../medicine/presentation/bloc/medicine_state.dart';
import '../../domain/entities/rekam_medis_entity.dart';
import '../bloc/rekam_medis_bloc.dart';
import '../bloc/rekam_medis_event.dart';
import '../../../patient/domain/entities/patient_entity.dart';

class AddRekamMedisPage extends StatefulWidget {
  final PatientEntity patient;

  const AddRekamMedisPage({super.key, required this.patient});

  @override
  State<AddRekamMedisPage> createState() => _AddRekamMedisPageState();
}

class _AddRekamMedisPageState extends State<AddRekamMedisPage> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanController = TextEditingController();
  final _pemeriksaanController = TextEditingController();
  final _diagnosisController = TextEditingController();
  
  final List<ResepObatEntity> _prescriptions = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _keluhanController.dispose();
    _pemeriksaanController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  void _addPrescription(MedicineEntity obat, String aturan, int jumlah) {
    setState(() {
      _prescriptions.add(
        ResepObatEntity(
          id: '',
          rekamMedisId: '',
          obatId: obat.id,
          aturanMinum: aturan,
          jumlahDiberikan: jumlah,
          obat: obat,
        ),
      );
    });
  }

  void _removePrescription(int index) {
    setState(() {
      _prescriptions.removeAt(index);
    });
  }

  void _showAddObatBottomSheet() {
    final medState = context.read<MedicineBloc>().state;
    if (medState is! MedicineLoaded) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Memuat Obat'),
          content: const Text('Data obat sedang dimuat atau belum tersedia.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final obatList = medState.medicines;
    if (obatList.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Stok Obat Kosong'),
          content: const Text('Belum ada data obat di database. Silakan tambahkan obat terlebih dahulu.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    MedicineEntity? selectedObat = obatList.first;
    final aturanController = TextEditingController(text: '3 x 1 Sehari');
    final jumlahController = TextEditingController(text: '10');

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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resepkan Obat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  // Dropdown obat
                  const Text('Pilih Obat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MedicineEntity>(
                        value: selectedObat,
                        isExpanded: true,
                        items: obatList.map((o) {
                          return DropdownMenuItem(
                            value: o,
                            child: Text('${o.namaObat} (Stok: ${o.stok} ${o.satuan})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => selectedObat = v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aturan Minum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: aturanController,
                              decoration: InputDecoration(
                                hintText: 'Misal: 3 x 1 sehari',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jumlah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: jumlahController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      final qty = int.tryParse(jumlahController.text) ?? 0;
                      if (selectedObat != null && qty > 0) {
                        if (qty > selectedObat!.stok) {
                          showDialog(
                            context: ctx,
                            builder: (c) => AlertDialog(
                              title: const Text('Stok Kurang'),
                              content: Text('Stok ${selectedObat!.namaObat} hanya tersisa ${selectedObat!.stok}.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
                              ],
                            ),
                          );
                          return;
                        }
                        _addPrescription(selectedObat!, aturanController.text.trim(), qty);
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tambahkan Resep', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    final authState = context.read<AuthBloc>().state;
    String? currentDokterId;
    if (authState is AuthAuthenticated) {
      // Jika login sebagai dokter, set dokter_id. Jika admin, set null atau user id.
      if (authState.user.role == 'dokter') {
        currentDokterId = authState.user.uid;
      }
    }

    final record = RekamMedisEntity(
      id: '',
      pasienId: widget.patient.id,
      dokterId: currentDokterId,
      keluhan: _keluhanController.text.trim(),
      hasilPemeriksaan: _pemeriksaanController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
    );

    context.read<RekamMedisBloc>().add(AddRekamMedisEvent(record, _prescriptions));

    // Pemicu update data obat untuk sinkronisasi stok lokal
    context.read<MedicineBloc>().add(LoadMedicinesEvent());

    // Notifikasi Keamanan/Umum
    final notifEnabled = await NotificationPrefs.isUmumNotifEnabled();
    if (notifEnabled) {
      await NotificationService().showNotification(
        id: 40,
        title: 'Rekam Medis Disimpan',
        body: 'Rekam medis ${widget.patient.namaLengkap} berhasil disimpan.',
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context); // Kembali ke Detail Pasien
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Tambah Rekam Medis', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Pasien Singkat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pasien Pemeriksaan', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      widget.patient.namaLengkap,
                      style: AppTextStyles.labelBold.copyWith(fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Pemeriksaan Medis', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _keluhanController,
                label: 'Keluhan Utama',
                icon: Icons.chat_bubble_outline_rounded,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Keluhan wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _pemeriksaanController,
                label: 'Hasil Pemeriksaan Fisik & Penunjang',
                icon: Icons.assignment_outlined,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Hasil pemeriksaan wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _diagnosisController,
                label: 'Diagnosis Akhir',
                icon: Icons.label_important_outline_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Diagnosis wajib diisi' : null,
              ),

              const SizedBox(height: 24),
              
              // Resep Obat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Resep Obat', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: _showAddObatBottomSheet,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Obat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_prescriptions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada resep obat (Pemeriksaan non-medikasi)',
                      style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final p = _prescriptions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.obat?.namaObat ?? 'Nama Obat',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Dosis: ${p.aturanMinum}',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${p.jumlahDiberikan} ${p.obat?.satuan ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                            onPressed: () => _removePrescription(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 36),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Rekam Medis',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
