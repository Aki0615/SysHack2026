import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

/// StreetPassアプリ専用のBLEサービスUUID
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

  DetectedDevice({
    required this.ephemeralId,
    required this.firstDetection,
  })  : detectionTimes = [firstDetection],
        isConfirmed = false;

  /// 新しい検知を記録
  void addDetection(DateTime time) {
    detectionTimes.add(time);
    // 5秒より古い検知は削除
    detectionTimes.removeWhere(
      (t) => time.difference(t) > _detectionWindow,
    );
  }

  /// すれ違い確定条件を満たしているか
  /// 条件: 5秒以内に3回以上検知
  bool meetsEncounterCriteria(DateTime now) {
    if (isConfirmed) return false; // 既に確定済み

    // 5秒以内の検知回数をカウント
    final recentCount = detectionTimes.where(
      (t) => now.difference(t) <= _detectionWindow,
    ).length;

    return recentCount >= _requiredDetectionCount;
  }
}

/// BLEのスキャンとアドバタイズを担当するサービスクラス
class BleService {
  // --- スキャン関連 ---
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isScanning = false;

  // --- アドバタイズ関連 ---
  bool _isAdvertising = false;
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
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

    // 既にスキャン中であれば一度停止
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    // バッファクリーンアップタイマーを開始
    _startCleanupTimer();

    // StreetPassのサービスUUIDを持つデバイスのみをスキャン
    FlutterBluePlus.startScan(
      withServices: [Guid(streetPassServiceUuid)],
      timeout: const Duration(hours: 24), // 長時間スキャン
      androidUsesFineLocation: true,
    );

    // スキャン結果をリッスン
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        final now = DateTime.now();
        for (final result in results) {
          _processDetection(result, now);
        }
      },
      onError: (error) {
        debugPrint('BLEスキャンエラー: $error');
        onError(error);
      },
    );

    debugPrint('BLEスキャンを開始しました');
  }

  /// 検知結果を処理
  void _processDetection(ScanResult result, DateTime now) {
    final ephemeralId = _extractEphemeralId(result);
    if (ephemeralId == null) return;

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

  /// ScanResultからエフェメラルIDを抽出
  String? _extractEphemeralId(ScanResult result) {
    // アドバタイズ名 / プラットフォーム名 の順で確認する
    // フォーマット: "SP_{ephemeralId}"
    final advertisedName = result.advertisementData.advName;
    if (advertisedName.startsWith('SP_')) {
      return advertisedName.substring(3);
    }

    final platformName = result.device.platformName;
    if (platformName.startsWith('SP_')) {
      return platformName.substring(3);
    }

    return null;
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
    await FlutterBluePlus.stopScan();
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
      // アドバタイズがサポートされているか確認
      final isSupported = await _blePeripheral.isSupported;
      if (!isSupported) {
        debugPrint('このデバイスはBLEアドバタイズをサポートしていません');
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
    // エフェメラルIDをデバイス名に埋め込む（SP_プレフィックス付き）
    // BLEの制限: ローカル名は最大20バイト程度
    final localName = 'SP_$ephemeralId';
    final truncatedName = localName.length > 20
        ? localName.substring(0, 20)
        : localName;

    final advertiseData = AdvertiseData(
      serviceUuid: streetPassServiceUuid,
      localName: truncatedName,
      includePowerLevel: false,
    );

    final advertiseSettings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeBalanced,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
      connectable: false,
      timeout: 0, // 無制限
    );

    await _blePeripheral.start(
      advertiseData: advertiseData,
      advertiseSettings: advertiseSettings,
    );
  }

  /// アドバタイズ中のIDを更新
  Future<void> _updateAdvertisingId(String newEphemeralId) async {
    if (!_isAdvertising) return;

    await _blePeripheral.stop();
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
      await _blePeripheral.stop();
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
