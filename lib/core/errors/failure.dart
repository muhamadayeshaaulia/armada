import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Error jika terjadi masalah pada server/jaringan/Firebase
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Error khusus masalah autentikasi (seperti email salah/password salah)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}