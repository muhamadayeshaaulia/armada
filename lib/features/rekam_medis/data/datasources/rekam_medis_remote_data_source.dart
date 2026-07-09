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
    print('DEBUG: addRekamMedis started');
    final data = record.toJson();
    data.remove('id');

    // 1. Insert rekam_medis
    final recordResponse = await supabaseClient
        .from('rekam_medis')
        .insert(data)
        .select('id')
        .single();
    
    final rekamMedisId = recordResponse['id'] as String;
    print('DEBUG: Inserted rekam_medis ID: $rekamMedisId');

    // 2. Insert resep_obat dan update stok obat
    if (resepList.isNotEmpty) {
      print('DEBUG: Inserting ${resepList.length} prescriptions');
      final resepData = resepList.map((resep) => {
        'rekam_medis_id': rekamMedisId,
        'obat_id': resep.obatId,
        'aturan_minum': resep.aturanMinum,
        'jumlah_diberikan': resep.jumlahDiberikan,
      }).toList();

      await supabaseClient.from('resep_obat').insert(resepData);

      // Kurangi stok untuk masing-masing obat
      for (var resep in resepList) {
        try {
          final obatRes = await supabaseClient
              .from('obats')
              .select('stok')
              .eq('id', resep.obatId)
              .single();

          final currentStok = int.tryParse(obatRes['stok']?.toString() ?? '0') ?? 0;
          final newStok = currentStok - resep.jumlahDiberikan;
          print('DEBUG: Medicine ID ${resep.obatId} - Current stock: $currentStok, Deducting: ${resep.jumlahDiberikan}, New stock: $newStok');

          final updateRes = await supabaseClient
              .from('obats')
              .update({'stok': newStok >= 0 ? newStok : 0})
              .eq('id', resep.obatId)
              .select();
          print('DEBUG: Stock update query executed successfully. Result: $updateRes');
        } catch (e) {
          print('DEBUG: Error updating stock in addRekamMedis for medicine ${resep.obatId}: $e');
          rethrow;
        }
      }
    }
    print('DEBUG: addRekamMedis completed successfully');
  }

  @override
  Future<void> updateRekamMedis(RekamMedisModel record, List<ResepObatModel> resepList) async {
    print('DEBUG: updateRekamMedis started for record ID: ${record.id}');

    // 1. Ambil resep lama untuk dikembalikan stoknya
    final oldResepRes = await supabaseClient
        .from('resep_obat')
        .select('obat_id, jumlah_diberikan')
        .eq('rekam_medis_id', record.id);

    final oldReseps = oldResepRes as List<dynamic>;
    print('DEBUG: Found ${oldReseps.length} old prescriptions to revert');

    // 2. Kembalikan stok obat lama
    for (var old in oldReseps) {
      final oldObatId = old['obat_id']?.toString();
      final oldQty = int.tryParse(old['jumlah_diberikan']?.toString() ?? '0') ?? 0;

      if (oldObatId != null && oldQty > 0) {
        try {
          final obatRes = await supabaseClient
              .from('obats')
              .select('stok')
              .eq('id', oldObatId)
              .single();
          
          final currentStok = int.tryParse(obatRes['stok']?.toString() ?? '0') ?? 0;
          final updateRes = await supabaseClient
              .from('obats')
              .update({'stok': currentStok + oldQty})
              .eq('id', oldObatId)
              .select();
          print('DEBUG: Reverted stock result: $updateRes');
        } catch (e) {
          print('DEBUG: Error reverting stock for medicine $oldObatId: $e');
          rethrow;
        }
      }
    }

    // 3. Hapus resep lama
    print('DEBUG: Deleting old prescriptions from resep_obat for rekam_medis_id: ${record.id}');
    final deleteRes = await supabaseClient
        .from('resep_obat')
        .delete()
        .eq('rekam_medis_id', record.id)
        .select();
    print('DEBUG: Deleted prescriptions result: $deleteRes');

    // 4. Update rekam_medis
    print('DEBUG: Updating rekam_medis table');
    final data = record.toJson();
    data.remove('created_at'); // Jangan update created_at
    final updateRMRes = await supabaseClient
        .from('rekam_medis')
        .update(data)
        .eq('id', record.id)
        .select();
    print('DEBUG: Updated rekam_medis result: $updateRMRes');

    // 5. Masukkan resep baru dan kurangi stok obat baru
    if (resepList.isNotEmpty) {
      print('DEBUG: Inserting ${resepList.length} new prescriptions');
      final resepData = resepList.map((resep) => {
        'rekam_medis_id': record.id,
        'obat_id': resep.obatId,
        'aturan_minum': resep.aturanMinum,
        'jumlah_diberikan': resep.jumlahDiberikan,
      }).toList();

      await supabaseClient.from('resep_obat').insert(resepData);

      // Kurangi stok untuk masing-masing obat baru
      for (var resep in resepList) {
        try {
          final obatRes = await supabaseClient
              .from('obats')
              .select('stok')
              .eq('id', resep.obatId)
              .single();
          
          final currentStok = int.tryParse(obatRes['stok']?.toString() ?? '0') ?? 0;
          final newStok = currentStok - resep.jumlahDiberikan;

          final updateRes = await supabaseClient
              .from('obats')
              .update({'stok': newStok >= 0 ? newStok : 0})
              .eq('id', resep.obatId)
              .select();
          print('DEBUG: Deducted stock result: $updateRes');
        } catch (e) {
          print('DEBUG: Error deducting stock for medicine ${resep.obatId}: $e');
          rethrow;
        }
      }
    }
    print('DEBUG: updateRekamMedis completed successfully');
  }
}
