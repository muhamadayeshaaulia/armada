import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String role);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final SupabaseClient supabaseClient; // Tambahkan Supabase Client

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.supabaseClient,
  });

  @override
  Future<UserModel> loginWithEmailAndPassword(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user != null) {
      return UserModel.fromFirebaseUser(userCredential.user!);
    } else {
      throw Exception('Gagal mendapatkan data pengguna');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String role) async {
    // 1. Buat User di Firebase
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;

    if (user != null) {
      // 2. Simpan UID dan Role ke Supabase
      await supabaseClient.from('users').insert({
        'id': user.uid,
        'email': email,
        'role': role,
      });
      return UserModel.fromFirebaseUser(user);
    } else {
      throw Exception('Gagal mendaftar pengguna baru');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}