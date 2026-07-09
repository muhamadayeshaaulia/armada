import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class NotificationHistoryItem {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationHistoryItem({required this.title, required this.body, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
  };

  factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) => NotificationHistoryItem(
    title: json['title'],
    body: json['body'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Logika saat notifikasi ditekan
      },
    );
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'armada_channel_id',
      'Armada Notifications',
      channelDescription: 'Channel untuk notifikasi aplikasi Armada',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );

    await saveNotificationHistory(title, body);
  }

  static const String _historyKey = 'notification_history';
  
  Future<void> saveNotificationHistory(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    List<NotificationHistoryItem> history = [];
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      history = decoded.map((e) => NotificationHistoryItem.fromJson(e)).toList();
    }
    history.insert(0, NotificationHistoryItem(title: title, body: body, timestamp: DateTime.now()));

    // Keep only last 50 notifications
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await prefs.setString(_historyKey, jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  Future<List<NotificationHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((e) => NotificationHistoryItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
