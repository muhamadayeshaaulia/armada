import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_prefs.dart';
import '../../domain/entities/patient_entity.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';

class AddPatientPage extends StatefulWidget {
  final PatientEntity? patient; // null means adding new patient, otherwise editing

  const AddPatientPage({super.key, this.patient});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nikController;
  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _noTelpController;
  
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'Laki-laki';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nikController = TextEditingController(text: p?.nik ?? '');
    _namaController = TextEditingController(text: p?.namaLengkap ?? '');
    _alamatController = TextEditingController(text: p?.alamat ?? '');
    _noTelpController = TextEditingController(text: p?.noTelp ?? '');
    
    if (p != null) {
      _tanggalLahir = p.tanggalLahir;
      _jenisKelamin = p.jenisKelamin;
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tanggal Lahir Kosong'),
          content: const Text('Harap pilih tanggal lahir pasien.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final patient = PatientEntity(
      id: widget.patient?.id ?? '',
      nik: _nikController.text.trim().isNotEmpty ? _nikController.text.trim() : null,
      namaLengkap: _namaController.text.trim(),
      tanggalLahir: _tanggalLahir!,
      jenisKelamin: _jenisKelamin,
      alamat: _alamatController.text.trim().isNotEmpty ? _alamatController.text.trim() : null,
      noTelp: _noTelpController.text.trim().isNotEmpty ? _noTelpController.text.trim() : null,
    );

    if (widget.patient == null) {
      context.read<PatientBloc>().add(AddPatientEvent(patient));
    } else {
      context.read<PatientBloc>().add(UpdatePatientEvent(patient));
    }

    // Trigger local notification (Kategori Umum)
    final notifEnabled = await NotificationPrefs.isUmumNotifEnabled();
    if (notifEnabled) {
      await NotificationService().showNotification(
        id: 30,
        title: widget.patient == null ? 'Pasien Ditambahkan' : 'Data Pasien Diperbarui',
        body: '${_namaController.text.trim()} berhasil disimpan ke database.',
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Data Pasien' : 'Tambah Pasien', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Demografis', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap Pasien',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _nikController,
                label: 'Nomor Induk Kependudukan (NIK)',
                icon: Icons.badge_outlined,
                keyboard: TextInputType.number,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty && v.trim().length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tanggalLahir != null
                                    ? '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'
                                    : 'Tanggal Lahir',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _tanggalLahir != null ? AppColors.textPrimary : AppColors.textHint,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _jenisKelamin,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          items: ['Laki-laki', 'Perempuan'].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _jenisKelamin = v);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('Kontak & Alamat', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _noTelpController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _alamatController,
                label: 'Alamat Tinggal',
                icon: Icons.home_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Data Pasien',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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
