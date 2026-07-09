import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/staff_entity.dart';

abstract class StaffRepository {
  Future<Either<Failure, List<StaffEntity>>> getAdmins();
  Future<Either<Failure, List<StaffEntity>>> getDoctors();
  Future<Either<Failure, void>> updateStaff(StaffEntity staff);
  Future<Either<Failure, void>> deleteStaff(String id, String role);
}
