import 'package:equatable/equatable.dart';
import '../../domain/entities/rekam_medis_entity.dart';

abstract class RekamMedisState extends Equatable {
  const RekamMedisState();

  @override
  List<Object?> get props => [];
}

class RekamMedisInitial extends RekamMedisState {}

class RekamMedisLoading extends RekamMedisState {}

class RekamMedisLoaded extends RekamMedisState {
  final List<RekamMedisEntity> records;
  const RekamMedisLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class RekamMedisError extends RekamMedisState {
  final String message;
  const RekamMedisError(this.message);

  @override
  List<Object?> get props => [message];
}

class RekamMedisActionSuccess extends RekamMedisState {
  final String message;
  const RekamMedisActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
