import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {

    // Menangani Event Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Ubah state jadi loading

      final result = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      // Fold dari dartz akan mengecek apakah result itu Left (Gagal) atau Right (Sukses)
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // Menangani Event Logout
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await logoutUseCase();
      emit(AuthInitial()); // Kembali ke state awal setelah logout
    });
  }
}