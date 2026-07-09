import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Jenis field mana yang mengalami error autentikasi
enum AuthErrorType {
  email,      // email tidak ditemukan / format salah
  password,   // email benar tapi password salah
  both,       // keduanya gagal (invalid-credential gabungan)
  general,    // error umum (disabled, too-many-requests, dsb)
}

class AuthError extends AuthState {
  final String message;
  final AuthErrorType errorType;

  const AuthError(this.message, {this.errorType = AuthErrorType.general});

  @override
  List<Object> get props => [message, errorType];
}

class AuthUnauthenticated extends AuthState {}