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

      final role = (response != null && response['role'] != null)
          ? response['role'] as String
          : 'dokter'; // fallback jika data tidak ditemukan

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: role,
      );
    } else {
      throw Exception('Gagal mendapatkan data pengguna');
    }
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
      // 2. Simpan UID, email, dan Role ke Supabase
      await supabaseClient.from('users').insert({
        'id': user.uid,
        'email': email,
        'role': role,
      });

      // 3. Kembalikan UserModel dengan role yang sebenarnya (bukan hardcode)
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

    final role = (response != null && response['role'] != null)
        ? response['role'] as String
        : 'dokter';

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      role: role,
    );
  }
}