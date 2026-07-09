import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';

class EditStaffPage extends StatefulWidget {
  final StaffEntity staff;

  const EditStaffPage({super.key, required this.staff});

  @override
  State<EditStaffPage> createState() => _EditStaffPageState();
}

class _EditStaffPageState extends State<EditStaffPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _tempatLahirController;
  late final TextEditingController _noTelpController;
  late final TextEditingController _alamatController;
  late final TextEditingController _spesialisController;
  DateTime? _tanggalLahir;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.staff.namaLengkap);
    _tempatLahirController =
        TextEditingController(text: widget.staff.tempatLahir ?? '');
    _noTelpController =
        TextEditingController(text: widget.staff.noTelp ?? '');
    _alamatController =
        TextEditingController(text: widget.staff.alamat ?? '');
    _spesialisController =
        TextEditingController(text: widget.staff.spesialis ?? '');
    _tanggalLahir = widget.staff.tanggalLahir;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tempatLahirController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _spesialisController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final updatedStaff = StaffEntity(
        id: widget.staff.id,
        namaLengkap: _namaController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim().isNotEmpty
            ? _tempatLahirController.text.trim()
            : null,
        tanggalLahir: _tanggalLahir,
        noTelp: _noTelpController.text.trim().isNotEmpty
            ? _noTelpController.text.trim()
            : null,
        alamat: _alamatController.text.trim().isNotEmpty
            ? _alamatController.text.trim()
            : null,
        role: widget.staff.role,
        spesialis: widget.staff.role == 'dokter' &&
                _spesialisController.text.trim().isNotEmpty
            ? _spesialisController.text.trim()
            : widget.staff.spesialis,
        createdAt: widget.staff.createdAt,
      );

      context.read<StaffBloc>().add(UpdateStaffEvent(updatedStaff));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDokter = widget.staff.role == 'dokter';

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Edit ${isDokter ? 'Dokter' : 'Admin'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _onSave,
              child: const Text(
                'Simpan',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: (isDokter ? AppColors.info : AppColors.menuReport)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _namaController.text.isNotEmpty
                          ? _namaController.text
                              .split(' ')
                              .take(2)
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .join()
                              .toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isDokter ? AppColors.info : AppColors.menuReport,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              _buildSectionTitle('Informasi Dasar'),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              if (isDokter) ...[
                _buildTextField(
                  controller: _spesialisController,
                  label: 'Spesialis',
                  icon: Icons.medical_services_outlined,
                  hint: 'contoh: Umum, Gigi, Anak',
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tempatLahirController,
                      label: 'Tempat Lahir',
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tanggalLahir != null
                                    ? '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'
                                    : 'Tgl Lahir',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _tanggalLahir != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Kontak & Lokasi'),
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
                label: 'Alamat',
                icon: Icons.home_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Simpan Button
              ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
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
        hintText: hint,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
