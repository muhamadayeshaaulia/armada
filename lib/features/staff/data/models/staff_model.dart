import '../../domain/entities/staff_entity.dart';

class StaffModel extends StaffEntity {
  const StaffModel({
    required super.id,
    required super.namaLengkap,
    super.tempatLahir,
    super.tanggalLahir,
    super.noTelp,
    super.alamat,
    required super.role,
    super.spesialis,
    super.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json, String role) {
    return StaffModel(
      id: json['id'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      tempatLahir: json['tempat_lahir'] as String?,
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'] as String)
          : null,
      noTelp: json['no_telp'] as String?,
      alamat: json['alamat'] as String?,
      role: role,
      spesialis: json['spesialis'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'nama_lengkap': namaLengkap,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String().substring(0, 10),
      'no_telp': noTelp,
      'alamat': alamat,
    };
    if (role == 'dokter') {
      data['spesialis'] = spesialis ?? 'Umum';
    }
    return data;
  }
}
