import '../../../../features/medicine/data/models/medicine_model.dart';
import '../../domain/entities/rekam_medis_entity.dart';

class ResepObatModel extends ResepObatEntity {
  const ResepObatModel({
    required super.id,
    required super.rekamMedisId,
    required super.obatId,
    required super.aturanMinum,
    required super.jumlahDiberikan,
    super.obat,
  });

  factory ResepObatModel.fromJson(Map<String, dynamic> json) {
    return ResepObatModel(
      id: json['id'] as String,
      rekamMedisId: json['rekam_medis_id'] as String,
      obatId: json['obat_id'] as String,
      aturanMinum: json['aturan_minum'] as String,
      jumlahDiberikan: json['jumlah_diberikan'] as int,
      obat: json['obats'] != null ? MedicineModel.fromJson(json['obats'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rekam_medis_id': rekamMedisId,
      'obat_id': obatId,
      'aturan_minum': aturanMinum,
      'jumlah_diberikan': jumlahDiberikan,
    };
  }
}

class RekamMedisModel extends RekamMedisEntity {
  const RekamMedisModel({
    required super.id,
    required super.pasienId,
    super.dokterId,
    required super.keluhan,
    required super.hasilPemeriksaan,
    required super.diagnosis,
    super.createdAt,
    super.namaPasien,
    super.namaDokter,
    super.resepList,
  });

  factory RekamMedisModel.fromJson(Map<String, dynamic> json) {
    var resepJson = json['resep_obat'] as List?;
    List<ResepObatModel>? resepList = resepJson != null
        ? resepJson.map((r) => ResepObatModel.fromJson(r as Map<String, dynamic>)).toList()
        : null;

    return RekamMedisModel(
      id: json['id'] as String,
      pasienId: json['pasien_id'] as String,
      dokterId: json['dokter_id'] as String?,
      keluhan: json['keluhan'] as String,
      hasilPemeriksaan: json['hasil_pemeriksaan'] as String,
      diagnosis: json['diagnosis'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      namaPasien: json['pasiens'] != null ? json['pasiens']['nama_lengkap'] as String? : null,
      namaDokter: json['dokters'] != null ? json['dokters']['nama_lengkap'] as String? : null,
      resepList: resepList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'dokter_id': dokterId,
      'keluhan': keluhan,
      'hasil_pemeriksaan': hasilPemeriksaan,
      'diagnosis': diagnosis,
    };
  }
}
