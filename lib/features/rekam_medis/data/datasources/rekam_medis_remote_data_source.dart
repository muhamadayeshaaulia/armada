import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rekam_medis_model.dart';

abstract class RekamMedisRemoteDataSource {
  Future<List<RekamMedisModel>> getRekamMedis();
  Future<List<RekamMedisModel>> getRekamMedisForPatient(String patientId);
  Future<void> addRekamMedis(RekamMedisModel record, List<ResepObatModel> resepList);
  Future<void> updateRekamMedis(RekamMedisModel record, List<ResepObatModel> resepList);
}

class RekamMedisRemoteDataSourceImpl implements RekamMedisRemoteDataSource {
  final SupabaseClient supabaseClient;

  RekamMedisRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<RekamMedisModel>> getRekamMedis() async {
    final response = await supabaseClient
        .from('rekam_medis')
        .select('*, pasiens(nama_lengkap), dokters(nama_lengkap), resep_obat(*, obats(*))')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RekamMedisModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RekamMedisModel>> getRekamMedisForPatient(String patientId) async {
    final response = await supabaseClient
        .from('rekam_medis')
        .select('*, pasiens(nama_lengkap), dokters(nama_lengkap), resep_obat(*, obats(*))')
        .eq('pasien_id', patientId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RekamMedisModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addRekamMedis(RekamMedisModel record, List<ResepObatModel> resepList) async {
    final data = record.toJson();
    data.remove('id');

    // 1. Insert rekam_medis
    final recordResponse = await supabaseClient
        .from('rekam_medis')
        .insert(data)
        .select('id')
        .single();
    
    final rekamMedisId = recordResponse['id'] as String;

    // 2. Insert resep_obat dan update stok obat
    if (resepList.isNotEmpty) {
      final resepData = resepList.map((resep) => {
        'rekam_medis_id': rekamMedisId,
        'obat_id': resep.obatId,
        'aturan_minum': resep.aturanMinum,
        'jumlah_diberikan': resep.jumlahDiberikan,
      }).toList();

      await supabaseClient.from('resep_obat').insert(resepData);

      // Kurangi stok untuk masing-masing obat
      for (var resep in resepList) {
        final obatRes = await supabaseClient
            .from('obats')
            .select('stok')
            .eq('id', resep.obatId)
            .single();
        
        final currentStok = obatRes['stok'] as int? ?? 0;
        final newStok = currentStok - resep.jumlahDiberikan;

        await supabaseClient
            .from('obats')
            .update({'stok': newStok >= 0 ? newStok : 0})
            .eq('id', resep.obatId);
      }
    }
  }

  @override
  Future<void> updateRekamMedis(RekamMedisModel record, List<ResepObatModel> resepList) async {
    // 1. Ambil resep lama untuk dikembalikan stoknya
    final oldResepRes = await supabaseClient
        .from('resep_obat')
        .select('obat_id, jumlah_diberikan')
        .eq('rekam_medis_id', record.id);

    final oldReseps = oldResepRes as List<dynamic>;

    // 2. Kembalikan stok obat lama
    for (var old in oldReseps) {
      final oldObatId = old['obat_id'] as String;
      final oldQty = old['jumlah_diberikan'] as int;

      final obatRes = await supabaseClient
          .from('obats')
          .select('stok')
          .eq('id', oldObatId)
          .single();
      
      final currentStok = obatRes['stok'] as int? ?? 0;
      await supabaseClient
          .from('obats')
          .update({'stok': currentStok + oldQty})
          .eq('id', oldObatId);
    }

    // 3. Hapus resep lama
    await supabaseClient
        .from('resep_obat')
        .delete()
        .eq('rekam_medis_id', record.id);

    // 4. Update rekam_medis
    final data = record.toJson();
    data.remove('created_at'); // Jangan update created_at
    await supabaseClient
        .from('rekam_medis')
        .update(data)
        .eq('id', record.id);

    // 5. Masukkan resep baru dan kurangi stok obat baru
    if (resepList.isNotEmpty) {
      final resepData = resepList.map((resep) => {
        'rekam_medis_id': record.id,
        'obat_id': resep.obatId,
        'aturan_minum': resep.aturanMinum,
        'jumlah_diberikan': resep.jumlahDiberikan,
      }).toList();

      await supabaseClient.from('resep_obat').insert(resepData);

      // Kurangi stok untuk masing-masing obat baru
      for (var resep in resepList) {
        final obatRes = await supabaseClient
            .from('obats')
            .select('stok')
            .eq('id', resep.obatId)
            .single();
        
        final currentStok = obatRes['stok'] as int? ?? 0;
        final newStok = currentStok - resep.jumlahDiberikan;

        await supabaseClient
            .from('obats')
            .update({'stok': newStok >= 0 ? newStok : 0})
            .eq('id', resep.obatId);
      }
    }
  }
}
