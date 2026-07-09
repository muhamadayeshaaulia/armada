import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';
import '../models/staff_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StaffEntity>>> getAdmins() async {
    try {
      final admins = await remoteDataSource.getAdmins();
      return Right(admins);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffEntity>>> getDoctors() async {
    try {
      final doctors = await remoteDataSource.getDoctors();
      return Right(doctors);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStaff(StaffEntity staff) async {
    try {
      final staffModel = StaffModel(
        id: staff.id,
        namaLengkap: staff.namaLengkap,
        tempatLahir: staff.tempatLahir,
        tanggalLahir: staff.tanggalLahir,
        noTelp: staff.noTelp,
        alamat: staff.alamat,
        role: staff.role,
        spesialis: staff.spesialis,
        createdAt: staff.createdAt,
      );
      await remoteDataSource.updateStaff(staffModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStaff(String id, String role) async {
    try {
      await remoteDataSource.deleteStaff(id, role);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
