import 'package:armada/core/errors/failure.dart';
import 'package:armada/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  // Kontrak untuk fungsi Login
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  });

  // Kontrak untuk fungsi Logout
  Future<Either<Failure, void>> logout();

  // Kontrak untuk cek sesi login yang ada
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}