import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/encounter/domain/encounter_notifier.dart';
import 'package:syshack2026/features/encounter/data/encounter_repository.dart';
import 'package:syshack2026/features/ble/ble_service.dart';

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
  final List<String> newlyUnlockedAchievementTitles;
  final String? lastError;

  const BleState({
    this.isScanning = false,
    this.isAdvertising = false,
    this.currentEphemeralId,
    this.confirmedEncounterCount = 0,
    this.newlyUnlockedAchievementTitles = const [],
    this.lastError,
  });

  BleState copyWith({
    bool? isScanning,
    bool? isAdvertising,
    String? currentEphemeralId,
    int? confirmedEncounterCount,
    List<String>? newlyUnlockedAchievementTitles,
    String? lastError,
  }) {
    return BleState(
      isScanning: isScanning ?? this.isScanning,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      currentEphemeralId: currentEphemeralId ?? this.currentEphemeralId,
      confirmedEncounterCount:
          confirmedEncounterCount ?? this.confirmedEncounterCount,
      newlyUnlockedAchievementTitles:
          newlyUnlockedAchievementTitles ?? this.newlyUnlockedAchievementTitles,
      lastError: lastError,
    );
  }
}

/// BLE機能を統合管理するNotifier
class BleNotifier extends Notifier<BleState> {
  late final BleService _bleService;
  EphemeralToken? _currentToken;
  String? _activeUserId;
  Set<String> _knownUnlockedAchievementIds = <String>{};

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

    // ログインユーザーが切り替わっている場合は古いBLEセッションを停止して再初期化する
    if ((_activeUserId != null && _activeUserId != user.id) ||
        state.isScanning ||
        state.isAdvertising) {
      await stop();
    }

    try {
      // 1. エフェメラルトークンを取得
      final encounterRepo = ref.read(encounterRepositoryProvider);
      _currentToken = await encounterRepo.getEphemeralToken(user.id);
      _activeUserId = user.id;

      await _initializeAchievementBaseline(user.id, encounterRepo);

      // 2. スキャンを開始
      _bleService.startScanning(
        onEncounterConfirmed: _handleEncounterConfirmed,
        onError: (error) {
          debugPrint('BLEスキャンエラー: $error');
          state = state.copyWith(lastError: error.toString());
        },
      );

      // 3. アドバタイズを開始
      await _bleService.startAdvertising(
        ephemeralId: _currentToken!.token,
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
    _activeUserId = null;
    _knownUnlockedAchievementIds = <String>{};

    state = state.copyWith(
      isScanning: false,
      isAdvertising: false,
      currentEphemeralId: null,
      newlyUnlockedAchievementTitles: const [],
    );

    debugPrint('BLEすれ違い機能を停止しました');
  }


  /// iOSバックグラウンド移行時のアドバタイズ一時停止
  Future<void> pauseAdvertising() async {
    if (!state.isAdvertising) return;
    await _bleService.stopAdvertising();
    state = state.copyWith(isAdvertising: false);
    debugPrint('BLEアドバタイズを一時停止しました（iOSバックグラウンド）');
  }

  /// iOSフォアグラウンド復帰時のアドバタイズ再開
  Future<void> resumeAdvertising() async {
    if (state.isAdvertising || _activeUserId == null) return;
    try {
      final encounterRepo = ref.read(encounterRepositoryProvider);
      _currentToken = await encounterRepo.getEphemeralToken(_activeUserId!);
      await _bleService.startAdvertising(
        ephemeralId: _currentToken!.token,
      );
      state = state.copyWith(
        isAdvertising: true,
        currentEphemeralId: _currentToken!.token,
      );
      debugPrint('BLEアドバタイズを再開しました（iOSフォアグラウンド復帰）');
    } catch (e) {
      debugPrint('BLEアドバタイズ再開エラー: $e');
    }
  }

  /// すれ違い確定時の処理
  Future<void> _handleEncounterConfirmed(String ephemeralId) async {
    // TODO(Future Work): オフライン完全対応のための改修
    // 現状はすれ違った瞬間に即時バックエンドAPIを叩いて解決しているが、
    // 今後はここで PendingEncounterRepository に「ephemeralId(TOTP)」と「現在のUTCタイムスタンプ」を
    // ローカル保存（バッファリング）し、通信回復時にバックグラウンドで同期する仕組みに変更する。
    try {
      final myId = ref.read(authNotifierProvider).value?.id;
      if (myId == null) {
        debugPrint('すれ違い記録をスキップ: ログインユーザーが見つかりません');
        return;
      }

      final encounterRepo = ref.read(encounterRepositoryProvider);

      // 1. 受信したエフェメラルトークンをそのままサーバーへ渡して記録
      final recordResult = await encounterRepo.recordEncounter(
        myId: myId,
        targetToken: ephemeralId,
      );

      if (!recordResult.created) {
        debugPrint(
          'すれ違いは新規保存されませんでした: ${recordResult.message ?? 'no message'}',
        );
        // もう一方の端末が先に保存した場合は200が返るため、既存の未確認結果を取得する。
        await ref.read(encounterNotifierProvider.notifier).refresh();
        return;
      }

      // 2. すれ違い画面遷移トリガーのみ更新
      // 起動中のホーム人数は固定にしたいので、Homeの即時更新は行わない
      state = state.copyWith(
        confirmedEncounterCount: state.confirmedEncounterCount + 1,
      );

      await _detectNewlyUnlockedAchievements(myId, encounterRepo);

      await ref.read(encounterNotifierProvider.notifier).refresh();

      // [Phase 4] バックグラウンド動作時のローカル通知（モック）
      // TODO: flutter_local_notifications を導入して実際の通知を鳴らす
      final isBackground = WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
      if (isBackground) {
        debugPrint('🔔 [Local Notification] 新しいすれ違いが発生しました！ (バックグラウンド検知)');
      }

      debugPrint('すれ違いを記録しました: token=$ephemeralId');
    } catch (e) {
      debugPrint('すれ違い記録エラー: $e');
      state = state.copyWith(lastError: e.toString());
      // エラーが発生しても継続（次回リトライのためバッファは保持しない設計）
    }
  }

  /// 現在のセッションですれ違った人数をリセット
  void resetEncounterCount() {
    state = state.copyWith(
      confirmedEncounterCount: 0,
      newlyUnlockedAchievementTitles: const [],
    );
  }

  void consumeUnlockedAchievementNotifications() {
    if (state.newlyUnlockedAchievementTitles.isEmpty) return;
    state = state.copyWith(newlyUnlockedAchievementTitles: const []);
  }

  Future<void> _initializeAchievementBaseline(
    String userId,
    EncounterRepository repo,
  ) async {
    try {
      final unlocked = await repo.fetchUnlockedAchievements(userId);
      _knownUnlockedAchievementIds = unlocked.map((e) => e.id).toSet();
    } catch (e) {
      debugPrint('実績ベースライン初期化に失敗: $e');
    }
  }

  Future<void> _detectNewlyUnlockedAchievements(
    String userId,
    EncounterRepository repo,
  ) async {
    try {
      final unlocked = await repo.fetchUnlockedAchievements(userId);
      final newlyUnlocked = unlocked
          .where((a) => !_knownUnlockedAchievementIds.contains(a.id))
          .toList();

      _knownUnlockedAchievementIds = unlocked.map((e) => e.id).toSet();

      if (newlyUnlocked.isEmpty) return;

      state = state.copyWith(
        newlyUnlockedAchievementTitles: newlyUnlocked
            .map((a) => a.title)
            .toList(),
      );
    } catch (e) {
      debugPrint('新規実績の検知に失敗: $e');
    }
  }
}
