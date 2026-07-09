import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/rekam_medis_repository.dart';
import 'rekam_medis_event.dart';
import 'rekam_medis_state.dart';

class RekamMedisBloc extends Bloc<RekamMedisEvent, RekamMedisState> {
  final RekamMedisRepository repository;

  RekamMedisBloc({required this.repository}) : super(RekamMedisInitial()) {
    on<LoadRekamMedisEvent>((event, emit) async {
      emit(RekamMedisLoading());
      final result = await repository.getRekamMedis();
      result.fold(
        (failure) => emit(RekamMedisError(failure.message)),
        (records) => emit(RekamMedisLoaded(records)),
      );
    });

    on<LoadRekamMedisForPatientEvent>((event, emit) async {
      emit(RekamMedisLoading());
      final result = await repository.getRekamMedisForPatient(event.patientId);
      result.fold(
        (failure) => emit(RekamMedisError(failure.message)),
        (records) => emit(RekamMedisLoaded(records)),
      );
    });

    on<AddRekamMedisEvent>((event, emit) async {
      emit(RekamMedisLoading());
      final result = await repository.addRekamMedis(event.record, event.resepList);
      result.fold(
        (failure) => emit(RekamMedisError(failure.message)),
        (_) {
          emit(const RekamMedisActionSuccess('Rekam medis berhasil disimpan.'));
          add(LoadRekamMedisForPatientEvent(event.record.pasienId));
        },
      );
    });

    on<UpdateRekamMedisEvent>((event, emit) async {
      emit(RekamMedisLoading());
      final result = await repository.updateRekamMedis(event.record, event.resepList);
      result.fold(
        (failure) => emit(RekamMedisError(failure.message)),
        (_) {
          emit(const RekamMedisActionSuccess('Rekam medis berhasil diperbarui.'));
          add(LoadRekamMedisForPatientEvent(event.record.pasienId));
        },
      );
    });
  }
}
