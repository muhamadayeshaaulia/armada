import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine_entity.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicinesEvent extends MedicineEvent {}

class AddMedicineEvent extends MedicineEvent {
  final MedicineEntity medicine;
  const AddMedicineEvent(this.medicine);

  @override
  List<Object?> get props => [medicine];
}

class UpdateMedicineEvent extends MedicineEvent {
  final MedicineEntity medicine;
  const UpdateMedicineEvent(this.medicine);

  @override
  List<Object?> get props => [medicine];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String id;
  const DeleteMedicineEvent(this.id);

  @override
  List<Object?> get props => [id];
}
