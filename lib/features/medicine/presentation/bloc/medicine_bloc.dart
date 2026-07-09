import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/medicine_repository.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository repository;

  MedicineBloc({required this.repository}) : super(MedicineInitial()) {
    on<LoadMedicinesEvent>((event, emit) async {
      emit(MedicineLoading());
      final result = await repository.getMedicines();
      result.fold(
        (failure) => emit(MedicineError(failure.message)),
        (medicines) => emit(MedicineLoaded(medicines)),
      );
    });

    on<AddMedicineEvent>((event, emit) async {
      emit(MedicineLoading());
      final result = await repository.addMedicine(event.medicine);
      result.fold(
        (failure) => emit(MedicineError(failure.message)),
        (_) {
          emit(const MedicineActionSuccess('Obat berhasil ditambahkan.'));
          add(LoadMedicinesEvent());
        },
      );
    });

    on<UpdateMedicineEvent>((event, emit) async {
      emit(MedicineLoading());
      final result = await repository.updateMedicine(event.medicine);
      result.fold(
        (failure) => emit(MedicineError(failure.message)),
        (_) {
          emit(const MedicineActionSuccess('Data obat berhasil diperbarui.'));
          add(LoadMedicinesEvent());
        },
      );
    });

    on<DeleteMedicineEvent>((event, emit) async {
      emit(MedicineLoading());
      final result = await repository.deleteMedicine(event.id);
      result.fold(
        (failure) => emit(MedicineError(failure.message)),
        (_) {
          emit(const MedicineActionSuccess('Obat berhasil dihapus.'));
          add(LoadMedicinesEvent());
        },
      );
    });
  }
}
