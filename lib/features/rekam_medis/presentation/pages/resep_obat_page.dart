import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ResepObatPage extends StatefulWidget {
  const ResepObatPage({super.key});

  @override
  State<ResepObatPage> createState() => _ResepObatPageState();
}

class _ResepObatPageState extends State<ResepObatPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _prescriptions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    try {
      final response = await _supabase
          .from('resep_obat')
          .select('*, obats(*), rekam_medis(*, pasiens(nama_lengkap))')
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _prescriptions = response as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _prescriptions.where((r) {
      final obatName = r['obats']?['nama_obat']?.toString().toLowerCase() ?? '';
      final patientName = r['rekam_medis']?['pasiens']?['nama_lengkap']?.toString().toLowerCase() ?? '';
      return obatName.contains(_searchQuery) || patientName.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Daftar Resep Obat', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
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
            child: Text(
              'Lacak resep obat yang telah diberikan ke pasien',
              style: AppTextStyles.headerSubtitle.copyWith(fontSize: 13),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari obat atau nama pasien...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text('Belum ada resep obat terdaftar', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchPrescriptions,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final r = filtered[index];
                            final patientName = r['rekam_medis']?['pasiens']?['nama_lengkap'] ?? '-';
                            final obatName = r['obats']?['nama_obat'] ?? 'Nama Obat';
                            final qty = r['jumlah_diberikan'] ?? 0;
                            final unit = r['obats']?['satuan'] ?? '';
                            final aturan = r['aturan_minum'] ?? '-';
                            final dateStr = r['created_at'] != null
                                ? DateTime.parse(r['created_at'] as String).toLocal().toString().substring(0, 10)
                                : '-';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt_rounded, color: Colors.amber, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          obatName,
                                          style: AppTextStyles.labelBold.copyWith(color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Pasien: $patientName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Text('Dosis: $aturan', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                                        Text('Tgl Resep: $dateStr', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$qty $unit',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
