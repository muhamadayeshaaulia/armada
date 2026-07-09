import '../../domain/entities/medicine_entity.dart';

class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.id,
    required super.namaObat,
    super.kategori,
    required super.satuan,
    required super.stok,
    super.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String,
      namaObat: json['nama_obat'] as String,
      kategori: json['kategori'] as String?,
      satuan: json['satuan'] as String,
      stok: json['stok'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_obat': namaObat,
      'kategori': kategori,
      'satuan': satuan,
      'stok': stok,
    };
  }

  factory MedicineModel.fromEntity(MedicineEntity entity) {
    return MedicineModel(
      id: entity.id,
      namaObat: entity.namaObat,
      kategori: entity.kategori,
      satuan: entity.satuan,
      stok: entity.stok,
      createdAt: entity.createdAt,
    );
  }
}
