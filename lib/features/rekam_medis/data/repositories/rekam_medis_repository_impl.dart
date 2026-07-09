import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/rekam_medis_entity.dart';
import '../../domain/repositories/rekam_medis_repository.dart';
import '../datasources/rekam_medis_remote_data_source.dart';
import '../models/rekam_medis_model.dart';

class RekamMedisRepositoryImpl implements RekamMedisRepository {
  final RekamMedisRemoteDataSource remoteDataSource;

  RekamMedisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RekamMedisEntity>>> getRekamMedis() async {
    try {
      final response = await remoteDataSource.getRekamMedis();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RekamMedisEntity>>> getRekamMedisForPatient(String patientId) async {
    try {
      final response = await remoteDataSource.getRekamMedisForPatient(patientId);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addRekamMedis(RekamMedisEntity record, List<ResepObatEntity> resepList) async {
    try {
      final recordModel = RekamMedisModel(
        id: record.id,
        pasienId: record.pasienId,
        dokterId: record.dokterId,
        keluhan: record.keluhan,
        hasilPemeriksaan: record.hasilPemeriksaan,
        diagnosis: record.diagnosis,
        createdAt: record.createdAt,
      );

      final resepModels = resepList.map((resep) => ResepObatModel(
        id: resep.id,
        rekamMedisId: resep.rekamMedisId,
        obatId: resep.obatId,
        aturanMinum: resep.aturanMinum,
        dosis: resep.dosis,
        jumlahDiberikan: resep.jumlahDiberikan,
      )).toList();

      await remoteDataSource.addRekamMedis(recordModel, resepModels);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRekamMedis(RekamMedisEntity record, List<ResepObatEntity> resepList) async {
    try {
      final recordModel = RekamMedisModel(
        id: record.id,
        pasienId: record.pasienId,
        dokterId: record.dokterId,
        keluhan: record.keluhan,
        hasilPemeriksaan: record.hasilPemeriksaan,
        diagnosis: record.diagnosis,
        createdAt: record.createdAt,
      );

      final resepModels = resepList.map((resep) => ResepObatModel(
        id: resep.id,
        rekamMedisId: resep.rekamMedisId,
        obatId: resep.obatId,
        aturanMinum: resep.aturanMinum,
        dosis: resep.dosis,
        jumlahDiberikan: resep.jumlahDiberikan,
      )).toList();

      await remoteDataSource.updateRekamMedis(recordModel, resepModels);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
