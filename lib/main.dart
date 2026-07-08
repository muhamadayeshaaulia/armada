import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:armada/firebase_options.dart';

void main() async {
  // wajib di panggil sebelum inisialisasi firebase
  WidgetsFlutterBinding.ensureInitialized();

  // menjalankan inisialisasi firebase sesuai platform berjalan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARMADA',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ARMADA App'),
        ),
        body: const Center(
          child: Text('Firebase Berhasil Terhubung!'),
        ),
      ),
    );
  }
}