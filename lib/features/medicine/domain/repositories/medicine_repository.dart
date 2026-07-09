import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/medicine_entity.dart';

abstract class MedicineRepository {
  Future<Either<Failure, List<MedicineEntity>>> getMedicines();
  Future<Either<Failure, void>> addMedicine(MedicineEntity medicine);
  Future<Either<Failure, void>> updateMedicine(MedicineEntity medicine);
  Future<Either<Failure, void>> deleteMedicine(String id);
}
