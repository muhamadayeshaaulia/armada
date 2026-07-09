import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getAdmins();
  Future<List<StaffModel>> getDoctors();
  Future<void> updateStaff(StaffModel staff);
  Future<void> deleteStaff(String id, String role);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final SupabaseClient supabaseClient;

  StaffRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StaffModel>> getAdmins() async {
    final response = await supabaseClient
        .from('admins')
        .select('*')
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => StaffModel.fromJson(json as Map<String, dynamic>, 'admin'))
        .toList();
  }

  @override
  Future<List<StaffModel>> getDoctors() async {
    final response = await supabaseClient
        .from('dokters')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => StaffModel.fromJson(json as Map<String, dynamic>, 'dokter'))
        .toList();
  }

  @override
  Future<void> updateStaff(StaffModel staff) async {
    final table = staff.role == 'admin' ? 'admins' : 'dokters';
    final data = staff.toJson();
    // Hapus id dari data update agar tidak menimpa primary key
    data.remove('id');
    
    await supabaseClient
        .from(table)
        .update(data)
        .eq('id', staff.id);
  }

  @override
  Future<void> deleteStaff(String id, String role) async {
    // Karena onDelete Cascade, menghapus dari tabel users akan otomatis
    // menghapus data di admins/dokters
    await supabaseClient.from('users').delete().eq('id', id);
  }
}
