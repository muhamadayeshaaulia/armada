import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/rekam_medis_entity.dart';

abstract class RekamMedisRepository {
  Future<Either<Failure, List<RekamMedisEntity>>> getRekamMedis();
  Future<Either<Failure, List<RekamMedisEntity>>> getRekamMedisForPatient(String patientId);
  Future<Either<Failure, void>> addRekamMedis(RekamMedisEntity record, List<ResepObatEntity> resepList);
}
