import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffEntity> admins;
  final List<StaffEntity> doctors;

  const StaffLoaded({required this.admins, required this.doctors});

  @override
  List<Object?> get props => [admins, doctors];
}

class StaffActionSuccess extends StaffState {
  final String message;

  const StaffActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}
