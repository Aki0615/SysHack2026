import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/domain/auth_notifier.dart';
import '../encounter/data/encounter_repository.dart';
import 'ble_service.dart';

/// BLE状態を管理するプロバイダー
final bleNotifierProvider = NotifierProvider<BleNotifier, BleState>(
  BleNotifier.new,
);

/// BLEの状態
class BleState {
  final bool isScanning;
  final bool isAdvertising;
  final String? currentEphemeralId;
  final int confirmedEncounterCount;
  final String? lastError;

  const BleState({
    this.isScanning = false,
    this.isAdvertising = false,
    this.currentEphemeralId,
    this.confirmedEncounterCount = 0,
    this.lastError,
  });

  BleState copyWith({
    bool? isScanning,
    bool? isAdvertising,
    String? currentEphemeralId,
    int? confirmedEncounterCount,
    String? lastError,
  }) {
    return BleState(
      isScanning: isScanning ?? this.isScanning,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      currentEphemeralId: currentEphemeralId ?? this.currentEphemeralId,
      confirmedEncounterCount: confirmedEncounterCount ?? this.confirmedEncounterCount,
      lastError: lastError,
    );
  }
}

/// BLE機能を統合管理するNotifier
class BleNotifier extends Notifier<BleState> {
  late final BleService _bleService;
  EphemeralToken? _currentToken;

  @override
  BleState build() {
    _bleService = BleService();

    // Notifierが破棄される時にBLEサービスも停止
    ref.onDispose(() {
      _bleService.dispose();
    });

    return const BleState();
  }

  /// BLEすれ違い機能を開始（スキャン + アドバタイズ）
  Future<void> start() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      state = state.copyWith(lastError: 'ログインが必要です');
      return;
    }

    try {
      // 1. エフェメラルトークンを取得
      final encounterRepo = ref.read(encounterRepositoryProvider);
      _currentToken = await encounterRepo.getEphemeralToken(user.id);

      // 2. スキャンを開始
      _bleService.startScanning(
        onEncounterConfirmed: (ephemeralId) => _handleEncounterConfirmed(ephemeralId, user.id),
        onError: (error) {
          debugPrint('BLEスキャンエラー: $error');
          state = state.copyWith(lastError: error.toString());
        },
      );

      // 3. アドバタイズを開始（トークン自動更新あり）
      await _bleService.startAdvertising(
        ephemeralId: _currentToken!.token,
        refreshCallback: () => _refreshToken(user.id),
        refreshInterval: const Duration(minutes: 5),
      );

      state = state.copyWith(
        isScanning: true,
        isAdvertising: true,
        currentEphemeralId: _currentToken!.token,
        lastError: null,
      );

      debugPrint('BLEすれ違い機能を開始しました');
    } catch (e) {
      debugPrint('BLE開始エラー: $e');
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// BLEすれ違い機能を停止
  Future<void> stop() async {
    await _bleService.stopScanning();
    await _bleService.stopAdvertising();

    state = state.copyWith(
      isScanning: false,
      isAdvertising: false,
      currentEphemeralId: null,
    );

    debugPrint('BLEすれ違い機能を停止しました');
  }

  /// エフェメラルトークンを更新
  Future<String> _refreshToken(String userId) async {
    final encounterRepo = ref.read(encounterRepositoryProvider);
    _currentToken = await encounterRepo.getEphemeralToken(userId);

    state = state.copyWith(currentEphemeralId: _currentToken!.token);

    return _currentToken!.token;
  }

  /// すれ違い確定時の処理
  Future<void> _handleEncounterConfirmed(String ephemeralId, String myId) async {
    try {
      final encounterRepo = ref.read(encounterRepositoryProvider);

      // 1. エフェメラルIDから実ユーザーIDを解決
      final targetUserId = await encounterRepo.resolveEphemeralId(ephemeralId);

      // 2. すれ違いをサーバーに記録
      await encounterRepo.recordEncounter(
        myId: myId,
        targetId: targetUserId,
      );

      // 3. カウントを更新
      state = state.copyWith(
        confirmedEncounterCount: state.confirmedEncounterCount + 1,
      );

      debugPrint('すれ違いを記録しました: $targetUserId');
    } catch (e) {
      debugPrint('すれ違い記録エラー: $e');
      // エラーが発生しても継続（次回リトライのためバッファは保持しない設計）
    }
  }

  /// 現在のセッションですれ違った人数をリセット
  void resetEncounterCount() {
    state = state.copyWith(confirmedEncounterCount: 0);
  }
}
