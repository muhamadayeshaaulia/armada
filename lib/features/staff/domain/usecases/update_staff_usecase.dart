import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class UpdateStaffUseCase {
  final StaffRepository repository;

  UpdateStaffUseCase(this.repository);

  Future<Either<Failure, void>> call(StaffEntity staff) {
    return repository.updateStaff(staff);
  }
}
