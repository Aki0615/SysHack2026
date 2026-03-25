import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepository(ref.read(dioProvider));
});

/// すれ違い通信（BLE）のAPI通信を担当するリポジトリ
class EncounterRepository {
  final Dio _dio;

  EncounterRepository(this._dio);

  /// バックグラウンドですれ違った相手のIDを送信する（POST /encounters）
  /// ※レスポンス仕様がないため、通信を行うのみでレスポンスボディのパースは行わない
  Future<void> recordEncounter({
    required String myId,
    required String targetId,
  }) async {
    await _dio.post(
      '/encounters',
      data: {"my_id": myId, "target_id": targetId},
      options: Options(contentType: 'application/json'),
    );
  }
}
