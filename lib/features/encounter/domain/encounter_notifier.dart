import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_notifier.dart';
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
    return await _fetchPendingEncounters();
  }

  /// 現在のユーザーIDを取得する
  String? get _currentUserId =>
      ref.read(authNotifierProvider.notifier).currentUserId;

  /// 未確認のすれ違いデータをサーバーとローカルの両方から取得する
  Future<List<EncounterModel>> _fetchPendingEncounters() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final repo = ref.read(encounterRepositoryProvider);
      final pendingData = await repo.getPendingEncounters(userId);

      // Map → EncounterModel に変換
      final encounters = pendingData.map((data) {
        return EncounterModel(
          id: data['id']?.toString() ?? '',
          encounteredUser: EncounteredUserInfo(
            id: data['id']?.toString() ?? '',
            name: data['name']?.toString() ?? '???',
            iconUrl: data['icon_url']?.toString() ?? '',
            oneWord: data['one_word']?.toString() ?? '',
          ),
          encounteredAt:
              DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
          isConfirmed: data['is_confirmed'] ?? false,
        );
      }).toList();

      // ローカルにも保存
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();
      for (final encounter in encounters) {
        await localRepo.add(encounter);
      }

      return encounters;
    } catch (e) {
      debugPrint('サーバーから未確認データ取得失敗、ローカルを使用: $e');
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      return await localRepo.getPending();
    }
  }

  /// BLEですれ違いを検知した時に呼ばれる処理
  Future<void> onEncounterDetected(String targetUserId, {int? eventId}) async {
    final myId = _currentUserId;
    if (myId == null) return;

    final limitService = ref.read(dailyLimitServiceProvider);
    await limitService.resetIfNewDay();

    if (!await limitService.canEncounter()) {
      debugPrint('本日のすれ違い上限に達しています');
      return;
    }

    try {
      final repo = ref.read(encounterRepositoryProvider);
      await repo.postEncounter(
        myId: myId,
        targetId: targetUserId,
        eventId: eventId,
      );
      await limitService.increment();
      state = AsyncValue.data(await _fetchPendingEncounters());
    } catch (e) {
      debugPrint('すれ違い記録の保存に失敗: $e');
    }
  }

  /// 「確認した！」ボタンが押された時の処理
  Future<void> confirmAll() async {
    final currentList = state.value ?? [];
    if (currentList.isEmpty) return;

    try {
      final repo = ref.read(encounterRepositoryProvider);
      final ids = currentList.map((e) => e.id).toList();
      await repo.confirmEncounters(ids);

      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();

      state = const AsyncValue.data([]);
    } catch (e) {
      debugPrint('すれ違いデータの確認処理に失敗: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 未確認データが存在するか
  bool get hasPending => (state.value ?? []).isNotEmpty;
}
