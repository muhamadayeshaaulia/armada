import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/patient_repository.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repository;

  PatientBloc({required this.repository}) : super(PatientInitial()) {
    on<LoadPatientsEvent>((event, emit) async {
      emit(PatientLoading());
      final result = await repository.getPatients();
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (patients) => emit(PatientLoaded(patients)),
      );
    });

    on<AddPatientEvent>((event, emit) async {
      emit(PatientLoading());
      final result = await repository.addPatient(event.patient);
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (_) {
          emit(const PatientActionSuccess('Pasien berhasil ditambahkan.'));
          add(LoadPatientsEvent());
        },
      );
    });

    on<UpdatePatientEvent>((event, emit) async {
      emit(PatientLoading());
      final result = await repository.updatePatient(event.patient);
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (_) {
          emit(const PatientActionSuccess('Data pasien berhasil diperbarui.'));
          add(LoadPatientsEvent());
        },
      );
    });

    on<DeletePatientEvent>((event, emit) async {
      emit(PatientLoading());
      final result = await repository.deletePatient(event.id);
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (_) {
          emit(const PatientActionSuccess('Pasien berhasil dihapus.'));
          add(LoadPatientsEvent());
        },
      );
    });
  }
}
