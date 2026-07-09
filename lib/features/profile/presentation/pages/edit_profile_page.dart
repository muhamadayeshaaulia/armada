import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../staff/domain/entities/staff_entity.dart';
import '../../../staff/domain/usecases/update_staff_usecase.dart';
import '../../../../injection_container.dart' as di;

class EditProfilePage extends StatefulWidget {
  final String uid;
  final String role;
  final Map<String, dynamic> initialData;

  const EditProfilePage({
    super.key,
    required this.uid,
    required this.role,
    required this.initialData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _namaController;
  late final TextEditingController _tempatLahirController;
  late final TextEditingController _noTelpController;
  late final TextEditingController _alamatController;
  late final TextEditingController _spesialisController;
  DateTime? _tanggalLahir;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialData['nama_lengkap'] ?? '');
    _tempatLahirController = TextEditingController(text: widget.initialData['tempat_lahir'] ?? '');
    _noTelpController = TextEditingController(text: widget.initialData['no_telp'] ?? '');
    _alamatController = TextEditingController(text: widget.initialData['alamat'] ?? '');
    _spesialisController = TextEditingController(text: widget.initialData['spesialis'] ?? '');
    if (widget.initialData['tanggal_lahir'] != null) {
      _tanggalLahir = DateTime.tryParse(widget.initialData['tanggal_lahir']);
    }
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
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedStaff = StaffEntity(
      id: widget.uid,
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
      role: widget.role,
      spesialis: widget.role == 'dokter'
          ? (_spesialisController.text.trim().isNotEmpty
              ? _spesialisController.text.trim()
              : 'Umum')
          : null,
      createdAt: widget.initialData['created_at'] != null
          ? DateTime.parse(widget.initialData['created_at'])
          : DateTime.now(),
    );

    final updateUseCase = di.sl<UpdateStaffUseCase>();
    final result = await updateUseCase(updatedStaff);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${failure.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        Navigator.pop(context, true); // kembalikan true untuk memicu reload profil
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDokter = widget.role == 'dokter';

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Dasar'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              if (isDokter) ...[
                _buildTextField(
                  controller: _spesialisController,
                  label: 'Spesialis',
                  icon: Icons.medical_services_outlined,
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
                                    : 'Tgl Lahir',
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
                  _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary));
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
