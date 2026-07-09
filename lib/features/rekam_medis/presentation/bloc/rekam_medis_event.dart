import 'package:equatable/equatable.dart';
import '../../domain/entities/rekam_medis_entity.dart';

abstract class RekamMedisEvent extends Equatable {
  const RekamMedisEvent();

  @override
  List<Object?> get props => [];
}

class LoadRekamMedisEvent extends RekamMedisEvent {}

class LoadRekamMedisForPatientEvent extends RekamMedisEvent {
  final String patientId;
  const LoadRekamMedisForPatientEvent(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class AddRekamMedisEvent extends RekamMedisEvent {
  final RekamMedisEntity record;
  final List<ResepObatEntity> resepList;

  const AddRekamMedisEvent(this.record, this.resepList);

  @override
  List<Object?> get props => [record, resepList];
}

class UpdateRekamMedisEvent extends RekamMedisEvent {
  final RekamMedisEntity record;
  final List<ResepObatEntity> resepList;

  const UpdateRekamMedisEvent(this.record, this.resepList);

  @override
  List<Object?> get props => [record, resepList];
}
