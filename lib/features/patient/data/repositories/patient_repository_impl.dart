import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_data_source.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientEntity>>> getPatients() async {
    try {
      final response = await remoteDataSource.getPatients();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPatient(PatientEntity patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      await remoteDataSource.addPatient(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePatient(PatientEntity patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      await remoteDataSource.updatePatient(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(String id) async {
    try {
      await remoteDataSource.deletePatient(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
