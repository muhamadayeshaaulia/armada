import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_admins_usecase.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/update_staff_usecase.dart';
import '../../domain/usecases/delete_staff_usecase.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetAdminsUseCase getAdminsUseCase;
  final GetDoctorsUseCase getDoctorsUseCase;
  final UpdateStaffUseCase updateStaffUseCase;
  final DeleteStaffUseCase deleteStaffUseCase;

  StaffBloc({
    required this.getAdminsUseCase,
    required this.getDoctorsUseCase,
    required this.updateStaffUseCase,
    required this.deleteStaffUseCase,
  }) : super(StaffInitial()) {
    
    on<LoadStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final adminsResult = await getAdminsUseCase();
      final doctorsResult = await getDoctorsUseCase();

      adminsResult.fold(
        (failure) => emit(StaffError(failure.message)),
        (admins) {
          doctorsResult.fold(
            (failure) => emit(StaffError(failure.message)),
            (doctors) => emit(StaffLoaded(admins: admins, doctors: doctors)),
          );
        },
      );
    });

    on<UpdateStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await updateStaffUseCase(event.staff);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (_) {
          emit(const StaffActionSuccess('Data petugas berhasil diperbarui'));
          add(LoadStaffEvent());
        },
      );
    });

    on<DeleteStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await deleteStaffUseCase(event.id, event.role);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (_) {
          emit(const StaffActionSuccess('Petugas berhasil dihapus'));
          add(LoadStaffEvent());
        },
      );
    });
  }
}
