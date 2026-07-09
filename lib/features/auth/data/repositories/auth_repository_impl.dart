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
      return Right(userModel); // Berhasil (Right)
    } on FirebaseAuthException catch (e) {
      // Tangkap error spesifik dari Firebase
      String errorMessage = 'Terjadi kesalahan autentikasi';
      if (e.code == 'user-not-found') {
        errorMessage = 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Email tidak terdaftar atau password salah';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Akun ini telah dinonaktifkan';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Terlalu banyak percobaan masuk yang gagal. Silakan coba lagi nanti.';
      } else if (e.message != null) {
        // Fallback translation if message contains certain terms
        final msg = e.message!.toLowerCase();
        if (msg.contains('incorrect') || msg.contains('expired') || msg.contains('malformed')) {
          errorMessage = 'Email tidak terdaftar atau password salah';
        } else {
          errorMessage = e.message!;
        }
      }
      return Left(AuthFailure(errorMessage));
    } catch (e) {
      // Tangkap error umum
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