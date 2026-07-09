import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<void> addPatient(PatientModel patient);
  Future<void> updatePatient(PatientModel patient);
  Future<void> deletePatient(String id);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient supabaseClient;

  PatientRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PatientModel>> getPatients() async {
    final response = await supabaseClient
        .from('pasiens')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addPatient(PatientModel patient) async {
    final data = patient.toJson();
    data.remove('id'); // Supabase gen_random_uuid
    await supabaseClient.from('pasiens').insert(data);
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    final data = patient.toJson();
    data.remove('id');
    await supabaseClient
        .from('pasiens')
        .update(data)
        .eq('id', patient.id);
  }

  @override
  Future<void> deletePatient(String id) async {
    await supabaseClient
        .from('pasiens')
        .delete()
        .eq('id', id);
  }
}
