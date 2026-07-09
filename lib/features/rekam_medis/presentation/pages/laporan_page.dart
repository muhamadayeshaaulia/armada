import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/rekam_medis_bloc.dart';
import '../bloc/rekam_medis_event.dart';
import '../bloc/rekam_medis_state.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<RekamMedisBloc>().add(LoadRekamMedisEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Laporan Rekam Medis', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Riwayat Pemeriksaan Pasien', style: AppTextStyles.headerSubtitle),
              ],
            ),
          ),

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
                                    ]
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
