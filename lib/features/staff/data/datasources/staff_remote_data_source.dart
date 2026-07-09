import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../firebase_options.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getAdmins();
  Future<List<StaffModel>> getDoctors();
  Future<void> updateStaff(StaffModel staff);
  Future<void> deleteStaff(String id, String role);
  Future<void> addStaff(StaffModel staff, String email, String password);
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

    print('=== UPDATE STAFF DEBUG ===');
    print('Table: $table');
    print('ID: ${staff.id}');
    print('Data: $data');

    try {
      final response = await supabaseClient
          .from(table)
          .update(data)
          .eq('id', staff.id)
          .select();

      print('Response: $response');
    } catch (e) {
      print('ERROR updateStaff: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteStaff(String id, String role) async {
    // Karena onDelete Cascade, menghapus dari tabel users akan otomatis
    // menghapus data di admins/dokters
    await supabaseClient.from('users').delete().eq('id', id);
  }

  @override
  Future<void> addStaff(StaffModel staff, String email, String password) async {
    // 1. Buat Firebase App sementara agar session pengguna saat ini tidak ter-logout
    final tempApp = await Firebase.initializeApp(
      name: 'TempApp_${DateTime.now().millisecondsSinceEpoch}',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // 2. Simpan ke Supabase tabel users
        await supabaseClient.from('users').insert({
          'id': user.uid,
          'email': email,
          'role': staff.role,
        });

        // 3. Simpan ke tabel admins atau dokters
        final table = staff.role == 'admin' ? 'admins' : 'dokters';
        final data = staff.toJson();
        data['id'] = user.uid; // Set ID dari Firebase UID
        
        await supabaseClient.from(table).insert(data);
      } else {
        throw Exception('Gagal membuat akun petugas.');
      }
    } finally {
      // Hapus app sementara
      await tempApp.delete();
    }
  }
}
