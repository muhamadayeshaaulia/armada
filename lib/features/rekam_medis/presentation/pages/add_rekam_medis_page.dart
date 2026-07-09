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
import '../../../patient/domain/entities/patient_entity.dart';
import '../../../patient/presentation/bloc/patient_bloc.dart';
import '../../../patient/presentation/bloc/patient_event.dart';
import '../../../patient/presentation/bloc/patient_state.dart';
import '../../domain/entities/rekam_medis_entity.dart';
import '../bloc/rekam_medis_bloc.dart';
import '../bloc/rekam_medis_event.dart';

class PrescriptionInput {
  MedicineEntity? selectedObat;
  final TextEditingController aturanController;
  final TextEditingController jumlahController;

  PrescriptionInput({
    this.selectedObat,
    String aturan = '3 x 1 Sehari',
    String jumlah = '10',
  })  : aturanController = TextEditingController(text: aturan),
        jumlahController = TextEditingController(text: jumlah);

  void dispose() {
    aturanController.dispose();
    jumlahController.dispose();
  }
}

class AddRekamMedisPage extends StatefulWidget {
  final PatientEntity? patient;
  final RekamMedisEntity? record;

  const AddRekamMedisPage({super.key, this.patient, this.record});

  @override
  State<AddRekamMedisPage> createState() => _AddRekamMedisPageState();
}

