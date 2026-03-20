import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/encounter_repository.dart';
import '../data/pending_encounter_repository.dart';
import '../domain/encounter_model.dart';
import 'daily_limit_service.dart';

/// 未確認すれ違いデータの状態を管理するプロバイダー
final encounterNotifierProvider =
    AsyncNotifierProvider<EncounterNotifier, List<EncounterModel>>(
      EncounterNotifier.new,
    );

/// すれ違いデータの取得・確認・BLE検知後の処理を管理するNotifier
class EncounterNotifier extends AsyncNotifier<List<EncounterModel>> {
  @override
  FutureOr<List<EncounterModel>> build() async {
    // アプリ起動時に未確認のすれ違いデータを取得する
    return await _fetchPendingEncounters();
  }

  /// 未確認のすれ違いデータをサーバーとローカルの両方から取得する
  Future<List<EncounterModel>> _fetchPendingEncounters() async {
    try {
      final repo = ref.read(encounterRepositoryProvider);
      final serverPending = await repo.getPendingEncounters();

      // ローカルにも保存しておく（オフライン対応の基盤）
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();
      for (final encounter in serverPending) {
        await localRepo.add(encounter);
      }

      return serverPending;
    } catch (e) {
      // サーバー通信失敗時はローカルから読み込む（フォールバック）
      debugPrint('サーバーから未確認データ取得失敗、ローカルを使用: $e');
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      return await localRepo.getPending();
    }
  }

  /// BLEですれ違いを検知した時に呼ばれる処理
  Future<void> onEncounterDetected(
    String encounteredUserId, {
    String? eventId,
  }) async {
    final limitService = ref.read(dailyLimitServiceProvider);

    // ステップ1: 日付リセットチェック
    await limitService.resetIfNewDay();

    // ステップ2: 5人制限チェック
    if (!await limitService.canEncounter()) {
      debugPrint('本日のすれ違い上限に達しています');
      return;
    }

    try {
      // ステップ3: サーバーに記録を送信
      final repo = ref.read(encounterRepositoryProvider);
      final encounter = await repo.postEncounter(
        encounteredUserId: encounteredUserId,
        eventId: eventId,
      );

      // ステップ4: ローカルにも保存
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.add(encounter);

      // ステップ5: カウントを加算
      await limitService.increment();

      // 状態を更新（UIに反映）
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, encounter]);
    } catch (e) {
      debugPrint('すれ違い記録の保存に失敗: $e');
    }
  }

  /// 「確認した！」ボタンが押された時の処理
  Future<void> confirmAll() async {
    final currentList = state.value ?? [];
    if (currentList.isEmpty) return;

    try {
      // サーバーに確認済みを送信
      final repo = ref.read(encounterRepositoryProvider);
      final ids = currentList.map((e) => e.id).toList();
      await repo.confirmEncounters(ids);

      // ローカルデータもクリア
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();

      // 状態を空リストに更新
      state = const AsyncValue.data([]);
    } catch (e) {
      debugPrint('すれ違いデータの確認処理に失敗: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 未確認データが存在するか
  bool get hasPending => (state.value ?? []).isNotEmpty;
}
