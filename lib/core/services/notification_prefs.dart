import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  static const String keyNotifUmum = 'notif_umum';
  static const String keyNotifAutentikasi = 'notif_autentikasi';
  static const String keyNotifKeamanan = 'notif_keamanan';

  // ── Getters ──────────────────────────────────────────
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
}
