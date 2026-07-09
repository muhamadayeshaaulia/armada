import 'package:shared_preferences/shared_preferences.dart';

/// Kunci key yang dipakai untuk menyimpan preferensi notifikasi
class NotificationPrefs {
  static const String keyNotifLogin = 'notif_login';
  static const String keyNotifRegister = 'notif_register';

  static Future<bool> isLoginNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotifLogin) ?? true; // default: aktif
  }

  static Future<bool> isRegisterNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotifRegister) ?? true; // default: aktif
  }

  static Future<void> setLoginNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifLogin, value);
  }

  static Future<void> setRegisterNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifRegister, value);
  }
}
