import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Android初期化設定
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS初期化設定
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      settings: initializationSettings,
    );

    // 権限リクエスト
    if (Platform.isAndroid) {
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  NotificationDetails _getDetails() {
    const androidDetails = AndroidNotificationDetails(
      'syshack_passly_channel', // チャンネルID
      'すれ違い通信', // チャンネル名
      channelDescription: 'バックグラウンドでのすれ違い検知や警告を通知します',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// バックグラウンドでの初回すれ違い検知時に呼ばれる
  Future<void> showStreetPassNotification() async {
    await initialize();
    debugPrint('[NotificationService] 🔔 すれ違いを検知しました！（バックグラウンド）');
    await _plugin.show(
      id: 0,
      title: 'すれ違いを検知しました！',
      body: '新しいすれ違いデータがあります。アプリを開いて確認してください。',
      notificationDetails: _getDetails(),
    );
  }

  /// オフライン用トークンが枯渇し、アドバタイズが継続できなくなった時に呼ばれる
  Future<void> showTokenExhaustedNotification() async {
    await initialize();
    debugPrint('[NotificationService] ⚠️ オフライン用トークンが枯渇しました。アプリを開いて継続してください。');
    await _plugin.show(
      id: 1,
      title: 'オフラインすれ違いの停止',
      body: 'トークンが枯渇したためアドバタイズを停止しました。アプリを開いて通信を再開してください。',
      notificationDetails: _getDetails(),
    );
  }
}
