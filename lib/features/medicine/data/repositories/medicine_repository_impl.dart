import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_data_source.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MedicineEntity>>> getMedicines() async {
    try {
      final response = await remoteDataSource.getMedicines();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMedicine(MedicineEntity medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      await remoteDataSource.addMedicine(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicine(MedicineEntity medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      await remoteDataSource.updateMedicine(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine(String id) async {
    try {
      await remoteDataSource.deleteMedicine(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
