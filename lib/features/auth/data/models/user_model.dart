import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.role,
  });

  // Fungsi khusus untuk mengubah data Firebase User menjadi UserModel
  factory UserModel.fromFirebaseUser(firebase.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      role: 'dokter',
    );
  }
}