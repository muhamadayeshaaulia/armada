import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Untuk state management
import 'firebase_options.dart'; // Dari flutterfire configure

// Import Injection Container dan BLoC Auth
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi async lainnya
  WidgetsFlutterBinding.ensureInitialized();

  // Menjalankan inisialisasi Dependency Injection (GetIt)
  await di.init();

  // Menjalankan inisialisasi Firebase sesuai platform berjalan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftarkan AuthBloc ke tingkat paling atas (Global) menggunakan BlocProvider
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
        home: Scaffold(
          appBar: AppBar(
            title: const Text('ARMADA App'),
          ),
          body: const Center(
            child: Text('Firebase & Arsitektur Berhasil Terhubung!'),
          ),
        ),
      ),
    );
  }
}