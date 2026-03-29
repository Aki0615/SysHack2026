import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/domain/auth_notifier.dart';
import '../encounter/domain/encounter_notifier.dart';
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
      confirmedEncounterCount: confirmedEncounterCount ?? this.confirmedEncounterCount,
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

      // 3. アドバタイズを開始（トークン自動更新あり）
      await _bleService.startAdvertising(
        ephemeralId: _currentToken!.token,
        refreshCallback: _refreshTokenForCurrentUser,
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

  /// エフェメラルトークンを更新
  Future<String> _refreshToken(String userId) async {
    final encounterRepo = ref.read(encounterRepositoryProvider);
    _currentToken = await encounterRepo.getEphemeralToken(userId);

    state = state.copyWith(currentEphemeralId: _currentToken!.token);

    return _currentToken!.token;
  }

  Future<String> _refreshTokenForCurrentUser() async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) {
      throw Exception('ログインユーザーが見つかりません');
    }
    return _refreshToken(userId);
  }

  /// すれ違い確定時の処理
  Future<void> _handleEncounterConfirmed(String ephemeralId) async {
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
        debugPrint('すれ違いは新規保存されませんでした: ${recordResult.message ?? 'no message'}');
        // 起動中のホーム表示は固定したいので、この場ではUI再取得しない
        return;
      }

      // 2. すれ違い画面遷移トリガーのみ更新
      // 起動中のホーム人数は固定にしたいので、Homeの即時更新は行わない
      state = state.copyWith(
        confirmedEncounterCount: state.confirmedEncounterCount + 1,
      );

      await _detectNewlyUnlockedAchievements(myId, encounterRepo);

      // 起動中に新規すれ違いが発生したら、未確認データを更新して結果画面遷移を発火させる
      await ref.read(encounterNotifierProvider.notifier).refresh();

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
        newlyUnlockedAchievementTitles: newlyUnlocked.map((a) => a.title).toList(),
      );
    } catch (e) {
      debugPrint('新規実績の検知に失敗: $e');
    }
  }
}
