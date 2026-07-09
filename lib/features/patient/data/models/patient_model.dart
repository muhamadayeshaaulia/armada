import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    super.nik,
    required super.namaLengkap,
    required super.tanggalLahir,
    required super.jenisKelamin,
    super.alamat,
    super.noTelp,
    super.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      nik: json['nik'] as String?,
      namaLengkap: json['nama_lengkap'] as String,
      tanggalLahir: DateTime.parse(json['tanggal_lahir'] as String),
      jenisKelamin: json['jenis_kelamin'] as String,
      alamat: json['alamat'] as String?,
      noTelp: json['no_telp'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'tanggal_lahir': tanggalLahir.toIso8601String().split('T')[0],
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_telp': noTelp,
    };
  }

  factory PatientModel.fromEntity(PatientEntity entity) {
    return PatientModel(
      id: entity.id,
      nik: entity.nik,
      namaLengkap: entity.namaLengkap,
      tanggalLahir: entity.tanggalLahir,
      jenisKelamin: entity.jenisKelamin,
      alamat: entity.alamat,
      noTelp: entity.noTelp,
      createdAt: entity.createdAt,
    );
  }
}
