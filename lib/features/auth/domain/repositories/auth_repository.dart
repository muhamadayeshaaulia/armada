import 'package:armada/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:armada/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Kontrak untuk fungsi Login
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Kontrak untuk fungsi Logout
  Future<Either<Failure, void>> logout();
}