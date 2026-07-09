import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<PatientEntity> patients;
  const PatientLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientError extends PatientState {
  final String message;
  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientActionSuccess extends PatientState {
  final String message;
  const PatientActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
