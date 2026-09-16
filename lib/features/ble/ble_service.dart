import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Passlyアプリ専用のBLEサービスUUID
const String streetPassServiceUuid = '12345678-1234-1234-1234-123456789abc';

/// すれ違い確定の条件
const int _requiredDetectionCount = 1; // 1回検知で確定（端末差による取りこぼし対策）
const Duration _detectionWindow = Duration(seconds: 5); // 検知ウィンドウ
const Duration _cleanupInterval = Duration(seconds: 10); // バッファクリーンアップ間隔

/// 検知デバイスの情報を保持するクラス
class DetectedDevice {
  final String ephemeralId;
  final List<DateTime> detectionTimes;
  DateTime firstDetection;

  bool isConfirmed;

  DetectedDevice({required this.ephemeralId, required this.firstDetection})
    : detectionTimes = [firstDetection],
      isConfirmed = false;

  /// 新しい検知を記録
  void addDetection(DateTime time) {
    detectionTimes.add(time);
    // 5秒より古い検知は削除
    detectionTimes.removeWhere((t) => time.difference(t) > _detectionWindow);
  }

  /// すれ違い確定条件を満たしているか
  /// 条件: 5秒以内に3回以上検知
  bool meetsEncounterCriteria(DateTime now) {
    if (isConfirmed) return false; // 既に確定済み

    // 5秒以内の検知回数をカウント
    final recentCount = detectionTimes
        .where((t) => now.difference(t) <= _detectionWindow)
        .length;

    return recentCount >= _requiredDetectionCount;
  }
}

/// BLEのスキャンとアドバタイズを担当するサービスクラス
///
/// 2026-09-15: すれ違いが一切検知されない不具合の調査の結果、
/// 従来使用していた flutter_blue_plus / flutter_ble_peripheral パッケージ経由の実装は
/// 廃止し、ネイティブ実装(BleScanManager.kt / BleAdvertiseManager.kt)を
/// MethodChannel("syshack/ble") / EventChannel("syshack/ble/scan_results") 経由で
/// 呼び出す方式に切り替えた。外部クラス(BleNotifier等)から見える公開APIは変更していない。
class BleService {
  static const MethodChannel _channel = MethodChannel('syshack/ble');
  static const EventChannel _eventChannel = EventChannel(
    'syshack/ble/scan_results',
  );

  // --- スキャン関連 ---
  StreamSubscription<dynamic>? _scanSubscription;
  bool _isScanning = false;

  // --- アドバタイズ関連 ---
  bool _isAdvertising = false;
  String? _currentEphemeralId;
  Timer? _tokenRefreshTimer;

  // --- 検知バッファ ---
  final Map<String, DetectedDevice> _detectionBuffer = {};
  Timer? _cleanupTimer;

  // --- コールバック ---
  void Function(String ephemeralId)? _onEncounterConfirmed;

  /// 現在スキャン中かどうか
  bool get isScanning => _isScanning;

  /// 現在アドバタイズ中かどうか
  bool get isAdvertising => _isAdvertising;

  /// 現在のエフェメラルID
  String? get currentEphemeralId => _currentEphemeralId;

  // ═══════════════════════════════════════════════════════
  //  スキャン（受信）処理
  // ═══════════════════════════════════════════════════════

