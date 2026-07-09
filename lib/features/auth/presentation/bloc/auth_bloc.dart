import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {

    // Cek sesi login yang ada (auto-login)
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) {
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUseCase(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // Menangani Event Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Ubah state jadi loading

      final result = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      // Fold dari dartz akan mengecek apakah result itu Left (Gagal) atau Right (Sukses)
      result.fold(
        (failure) {
          // Parse prefix kode untuk menentukan field yang error
          final raw = failure.message;
          if (raw.startsWith('[EMAIL_ERROR]')) {
            emit(AuthError(raw.replaceFirst('[EMAIL_ERROR]', ''), errorType: AuthErrorType.email));
          } else if (raw.startsWith('[PASSWORD_ERROR]')) {
            emit(AuthError(raw.replaceFirst('[PASSWORD_ERROR]', ''), errorType: AuthErrorType.password));
          } else if (raw.startsWith('[BOTH_ERROR]')) {
            emit(AuthError(raw.replaceFirst('[BOTH_ERROR]', ''), errorType: AuthErrorType.both));
          } else {
            final clean = raw.replaceFirst(RegExp(r'^\[.*?\]'), '');
            emit(AuthError(clean, errorType: AuthErrorType.general));
          }
        },
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // Menangani Event Logout
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await logoutUseCase();
      emit(AuthUnauthenticated()); // Kembali ke state unauthenticated setelah logout
    });
  }
}