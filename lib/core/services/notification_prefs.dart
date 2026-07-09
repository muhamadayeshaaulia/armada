import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  static const String keyNotifUmum = 'notif_umum';
  static const String keyNotifAutentikasi = 'notif_autentikasi';
  static const String keyNotifKeamanan = 'notif_keamanan';
  static const String keyBiometricEnabled = 'biometric_enabled';

  // ── Getters ──────────────────────────────────────────
  static Future<bool> isBiometricEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(keyBiometricEnabled) ?? false;

  static Future<bool> isUmumNotifEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(keyNotifUmum) ?? true;

  static Future<bool> isAutentikasiNotifEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(keyNotifAutentikasi) ?? true;

  static Future<bool> isKeamananNotifEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(keyNotifKeamanan) ?? true;

  // ── Setters ──────────────────────────────────────────
  static Future<void> setUmumNotif(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(keyNotifUmum, v);

  static Future<void> setAutentikasiNotif(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(keyNotifAutentikasi, v);

  static Future<void> setKeamananNotif(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(keyNotifKeamanan, v);

  static Future<void> setBiometricEnabled(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(keyBiometricEnabled, v);
}
