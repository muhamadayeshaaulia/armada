import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientsEvent extends PatientEvent {}

class AddPatientEvent extends PatientEvent {
  final PatientEntity patient;
  const AddPatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UpdatePatientEvent extends PatientEvent {
  final PatientEntity patient;
  const UpdatePatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

class DeletePatientEvent extends PatientEvent {
  final String id;
  const DeletePatientEvent(this.id);

  @override
  List<Object?> get props => [id];
}
