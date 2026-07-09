import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<List<MedicineModel>> getMedicines();
  Future<void> addMedicine(MedicineModel medicine);
  Future<void> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final SupabaseClient supabaseClient;

  MedicineRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<MedicineModel>> getMedicines() async {
    final response = await supabaseClient
        .from('obats')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MedicineModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addMedicine(MedicineModel medicine) async {
    final data = medicine.toJson();
    data.remove('id'); // Supabase gen_random_uuid
    await supabaseClient.from('obats').insert(data);
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    final data = medicine.toJson();
    data.remove('id');
    await supabaseClient
        .from('obats')
        .update(data)
        .eq('id', medicine.id);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await supabaseClient
        .from('obats')
        .delete()
        .eq('id', id);
  }
}
