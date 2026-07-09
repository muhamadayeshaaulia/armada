import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/patient_entity.dart';

// Kita pastikan core/errors/failures.dart ada, jika tidak, kita buat atau ganti dengan class error lokal.
// Let's check if core/errors/failures.dart exists in the workspace.
abstract class PatientRepository {
  Future<Either<Failure, List<PatientEntity>>> getPatients();
  Future<Either<Failure, void>> addPatient(PatientEntity patient);
  Future<Either<Failure, void>> updatePatient(PatientEntity patient);
  Future<Either<Failure, void>> deletePatient(String id);
}
