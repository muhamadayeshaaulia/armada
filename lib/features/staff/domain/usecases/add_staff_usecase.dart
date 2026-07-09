import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class AddStaffUseCase {
  final StaffRepository repository;

  AddStaffUseCase(this.repository);

  Future<Either<Failure, void>> call(StaffEntity staff, String email, String password) async {
    return await repository.addStaff(staff, email, password);
  }
}
