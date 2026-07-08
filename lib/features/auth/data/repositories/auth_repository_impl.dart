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
      return Left(AuthFailure(e.message ?? 'Kredensial tidak valid'));
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
}