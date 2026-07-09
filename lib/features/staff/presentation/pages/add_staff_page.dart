import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/staff_entity.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/add_staff_usecase.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';

class AddStaffPage extends StatefulWidget {
  final String initialRole;

  const AddStaffPage({super.key, required this.initialRole});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();

  // Auth fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Profile fields
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _spesialisController = TextEditingController();
  DateTime? _tanggalLahir;

  late String _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      initialDate: DateTime(1990),
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

    final newStaff = StaffEntity(
      id: '', // Will be filled by Firebase UID in data source
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
      role: _selectedRole,
      spesialis: _selectedRole == 'dokter'
          ? (_spesialisController.text.trim().isNotEmpty
              ? _spesialisController.text.trim()
              : 'Umum')
          : null,
      createdAt: DateTime.now(),
    );

    final useCase = di.sl<AddStaffUseCase>();
    final result = await useCase(newStaff, _emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan: ${failure.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        // Reload data
        context.read<StaffBloc>().add(LoadStaffEvent());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Petugas berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDokter = _selectedRole == 'dokter';

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Tambah ${isDokter ? 'Dokter' : 'Admin'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildSectionTitle('Informasi Akun (Login)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
              ),

              const SizedBox(height: 24),
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
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Petugas Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      obscureText: obscure,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
