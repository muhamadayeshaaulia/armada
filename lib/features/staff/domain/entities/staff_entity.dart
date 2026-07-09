import 'package:equatable/equatable.dart';

class StaffEntity extends Equatable {
  final String id;
  final String namaLengkap;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? noTelp;
  final String? alamat;
  final String role; // 'admin' or 'dokter'
  final String? spesialis; // Khusus dokter
  final DateTime? createdAt;

  const StaffEntity({
    required this.id,
    required this.namaLengkap,
    this.tempatLahir,
    this.tanggalLahir,
    this.noTelp,
    this.alamat,
    required this.role,
    this.spesialis,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        namaLengkap,
        tempatLahir,
        tanggalLahir,
        noTelp,
        alamat,
        role,
        spesialis,
        createdAt,
      ];
}
