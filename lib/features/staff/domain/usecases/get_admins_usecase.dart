import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class GetAdminsUseCase {
  final StaffRepository repository;

  GetAdminsUseCase(this.repository);

  Future<Either<Failure, List<StaffEntity>>> call() {
    return repository.getAdmins();
  }
}
