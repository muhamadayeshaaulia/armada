import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/rekam_medis_bloc.dart';
import '../bloc/rekam_medis_event.dart';
import '../bloc/rekam_medis_state.dart';
import '../../domain/entities/rekam_medis_entity.dart';
import '../../../patient/domain/entities/patient_entity.dart';
import '../../../patient/presentation/bloc/patient_bloc.dart';
import '../../../patient/presentation/bloc/patient_event.dart';
import '../../../patient/presentation/bloc/patient_state.dart';
import '../../../patient/presentation/pages/patient_detail_page.dart';
import 'add_rekam_medis_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPage extends StatefulWidget {
  final String title;
  const LaporanPage({super.key, this.title = 'Rekam Medis'});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _statusSearchController = TextEditingController();
  String _statusSearchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
    context.read<PatientBloc>().add(LoadPatientsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statusSearchController.dispose();
    super.dispose();
  }

  Future<void> _printSummaryReport(List<RekamMedisEntity> records) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('LAPORAN REKAM MEDIS - KLINIK KASIH IBU', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text(DateTime.now().toString().substring(0, 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Tanggal', 'Pasien', 'Dokter', 'Diagnosis', 'Keluhan'],
              data: List<List<dynamic>>.generate(records.length, (index) {
                final r = records[index];
                final dateStr = r.createdAt != null
                    ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}'
                    : '-';
                return [
                  (index + 1).toString(),
                  dateStr,
                  r.namaPasien ?? '-',
                  r.namaDokter ?? 'Umum',
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
                5: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    final isLaporan = widget.title.toLowerCase().contains('laporan');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPage,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          const BackButton(color: Colors.white),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                          ),
                          BlocBuilder<RekamMedisBloc, RekamMedisState>(
                            builder: (context, state) {
                              if (isLaporan && state is RekamMedisLoaded && state.records.isNotEmpty) {
                                return IconButton(
                                  icon: const Icon(Icons.print_rounded, color: Colors.white),
                                  onPressed: () => _printSummaryReport(state.records),
                                  tooltip: 'Cetak Laporan',
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(text: 'Riwayat Pemeriksaan'),
                        Tab(text: 'Status Pasien'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildRiwayatTab(isLaporan),
                  _buildStatusPasienTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: isLaporan ? null : FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRekamMedisPage()),
            ).then((_) {
              if (!mounted) return;
              this.context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
            });
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildRiwayatTab(bool isLaporan) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari diagnosis, nama pasien, atau dokter...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),

        // Records List
        Expanded(
          child: BlocBuilder<RekamMedisBloc, RekamMedisState>(
            builder: (context, state) {
              if (state is RekamMedisLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RekamMedisError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                );
              }

              if (state is RekamMedisLoaded) {
                final filtered = state.records.where((r) {
                  final diagMatch = r.diagnosis.toLowerCase().contains(_searchQuery);
                  final patientMatch = r.namaPasien?.toLowerCase().contains(_searchQuery) ?? false;
                  final docMatch = r.namaDokter?.toLowerCase().contains(_searchQuery) ?? false;
                  return diagMatch || patientMatch || docMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'Belum ada data pemeriksaan' : 'Hasil tidak ditemukan',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
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
                            'Pasien: ${r.namaPasien ?? '-'} • Tgl: $dateStr',
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
                                  _buildDetailRow('Dokter Pemeriksa', 'Dr. ${r.namaDokter ?? 'Umum'}'),
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
                                                      resep.aturanMinum + (resep.dosis != null && resep.dosis!.isNotEmpty ? ' - Dosis: ${resep.dosis}' : ''),
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
                                      if (!isLaporan)
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              final dummyPatient = PatientEntity(
                                                id: r.pasienId,
                                                namaLengkap: r.namaPasien ?? 'Pasien',
                                                tanggalLahir: DateTime.now(),
                                                jenisKelamin: '',
                                                nik: '',
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AddRekamMedisPage(
                                                    patient: dummyPatient,
                                                    record: r,
                                                  ),
                                                ),
                                              ).then((_) {
                                                if (!mounted) return;
                                                this.context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
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
                                      if (isLaporan)
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
    );
  }

  Widget _buildStatusPasienTab() {
    return Column(
      children: [
        // Search Bar for Status Pasien
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _statusSearchController,
            onChanged: (val) => setState(() => _statusSearchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari nama pasien atau NIK...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _statusSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () => setState(() {
                        _statusSearchController.clear();
                        _statusSearchQuery = '';
                      }),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: BlocBuilder<PatientBloc, PatientState>(
            builder: (context, patientState) {
              return BlocBuilder<RekamMedisBloc, RekamMedisState>(
                builder: (context, rmState) {
                  if (patientState is PatientLoading || rmState is RekamMedisLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (patientState is PatientLoaded && rmState is RekamMedisLoaded) {
                    final allPatients = patientState.patients;
                    final allRecords = rmState.records;

                    final patientIdsWithRecords = allRecords.map((e) => e.pasienId).toSet();

                    var sudahPeriksa = allPatients.where((p) => patientIdsWithRecords.contains(p.id)).toList();
                    var belumPeriksa = allPatients.where((p) => !patientIdsWithRecords.contains(p.id)).toList();
                    
                    if (_statusSearchQuery.isNotEmpty) {
                      sudahPeriksa = sudahPeriksa.where((p) => 
                        p.namaLengkap.toLowerCase().contains(_statusSearchQuery) || 
                        (p.nik?.contains(_statusSearchQuery) ?? false)
                      ).toList();
                      
                      belumPeriksa = belumPeriksa.where((p) => 
                        p.namaLengkap.toLowerCase().contains(_statusSearchQuery) || 
                        (p.nik?.contains(_statusSearchQuery) ?? false)
                      ).toList();
                    }

                    return ListView(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      children: [
                        _buildStatusSection('Sudah Melakukan Rekam Medis', sudahPeriksa, true),
                        const SizedBox(height: 24),
                        _buildStatusSection('Belum Melakukan Rekam Medis', belumPeriksa, false),
                        const SizedBox(height: 80),
                      ],
                    );
                  }

                  return const Center(child: Text('Gagal memuat data.'));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(String title, List<PatientEntity> patients, bool isSudah) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(isSudah ? Icons.check_circle_rounded : Icons.pending_actions_rounded, 
                color: isSudah ? Colors.green : Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelBold.copyWith(fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isSudah ? Colors.green : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${patients.length}',
                style: TextStyle(color: isSudah ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (patients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Text('Tidak ada pasien di kategori ini.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patients.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderColor),
              itemBuilder: (context, index) {
                final p = patients[index];
                return InkWell(
                  onTap: () {
                    final isLaporanMode = widget.title.toLowerCase().contains('laporan');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailPage(
                          patient: p,
                          isFromLaporan: isLaporanMode,
                        ),
                      ),
                    ).then((_) {
                      if (!mounted) return;
                      this.context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -3), // Menggeser teks ke atas sedikit
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.namaLengkap, style: AppTextStyles.labelBold.copyWith(fontSize: 13, height: 1.0)),
                                const SizedBox(height: 2),
                                Text('NIK: ${p.nik}', style: AppTextStyles.bodySmall.copyWith(fontSize: 11, height: 1.0)),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
