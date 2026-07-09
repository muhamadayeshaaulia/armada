import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffEvent extends StaffEvent {}

class UpdateStaffEvent extends StaffEvent {
  final StaffEntity staff;

  const UpdateStaffEvent(this.staff);

  @override
  List<Object?> get props => [staff];
}

class DeleteStaffEvent extends StaffEvent {
  final String id;
  final String role;

  const DeleteStaffEvent(this.id, this.role);

  @override
  List<Object?> get props => [id, role];
}
