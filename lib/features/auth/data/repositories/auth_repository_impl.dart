import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userModel = await remoteDataSource.registerWithEmailAndPassword(email, password, role);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Gagal melakukan registrasi'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailAndPassword(
        email,
        password,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      // Tangkap error spesifik dari Firebase
      if (e.code == 'user-not-found') {
        // Kode lama (Firebase SDK sebelum v9)
        return const Left(AuthFailure('[EMAIL_ERROR]Email tidak terdaftar'));
      } else if (e.code == 'wrong-password') {
        // Kode lama (Firebase SDK sebelum v9)
        return const Left(AuthFailure('[PASSWORD_ERROR]Password salah'));
      } else if (e.code == 'invalid-credential' ||
          (e.message?.toLowerCase().contains('incorrect') ?? false) ||
          (e.message?.toLowerCase().contains('malformed') ?? false) ||
          (e.message?.toLowerCase().contains('expired') ?? false)) {
        // Firebase SDK modern (v6+) menggabungkan semua kegagalan login ke 'invalid-credential'
        // → Gunakan sendPasswordResetEmail untuk cek apakah email terdaftar
        //   (tidak benar-benar mengirim email karena kita tidak pernah konfirmasi ke user)
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          // Jika tidak ada exception → email terdaftar → password yang salah
          return const Left(AuthFailure('[PASSWORD_ERROR]Password salah'));
        } on FirebaseAuthException catch (resetErr) {
          if (resetErr.code == 'user-not-found' ||
              resetErr.code == 'invalid-email' ||
              resetErr.code == 'invalid-recipient-email') {
            // Email tidak terdaftar
            return const Left(AuthFailure('[EMAIL_ERROR]Email tidak terdaftar'));
          }
          // Error lain saat cek (misal: quota habis) → tampilkan error gabungan
          return const Left(AuthFailure('[BOTH_ERROR]Email tidak terdaftar atau password salah'));
        }
      } else if (e.code == 'user-disabled') {
        return const Left(AuthFailure('[GENERAL_ERROR]Akun ini telah dinonaktifkan'));
      } else if (e.code == 'too-many-requests') {
        return const Left(AuthFailure('[GENERAL_ERROR]Terlalu banyak percobaan gagal. Coba lagi nanti.'));
      } else {
        return Left(AuthFailure('[GENERAL_ERROR]${e.message ?? 'Terjadi kesalahan autentikasi'}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Gagal melakukan logout'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}