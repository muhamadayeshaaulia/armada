import '../../../../features/medicine/domain/entities/medicine_entity.dart';

class ResepObatEntity {
  final String id;
  final String rekamMedisId;
  final String obatId;
  final String aturanMinum;
  final String? dosis;
  final int jumlahDiberikan;
  final MedicineEntity? obat;

  const ResepObatEntity({
    required this.id,
    required this.rekamMedisId,
    required this.obatId,
    required this.aturanMinum,
    this.dosis,
    required this.jumlahDiberikan,
    this.obat,
  });
}

class RekamMedisEntity {
  final String id;
  final String pasienId;
  final String? dokterId;
  final String keluhan;
  final String hasilPemeriksaan;
  final String diagnosis;
  final DateTime? createdAt;
  
  // Detil relasi yang di-join
  final String? namaPasien;
  final String? namaDokter;
  final List<ResepObatEntity>? resepList;

  const RekamMedisEntity({
    required this.id,
    required this.pasienId,
    this.dokterId,
    required this.keluhan,
    required this.hasilPemeriksaan,
    required this.diagnosis,
    this.createdAt,
    this.namaPasien,
    this.namaDokter,
    this.resepList,
  });
}
