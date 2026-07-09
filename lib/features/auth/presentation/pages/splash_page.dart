import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'onboarding_page.dart';
import '../../../../features/main/presentation/pages/main_navigation_page.dart';
import '../../../../core/services/notification_prefs.dart';
import '../../../../core/constants/app_colors.dart';
import 'biometric_auth_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger cek status login saat splash ditampilkan
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // Cek apakah autentikasi biometrik aktif
          final isBioEnabled = await NotificationPrefs.isBiometricEnabled();
          if (!mounted) return;
          if (isBioEnabled) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BiometricAuthPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationPage()),
            );
          }
        } else if (state is AuthUnauthenticated) {
          // User belum / sudah logout → ke onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'ARMADA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aplikasi Rekam Medis dan Data Obat',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
