import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/patient_entity.dart';
import '../../../rekam_medis/presentation/bloc/rekam_medis_bloc.dart';
import '../../../rekam_medis/presentation/bloc/rekam_medis_event.dart';
import '../../../rekam_medis/presentation/bloc/rekam_medis_state.dart';
import '../../../rekam_medis/presentation/pages/add_rekam_medis_page.dart';
import '../../../rekam_medis/domain/entities/rekam_medis_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientDetailPage extends StatefulWidget {
  final PatientEntity patient;
  final bool isFromLaporan;

  const PatientDetailPage({super.key, required this.patient, this.isFromLaporan = false});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load rekam medis history for this patient
    context.read<RekamMedisBloc>().add(LoadRekamMedisForPatientEvent(widget.patient.id));
  }

  Future<void> _printPatientHistory(List<RekamMedisEntity> records) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
             pw.Header(
                level: 0,
                child: pw.Text('LAPORAN RIWAYAT REKAM MEDIS PASIEN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
             ),
             pw.SizedBox(height: 10),
             _buildPdfRow('Nama Pasien', widget.patient.namaLengkap),
             _buildPdfRow('NIK', widget.patient.nik ?? '-'),
             _buildPdfRow('Total Kunjungan', '${records.length} kali'),
             pw.SizedBox(height: 20),
             pw.TableHelper.fromTextArray(
                headers: ['No', 'Tanggal', 'Dokter', 'Diagnosis', 'Keluhan'],
                data: List<List<dynamic>>.generate(records.length, (index) {
                   final r = records[index];
                   final dateStr = r.createdAt != null
                       ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}'
                       : '-';
                   return [
                      (index + 1).toString(),
                      dateStr,
                      'Dr. ${r.namaDokter ?? 'Umum'}',
                      r.diagnosis,
                      r.keluhan,
                   ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                },
             ),
          ];
        }
      )
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _printSingleRecord(RekamMedisEntity r) async {
    final pdf = pw.Document();

    final dateStr = r.createdAt != null
        ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}'
        : '-';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('SURAT KETERANGAN REKAM MEDIS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ),
                pw.Center(
                  child: pw.Text('KLINIK KASIH IBU', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                _buildPdfRow('Nama Pasien', r.namaPasien ?? '-'),
                _buildPdfRow('Tanggal Periksa', dateStr),
                _buildPdfRow('Dokter Pemeriksa', 'Dr. ${r.namaDokter ?? 'Umum'}'),
                pw.SizedBox(height: 15),
                pw.Divider(),
                pw.SizedBox(height: 15),
                _buildPdfRow('Keluhan Utama', r.keluhan),
                _buildPdfRow('Hasil Pemeriksaan', r.hasilPemeriksaan),
                _buildPdfRow('Diagnosis', r.diagnosis),
                pw.SizedBox(height: 20),
                if (r.resepList != null && r.resepList!.isNotEmpty) ...[
                  pw.Text('Resep Obat:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.SizedBox(height: 8),
                  ...r.resepList!.map((resep) => pw.Bullet(
                        text: '${resep.obat?.namaObat ?? 'Obat'} - Aturan: ${resep.aturanMinum} (Jml: ${resep.jumlahDiberikan} ${resep.obat?.satuan ?? ''})',
                        style: const pw.TextStyle(fontSize: 11),
                      )),
                ],
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text('Pemeriksa,', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 60),
                      pw.Text('Dr. ${r.namaDokter ?? 'Umum'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 140, child: pw.Text('$label  :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final age = _calculateAge(p.tanggalLahir);

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Detail Pasien & Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (widget.isFromLaporan)
            BlocBuilder<RekamMedisBloc, RekamMedisState>(
              builder: (context, state) {
                if (state is RekamMedisLoaded && state.records.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.print_rounded),
                    tooltip: 'Cetak Riwayat Pasien',
                    onPressed: () => _printPatientHistory(state.records),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demographic Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        p.namaLengkap[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.namaLengkap, style: AppTextStyles.headerTitle.copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('NIK: ${p.nik ?? '-'}', style: AppTextStyles.headerSubtitle.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('JENIS KELAMIN', p.jenisKelamin),
                    _buildInfoColumn('UMUR / TGL LAHIR', '$age Tahun / ${p.tanggalLahir.day}-${p.tanggalLahir.month}-${p.tanggalLahir.year}'),
                    _buildInfoColumn('TELEPON', p.noTelp ?? '-'),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoColumn('ALAMAT', p.alamat ?? '-'),
              ],
            ),
          ),

          // Riwayat Rekam Medis Section Title
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pemeriksaan',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRekamMedisPage(patient: p),
                      ),
                    ).then((_) {
                      context.read<RekamMedisBloc>().add(LoadRekamMedisForPatientEvent(p.id));
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Rekam Medis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Rekam Medis List
          Expanded(
            child: BlocBuilder<RekamMedisBloc, RekamMedisState>(
              builder: (context, state) {
                if (state is RekamMedisLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RekamMedisError) {
                  return Center(child: Text(state.message, style: TextStyle(color: AppColors.error)));
                }

                if (state is RekamMedisLoaded) {
                  if (state.records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text('Belum ada riwayat rekam medis', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.records.length,
                    itemBuilder: (context, index) {
                      final r = state.records[index];
                      final dateStr = r.createdAt != null
                          ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}'
                          : '-';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 22),
                            ),
                            title: Text(
                              r.diagnosis,
                              style: AppTextStyles.labelBold.copyWith(fontSize: 14, color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Tgl: $dateStr • Dr. ${r.namaDokter ?? 'Umum'}',
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(color: AppColors.borderColor),
                                    const SizedBox(height: 8),
                                    _buildDetailRow('Keluhan Utama', r.keluhan),
                                    const SizedBox(height: 8),
                                    _buildDetailRow('Hasil Pemeriksaan', r.hasilPemeriksaan),
                                    const SizedBox(height: 8),
                                    
                                    // Resep Obat Section
                                    if (r.resepList != null && r.resepList!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Resep Obat:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 6),
                                      ...r.resepList!.map((resep) => Container(
                                            margin: const EdgeInsets.only(bottom: 6),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        resep.obat?.namaObat ?? 'Nama Obat',
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                      ),
                                                      Text(
                                                        resep.aturanMinum,
                                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  '${resep.jumlahDiberikan} ${resep.obat?.satuan ?? ''}',
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AddRekamMedisPage(
                                                    patient: widget.patient,
                                                    record: r,
                                                  ),
                                                ),
                                              ).then((_) {
                                                context.read<RekamMedisBloc>().add(LoadRekamMedisForPatientEvent(widget.patient.id));
                                              });
                                            },
                                            icon: const Icon(Icons.edit_rounded, size: 16),
                                            label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary.withOpacity(0.1),
                                              foregroundColor: AppColors.primary,
                                              minimumSize: const Size(0, 40),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _printSingleRecord(r),
                                            icon: const Icon(Icons.print_rounded, size: 16),
                                            label: const Text('Cetak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(0, 40),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDetailRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      ],
    );
  }
}
