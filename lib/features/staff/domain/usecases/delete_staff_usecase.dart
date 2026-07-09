import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/staff_repository.dart';

class DeleteStaffUseCase {
  final StaffRepository repository;

  DeleteStaffUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String role) {
    return repository.deleteStaff(id, role);
  }
}