  /// BLEスキャンを開始し、すれ違い確定時にコールバックを呼ぶ
  void startScanning({
    required void Function(String ephemeralId) onEncounterConfirmed,
    required void Function(Object error) onError,
  }) {
    if (_isScanning) return;
    _isScanning = true;
    _onEncounterConfirmed = onEncounterConfirmed;

    // バッファクリーンアップタイマーを開始
    _startCleanupTimer();

    // ネイティブ側(BleScanManager)にスキャン開始を依頼
    // PasslyのサービスUUIDでフィルタしたスキャンを行う
    _channel
        .invokeMethod('startScanning', {'serviceUuid': streetPassServiceUuid})
        .catchError((Object error) {
          debugPrint('BLEスキャン開始エラー: $error');
          onError(error);
        });

    // ネイティブ側からの検知イベントをリッスン
    // EventChannelのペイロード: {ephemeralId, rssi, timestampMs}
    _scanSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is! Map) return;
        final ephemeralId = event['ephemeralId'] as String?;
        if (ephemeralId == null) return;
        _processDetection(ephemeralId, DateTime.now());
      },
      onError: (Object error) {
        debugPrint('BLEスキャンエラー: $error');
        onError(error);
      },
    );

    debugPrint('BLEスキャンを開始しました');
  }

  /// 検知結果を処理
  void _processDetection(String ephemeralId, DateTime now) {
    // 自分自身のIDは無視
    if (ephemeralId == _currentEphemeralId) return;

    // バッファに追加または更新
    if (_detectionBuffer.containsKey(ephemeralId)) {
      final device = _detectionBuffer[ephemeralId]!;
      device.addDetection(now);

      // すれ違い確定条件をチェック
      if (device.meetsEncounterCriteria(now)) {
        device.isConfirmed = true;
        debugPrint('すれ違い確定: $ephemeralId');
        _onEncounterConfirmed?.call(ephemeralId);
      }
    } else {
      // 新規検知
      final device = DetectedDevice(
        ephemeralId: ephemeralId,
        firstDetection: now,
      );
      _detectionBuffer[ephemeralId] = device;
      debugPrint('新規デバイス検知: $ephemeralId');

      // required countが1の場合、新規検知時点で確定させる
      if (device.meetsEncounterCriteria(now)) {
        device.isConfirmed = true;
        debugPrint('すれ違い確定: $ephemeralId');
        _onEncounterConfirmed?.call(ephemeralId);
      }
    }
  }

  /// 古い検知データをクリーンアップするタイマーを開始
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      final now = DateTime.now();
      _detectionBuffer.removeWhere((id, device) {
        // 確定済み、または最後の検知から30秒以上経過したデバイスを削除
        if (device.isConfirmed) return true;
        if (device.detectionTimes.isEmpty) return true;
        final lastDetection = device.detectionTimes.last;
        return now.difference(lastDetection) > const Duration(seconds: 30);
      });
    });
  }

  /// スキャンを停止する
  Future<void> stopScanning() async {
    _isScanning = false;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await _channel.invokeMethod('stopScanning');
    } catch (e) {
      debugPrint('BLEスキャン停止エラー: $e');
    }
    _detectionBuffer.clear();
    debugPrint('BLEスキャンを停止しました');
  }

  // ═══════════════════════════════════════════════════════
  //  アドバタイズ（発信）処理
  // ═══════════════════════════════════════════════════════

  /// BLEアドバタイズを開始する（エフェメラルIDを発信）
  /// [ephemeralId] サーバーから取得した短期トークン
  /// [refreshCallback] トークン更新時に新しいトークンを取得するコールバック
  Future<void> startAdvertising({
    required String ephemeralId,
    Future<String> Function()? refreshCallback,
    Duration refreshInterval = const Duration(minutes: 5),
  }) async {
    if (_isAdvertising) {
      debugPrint('既にアドバタイズ中です');
      return;
    }

    try {
      // Bluetoothが有効か確認
      final isEnabled =
          await _channel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
      if (!isEnabled) {
        debugPrint('Bluetoothが無効なため、アドバタイズを開始できません');
        return;
      }

      _currentEphemeralId = ephemeralId;
      await _startAdvertisingWithId(ephemeralId);
      _isAdvertising = true;

      // トークン更新タイマーを設定
      if (refreshCallback != null) {
        _tokenRefreshTimer?.cancel();
        _tokenRefreshTimer = Timer.periodic(refreshInterval, (_) async {
          try {
            final newToken = await refreshCallback();
            await _updateAdvertisingId(newToken);
          } catch (e) {
            debugPrint('トークン更新エラー: $e');
          }
        });
      }

      debugPrint('BLEアドバタイズを開始しました: ephemeralId=$ephemeralId');
    } catch (e) {
      debugPrint('BLEアドバタイズ開始エラー: $e');
      _isAdvertising = false;
    }
  }

  /// 指定されたIDでアドバタイズを開始
  Future<void> _startAdvertisingWithId(String ephemeralId) async {
    // ネイティブ側(BleAdvertiseManager)がローカル名への
    // "SP_" プレフィックス付与・20文字への切り詰めを担当する
    await _channel.invokeMethod('startAdvertising', {
      'token': ephemeralId,
      'serviceUuid': streetPassServiceUuid,
    });
  }

  /// アドバタイズ中のIDを更新
  Future<void> _updateAdvertisingId(String newEphemeralId) async {
    if (!_isAdvertising) return;

    await _channel.invokeMethod('stopAdvertising');
    _currentEphemeralId = newEphemeralId;
    await _startAdvertisingWithId(newEphemeralId);
    debugPrint('アドバタイズIDを更新しました: $newEphemeralId');
  }

  /// アドバタイズを停止する
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;
      await _channel.invokeMethod('stopAdvertising');
      _isAdvertising = false;
      _currentEphemeralId = null;
      debugPrint('BLEアドバタイズを停止しました');
    } catch (e) {
      debugPrint('BLEアドバタイズ停止エラー: $e');
    }
  }

  // ═══════════════════════════════════════════════════════
  //  リソース解放
  // ═══════════════════════════════════════════════════════

  /// リソースを解放する
  Future<void> dispose() async {
    await stopScanning();
    await stopAdvertising();
  }
}