class _AddRekamMedisPageState extends State<AddRekamMedisPage> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanController = TextEditingController();
  final _pemeriksaanController = TextEditingController();
  final _diagnosisController = TextEditingController();
  
  final List<PrescriptionInput> _prescriptionInputs = [];
  PatientEntity? _selectedPatient;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Load patients if we don't have a preselected patient
    if (widget.patient == null) {
      context.read<PatientBloc>().add(LoadPatientsEvent());
    } else {
      _selectedPatient = widget.patient;
    }

    // Prefill data if in Edit Mode
    if (widget.record != null) {
      _keluhanController.text = widget.record!.keluhan;
      _pemeriksaanController.text = widget.record!.hasilPemeriksaan;
      _diagnosisController.text = widget.record!.diagnosis;
      
      // Prefill prescriptions
      if (widget.record!.resepList != null) {
        for (var resep in widget.record!.resepList!) {
          _prescriptionInputs.add(
            PrescriptionInput(
              selectedObat: resep.obat,
              aturan: resep.aturanMinum,
              jumlah: resep.jumlahDiberikan.toString(),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    _pemeriksaanController.dispose();
    _diagnosisController.dispose();
    for (var input in _prescriptionInputs) {
      input.dispose();
    }
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Validasi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedPatient == null) {
      _showErrorDialog('Harap pilih pasien terlebih dahulu.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    // Validasi input resep secara inline
    final List<ResepObatEntity> resepList = [];
    for (var input in _prescriptionInputs) {
      if (input.selectedObat == null) {
        _showErrorDialog('Harap pilih obat pada semua resep yang ditambahkan.');
        setState(() => _isSaving = false);
        return;
      }
      final qty = int.tryParse(input.jumlahController.text.trim()) ?? 0;
      if (qty <= 0) {
        _showErrorDialog('Jumlah obat "${input.selectedObat!.namaObat}" harus lebih besar dari 0.');
        setState(() => _isSaving = false);
        return;
      }
      
      // Khusus mode tambah: cek apakah stok mencukupi
      // Pada mode edit, stok di database akan dikembalikan dulu di datasource, tapi kita lakukan cek stok sederhana
      if (widget.record == null && qty > input.selectedObat!.stok) {
        _showErrorDialog('Stok obat "${input.selectedObat!.namaObat}" tidak mencukupi (Tersisa: ${input.selectedObat!.stok}).');
        setState(() => _isSaving = false);
        return;
      }
      
      resepList.add(
        ResepObatEntity(
          id: '',
          rekamMedisId: widget.record?.id ?? '',
          obatId: input.selectedObat!.id,
          aturanMinum: input.aturanController.text.trim(),
          jumlahDiberikan: qty,
          obat: input.selectedObat,
        ),
      );
    }

    final authState = context.read<AuthBloc>().state;
    String? currentDokterId = widget.record?.dokterId;
    if (widget.record == null && authState is AuthAuthenticated) {
      if (authState.user.role == 'dokter') {
        currentDokterId = authState.user.uid;
      }
    }

    final record = RekamMedisEntity(
      id: widget.record?.id ?? '',
      pasienId: _selectedPatient!.id,
      dokterId: currentDokterId,
      keluhan: _keluhanController.text.trim(),
      hasilPemeriksaan: _pemeriksaanController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      createdAt: widget.record?.createdAt,
    );

    if (widget.record != null) {
      context.read<RekamMedisBloc>().add(UpdateRekamMedisEvent(record, resepList));
    } else {
      context.read<RekamMedisBloc>().add(AddRekamMedisEvent(record, resepList));
    }

    // Sinkronisasi data obat lokal
    context.read<MedicineBloc>().add(LoadMedicinesEvent());

    // Kirim Notifikasi lokal (Kategori Umum)
    final notifEnabled = await NotificationPrefs.isUmumNotifEnabled();
    if (notifEnabled) {
      await NotificationService().showNotification(
        id: 40,
        title: widget.record != null ? 'Rekam Medis Diperbarui' : 'Rekam Medis Disimpan',
        body: 'Rekam medis ${_selectedPatient!.namaLengkap} berhasil ${widget.record != null ? "diperbarui" : "disimpan"}.',
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.record != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(isEditMode ? 'Edit Rekam Medis' : 'Tambah Rekam Medis', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Pilih Pasien
              Text('Pilih Pasien', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              if (widget.patient != null || isEditMode)
                // Jika sudah ada pasien preselected atau sedang mode edit, tampilkan nama pasien terkunci
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPatient?.namaLengkap ?? 'Nama Pasien',
                              style: AppTextStyles.labelBold.copyWith(fontSize: 16, color: AppColors.primary),
                            ),
                            if (_selectedPatient?.nik != null)
                              Text('NIK: ${_selectedPatient!.nik}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Jika masuk dari menu umum, tampilkan Dropdown Pasien
                BlocBuilder<PatientBloc, PatientState>(
                  builder: (context, patientState) {
                    if (patientState is PatientLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (patientState is PatientLoaded) {
                      final patients = patientState.patients;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPatient?.id,
                                isExpanded: true,
                                hint: const Text('Pilih Pasien'),
                                items: patients.map((p) {
                                  return DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.namaLengkap, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedPatient = patients.firstWhere((p) => p.id == val);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          if (_selectedPatient != null) ...[
                            const SizedBox(height: 12),
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
                                  Text(
                                    _selectedPatient!.namaLengkap,
                                    style: AppTextStyles.labelBold.copyWith(fontSize: 15, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('NIK: ${_selectedPatient!.nik ?? "-"}', style: AppTextStyles.bodySmall),
                                  Text('Tanggal Lahir: ${_selectedPatient!.tanggalLahir.day}-${_selectedPatient!.tanggalLahir.month}-${_selectedPatient!.tanggalLahir.year}', style: AppTextStyles.bodySmall),
                                  Text('Jenis Kelamin: ${_selectedPatient!.jenisKelamin}', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Gagal memuat daftar pasien', style: TextStyle(color: AppColors.error)),
                    );
                  },
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
                    onPressed: () {
                      final medState = context.read<MedicineBloc>().state;
                      if (medState is MedicineLoaded && medState.medicines.isNotEmpty) {
                        setState(() {
                          _prescriptionInputs.add(
                            PrescriptionInput(
                              selectedObat: medState.medicines.first,
                            ),
                          );
                        });
                      } else {
                        _showErrorDialog('Data obat sedang dimuat atau belum tersedia.');
                      }
                    },
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

              if (_prescriptionInputs.isEmpty)
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
                BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, medState) {
                    if (medState is! MedicineLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final obatList = medState.medicines;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _prescriptionInputs.length,
                      itemBuilder: (context, index) {
                        final input = _prescriptionInputs[index];

                        // Cocokkan id obat lama dengan referensi obat dari bloc untuk memastikan model obat paling up-to-date
                        if (input.selectedObat != null) {
                          try {
                            input.selectedObat = obatList.firstWhere((o) => o.id == input.selectedObat!.id);
                          } catch (_) {}
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Obat #${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        input.dispose();
                                        _prescriptionInputs.removeAt(index);
                                      });
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dropdown
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderColor),
                                  color: Colors.grey.shade50,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: input.selectedObat?.id,
                                    isExpanded: true,
                                    items: obatList.map((o) {
                                      return DropdownMenuItem(
                                        value: o.id,
                                        child: Text('${o.namaObat} (Stok: ${o.stok} ${o.satuan})', style: const TextStyle(fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          input.selectedObat = obatList.firstWhere((o) => o.id == v);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Aturan Minum & Jumlah
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: input.aturanController,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                                      decoration: InputDecoration(
                                        labelText: 'Aturan Minum',
                                        prefixIcon: const Icon(Icons.schedule_rounded, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: input.jumlahController,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib' : null,
                                      decoration: InputDecoration(
                                        labelText: 'Jumlah',
                                        prefixIcon: const Icon(Icons.pin_rounded, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                  _isSaving
                      ? 'Menyimpan...'
                      : (isEditMode ? 'Perbarui Rekam Medis' : 'Simpan Rekam Medis'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditMode ? AppColors.primary : AppColors.success,
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
