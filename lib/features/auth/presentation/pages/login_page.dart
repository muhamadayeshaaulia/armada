import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../features/main/presentation/pages/main_navigation_page.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_prefs.dart';
import '../../../../core/constants/app_colors.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthError? _authError;

  /// State terpisah: email terbukti ada di Firebase (bertahan saat user mengetik password)
  bool _emailIsVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Centang hijau muncul jika email sudah terverifikasi (dari attempt sebelumnya)
  bool get _emailVerified => _emailIsVerified;

  /// Error di field email: jika tipe error 'email' atau 'both'
  String? get _emailErrorText {
    if (_authError == null) return null;
    if (_authError!.errorType == AuthErrorType.email) return _authError!.message;
    if (_authError!.errorType == AuthErrorType.both) return 'Email tidak terdaftar';
    return null;
  }

  /// Error di field password: jika tipe error 'password' atau 'both'
  String? get _passwordErrorText {
    if (_authError == null) return null;
    if (_authError!.errorType == AuthErrorType.password) return _authError!.message;
    if (_authError!.errorType == AuthErrorType.both) return 'Password salah';
    return null;
  }

  void _onLoginPressed() {
    setState(() {
      _authError = null;
      // Jangan reset _emailIsVerified — dipertahankan hingga email berubah
    });
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) async {
                if (state is AuthAuthenticated) {
                  if (ModalRoute.of(context)?.isCurrent ?? false) {
                    final loginNotifEnabled = await NotificationPrefs.isAutentikasiNotifEnabled();
                    if (loginNotifEnabled) {
                      NotificationService().showNotification(
                        id: 1,
                        title: 'Selamat Datang Kembali!',
                        body: 'Login berhasil, Anda sekarang berada di beranda Armada.',
                      );
                    }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationPage()),
                      (route) => false,
                    );
                  }
                } else if (state is AuthError) {
                  if (state.errorType == AuthErrorType.general) {
                    // Error umum (bukan per-field) → tampilkan snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  } else {
                    setState(() {
                      _authError = state;
                      // Jika hanya password yang salah → tandai email sebagai terverifikasi
                      // (centang hijau akan tetap tampil meski user mengetik di password)
                      if (state.errorType == AuthErrorType.password) {
                        _emailIsVerified = true;
                      } else {
                        // Email salah atau keduanya → hapus status verifikasi
                        _emailIsVerified = false;
                      }
                    });
                    // Trigger ulang validator agar error muncul di dalam field
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _formKey.currentState?.validate();
                    });
                  }
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ARMADA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'Aplikasi Rekam Medis Andalan Dokter Aktif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Input Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          // Jika email berubah: reset SEMUA state termasuk verifikasi email
                          setState(() {
                            _authError = null;
                            _emailIsVerified = false;
                          });
                          _formKey.currentState?.validate();
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          // Centang hijau jika email terbukti terdaftar (hanya password salah)
                          suffixIcon: _emailVerified
                              ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _emailErrorText != null
                                  ? Colors.red
                                  : _emailVerified
                                      ? Colors.green
                                      : AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _emailErrorText != null
                                  ? Colors.red
                                  : _emailVerified
                                      ? Colors.green
                                      : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        // Validator mengembalikan auth error agar TextFormField
                        // menampilkannya via FormField (field.errorText), bukan InputDecoration
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return _emailErrorText; // null jika tidak ada error
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (_) {
                          // Password berubah: hanya hapus auth error, JANGAN hapus _emailIsVerified
                          // supaya centang hijau di email tetap tampil
                          if (_authError != null) {
                            setState(() { _authError = null; });
                            _formKey.currentState?.validate();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _passwordErrorText != null
                                  ? Colors.red
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _passwordErrorText != null
                                  ? Colors.red
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return _passwordErrorText; // null jika tidak ada error
                        },
                      ),
                      const SizedBox(height: 24),


                      // Tombol Login
                      ElevatedButton(
                        onPressed: state is AuthLoading ? null : _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      // Membuat text dan  navigator push ke halaman register
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar di sini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}