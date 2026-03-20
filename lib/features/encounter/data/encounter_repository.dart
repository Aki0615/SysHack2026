import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/encounter_model.dart';

/// すれ違いAPI通信リポジトリのプロバイダー
final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepository(ref.read(dioProvider));
});

/// すれ違い通信のAPI通信を担当するリポジトリ
class EncounterRepository {
  final Dio _dio;

  EncounterRepository(this._dio);

  /// すれ違い記録をサーバーに送信する（POST /encounters）
  Future<EncounterModel> postEncounter({
    required String encounteredUserId,
    String? eventId,
  }) async {
    try {
      final response = await _dio.post(
        '/encounters',
        data: {
          'encountered_user_id': encounteredUserId,
          // ignore: use_null_aware_elements
          if (eventId != null) 'event_id': eventId,
        },
      );
      return EncounterModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('すれ違い記録の送信に失敗しました: ${e.message}');
    }
  }

  /// 未確認のすれ違いデータを取得する（GET /encounters/pending）
  Future<List<EncounterModel>> getPendingEncounters() async {
    try {
      final response = await _dio.get('/encounters/pending');
      final list = response.data as List;
      return list.map((e) => EncounterModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('未確認データの取得に失敗しました: ${e.message}');
    }
  }

  /// すれ違いデータを確認済みにする（PATCH /encounters/confirm）
  Future<int> confirmEncounters(List<String> encounterIds) async {
    try {
      final response = await _dio.patch(
        '/encounters/confirm',
        data: {'encounter_ids': encounterIds},
      );
      return response.data['updated_count'] as int;
    } on DioException catch (e) {
      throw Exception('すれ違いデータの確認に失敗しました: ${e.message}');
    }
  }

  /// 今日のすれ違い件数を取得する（GET /encounters/me/today）
  Future<int> getTodayCount() async {
    try {
      final response = await _dio.get('/encounters/me/today');
      return response.data['count'] as int;
    } on DioException catch (e) {
      throw Exception('今日のすれ違い件数の取得に失敗しました: ${e.message}');
    }
  }
}
