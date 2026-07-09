class PatientEntity {
  final String id;
  final String? nik;
  final String namaLengkap;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String? alamat;
  final String? noTelp;
  final DateTime? createdAt;

  const PatientEntity({
    required this.id,
    this.nik,
    required this.namaLengkap,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.alamat,
    this.noTelp,
    this.createdAt,
  });
}
