import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine_entity.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineEntity> medicines;
  const MedicineLoaded(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class MedicineError extends MedicineState {
  final String message;
  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineActionSuccess extends MedicineState {
  final String message;
  const MedicineActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
