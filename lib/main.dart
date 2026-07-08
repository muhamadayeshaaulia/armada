import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'core/services/notification_service.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi async lainnya
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("=== STARTING APP INITIALIZATION ===");

  // Inisialisasi dan Request Permission Notifikasi di awal buka aplikasi
  try {
    debugPrint("Initializing Notification Service...");
    await NotificationService().init();
    await NotificationService().requestPermission();
    debugPrint("Notification Service initialized successfully");
  } catch (e, stack) {
    debugPrint("ERROR initializing Notification Service: $e\n$stack");
  }

  // Memuat file .env
  try {
    debugPrint("Loading .env file...");
    await dotenv.load(fileName: ".env");
    debugPrint(".env file loaded successfully");
  } catch (e, stack) {
    debugPrint("ERROR loading .env: $e\n$stack");
  }

  // Inisialisasi Supabase menggunakan data dari .env
  try {
    debugPrint("Initializing Supabase...");
    final supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    final supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint("Supabase initialized successfully");
  } catch (e, stack) {
    debugPrint("ERROR initializing Supabase: $e\n$stack");
  }

  // Menjalankan inisialisasi Firebase sesuai platform berjalan
  try {
    debugPrint("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e, stack) {
    debugPrint("ERROR initializing Firebase: $e\n$stack");
  }

  // Menjalankan inisialisasi Dependency Injection (GetIt)
  try {
    debugPrint("Initializing Dependency Injection...");
    await di.init();
    debugPrint("Dependency Injection initialized successfully");
  } catch (e, stack) {
    debugPrint("ERROR initializing Dependency Injection: $e\n$stack");
  }

  debugPrint("=== APP INITIALIZATION COMPLETED ===");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'ARMADA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}