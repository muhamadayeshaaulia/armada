class MedicineEntity {
  final String id;
  final String namaObat;
  final String? kategori;
  final String satuan;
  final int stok;
  final DateTime? createdAt;

  const MedicineEntity({
    required this.id,
    required this.namaObat,
    this.kategori,
    required this.satuan,
    required this.stok,
    this.createdAt,
  });
}
