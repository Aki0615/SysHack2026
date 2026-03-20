import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

/// すれ違いAPI通信リポジトリのプロバイダー
final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepository(ref.read(dioProvider));
});

/// すれ違い通信のAPI通信を担当するリポジトリ
/// バックエンドの実際のAPIエンドポイントに合わせた実装
class EncounterRepository {
  final Dio _dio;

  EncounterRepository(this._dio);

  /// すれ違い記録をサーバーに送信する（POST /encounters）
  /// バックエンドは { my_id, target_id, event_id } を受け取る
  Future<Map<String, dynamic>> postEncounter({
    required String myId,
    required String targetId,
    int? eventId,
  }) async {
    try {
      final response = await _dio.post(
        '/encounters',
        data: {
          'my_id': myId,
          'target_id': targetId,
          // ignore: use_null_aware_elements
          if (eventId != null) 'event_id': eventId,
        },
      );
      // バックエンドは { id, is_confirmed } のみ返す
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('すれ違い記録の送信に失敗しました: ${e.message}');
    }
  }

  /// すれ違い履歴を取得する（GET /users/:id/encounters）
  /// バックエンドは JOINで相手のユーザー情報も含めた配列を返す
  Future<List<Map<String, dynamic>>> getEncounters(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/encounters');
      final list = response.data as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw Exception('すれ違い履歴の取得に失敗しました: ${e.message}');
    }
  }

  /// 未確認のすれ違いデータを取得する
  /// バックエンドに専用APIがないため、全履歴を取得して is_confirmed == false でフィルタ
  Future<List<Map<String, dynamic>>> getPendingEncounters(String userId) async {
    try {
      final allEncounters = await getEncounters(userId);
      return allEncounters.where((e) => e['is_confirmed'] == false).toList();
    } catch (e) {
      throw Exception('未確認データの取得に失敗しました: $e');
    }
  }

  /// すれ違いデータを確認済みにする
  /// TODO: バックエンドに PATCH /encounters/confirm が実装されたら正式対応
  /// 現在はフロントのローカルストレージのみで管理
  Future<void> confirmEncounters(List<String> encounterIds) async {
    // バックエンドに未実装のため、ローカルで管理する
    // 将来的にはここでAPI呼び出しを行う
  }

  /// 今日のすれ違い件数を取得する
  /// バックエンドに専用APIがないため、全履歴から今日の分をフィルタして数える
  Future<int> getTodayCount(String userId) async {
    try {
      final allEncounters = await getEncounters(userId);
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return allEncounters
          .where((e) => (e['created_at'] as String).startsWith(todayStr))
          .length;
    } catch (e) {
      return 0;
    }
  }
}
