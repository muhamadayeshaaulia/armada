import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> loginWithEmailAndPassword(String email, String password) async {
    // Eksekusi login ke Firebase
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Jika berhasil dan user tidak null, kembalikan ke dalam bentuk UserModel
    if (userCredential.user != null) {
      return UserModel.fromFirebaseUser(userCredential.user!);
    } else {
      throw Exception('Gagal mendapatkan data pengguna');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}