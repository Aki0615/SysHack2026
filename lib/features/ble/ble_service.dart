import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// StreetPassアプリ専用のBLEサービスUUID
/// 実際の運用時はユニークなUUIDを生成して使用すること
const String streetPassServiceUuid = '12345678-1234-1234-1234-123456789abc';

/// BLEのスキャンとアドバタイズを担当するサービスクラス
class BleService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isScanning = false;

  /// 現在スキャン中かどうか
  bool get isScanning => _isScanning;

  /// BLEスキャンを開始し、検知したデバイスのユーザーIDをコールバックで返す
  /// [onUserDetected] にはすれ違ったユーザーのIDが渡される
  void startScanning({
    required void Function(String userId) onUserDetected,
    required void Function(Object error) onError,
  }) {
    if (_isScanning) return;
    _isScanning = true;

    // 既にスキャン中であれば一度停止する
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    // StreetPassのサービスUUIDを持つデバイスのみをスキャン
    FlutterBluePlus.startScan(
      withServices: [Guid(streetPassServiceUuid)],
      timeout: const Duration(seconds: 30),
      androidUsesFineLocation: true,
    );

    // スキャン結果をリッスンする
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        for (final result in results) {
          // デバイス名にユーザーIDを埋め込む設計（アドバタイズデータから取得）
          final userId = _extractUserId(result);
          if (userId != null) {
            onUserDetected(userId);
          }
        }
      },
      onError: (error) {
        debugPrint('BLEスキャンエラー: $error');
        onError(error);
      },
    );

    debugPrint('BLEスキャンを開始しました');
  }

  /// スキャンを停止する
  Future<void> stopScanning() async {
    _isScanning = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await FlutterBluePlus.stopScan();
    debugPrint('BLEスキャンを停止しました');
  }

  /// BLEアドバタイズを開始する（自分のユーザーIDを発信する）
  /// ※ iOSではバックグラウンド時の制約あり
  /// ※ 実装は flutter_ble_peripheral パッケージ等を使用する想定
  Future<void> startAdvertising(String userId) async {
    // TODO: flutter_ble_peripheral などでアドバタイズを実装
    debugPrint('BLEアドバタイズ開始: userId=$userId');
  }

  /// アドバタイズを停止する
  Future<void> stopAdvertising() async {
    // TODO: アドバタイズ停止処理
    debugPrint('BLEアドバタイズ停止');
  }

  /// ScanResultからユーザーIDを抽出する
  /// 実際のアプリではServiceDataやManufacturerDataにユーザーIDを埋め込む
  String? _extractUserId(ScanResult result) {
    // デバイスのローカル名からユーザーIDを取得する簡易実装
    // フォーマット: "SP_{userId}" （例: "SP_abc123"）
    final name = result.device.platformName;
    if (name.startsWith('SP_')) {
      return name.substring(3);
    }
    return null;
  }

  /// リソースを解放する
  Future<void> dispose() async {
    await stopScanning();
    await stopAdvertising();
  }
}
