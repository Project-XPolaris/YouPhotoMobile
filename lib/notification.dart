import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationPlugin {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  static final NotificationPlugin _singleton = NotificationPlugin._internal();

  factory NotificationPlugin() {
    return _singleton;
  }

  NotificationPlugin._internal() {
    init();
  }

  init() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        iOS: initializationSettingsDarwin,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    this.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
  }

  Future<void> showUploadNotification(
      String title, String body, int progress, int total) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('upload_channel_id', 'Upload Channel',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
            progress: progress,
            maxProgress: total,
            showProgress: true);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin!
        .show(0, title, body, platformChannelSpecifics);
  }

  Future<void> showDownloadNotification(
      String title, String body, int progress, int total) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel_id',
      'Download Channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      progress: progress,
      maxProgress: total,
      showProgress: true,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin!
        .show(1, title, body, platformChannelSpecifics);
  }
}
