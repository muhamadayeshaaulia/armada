import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String role);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.supabaseClient,
  });

  @override
  Future<UserModel> loginWithEmailAndPassword(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      // Ambil role dari Supabase berdasarkan UID Firebase
      final response = await supabaseClient
          .from('users')
          .select('role')
          .eq('id', user.uid)
          .maybeSingle();

      if (response == null) {
        // Jika data tidak ditemukan di Supabase, anggap user tidak valid (sudah dihapus)
        await firebaseAuth.signOut();
        throw Exception('Akun telah dinonaktifkan atau dihapus oleh Admin.');
      }

      final role = response['role'] as String;

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: role,
      );
    } else {
      throw Exception('Gagal mendapatkan data pengguna');
    }
  }

  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      final name = parts[0].replaceAll(RegExp(r'[._-]'), ' ');
      return name.split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }
    return 'Pengguna';
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String role) async {
    // 1. Buat User di Firebase
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      // 2. Simpan UID, email, dan Role ke Supabase (tabel users)
      await supabaseClient.from('users').insert({
        'id': user.uid,
        'email': email,
        'role': role,
      });

      // 3. Masukkan ke tabel admins / dokters sesuai dengan role agar berelasi
      final namaLengkap = _extractNameFromEmail(email);
      if (role == 'admin') {
        await supabaseClient.from('admins').insert({
          'id': user.uid,
          'nama_lengkap': namaLengkap,
        });
      } else if (role == 'dokter') {
        await supabaseClient.from('dokters').insert({
          'id': user.uid,
          'nama_lengkap': namaLengkap,
          'spesialis': 'Umum', // Spesialis default karena NOT NULL di DB
        });
      }

      // 4. Kembalikan UserModel dengan role yang sebenarnya
      return UserModel(
        uid: user.uid,
        email: user.email ?? email,
        role: role,
      );
    } else {
      throw Exception('Gagal mendaftar pengguna baru');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    final response = await supabaseClient
        .from('users')
        .select('role')
        .eq('id', user.uid)
        .maybeSingle();

    if (response == null) {
      // User sudah dihapus di Supabase tapi masih nyangkut di Firebase Auth
      await firebaseAuth.signOut();
      return null;
    }

    final role = response['role'] as String;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      role: role,
    );
  }
}