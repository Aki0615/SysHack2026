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

  /// エフェメラルID（短期トークン）を取得する（GET /users/:id/ephemeral-token）
  /// プライバシー保護のため、一定時間ごとに新しいトークンを取得してアドバタイズに使用
  Future<EphemeralToken> getEphemeralToken(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/ephemeral-token');
      return EphemeralToken.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('エフェメラルトークンの取得に失敗: ${e.message}');
    }
  }

  /// エフェメラルIDから実際のユーザーIDを解決する（POST /encounters/resolve）
  /// すれ違い確定時に相手のエフェメラルIDから実ユーザーIDを取得
  Future<String> resolveEphemeralId(String ephemeralId) async {
    try {
      final response = await _dio.post(
        '/encounters/resolve',
        data: {
          "token": ephemeralId,
          "ephemeral_id": ephemeralId,
        },
      );
      return response.data['user_id'] as String;
    } on DioException catch (e) {
      throw Exception('ユーザーIDの解決に失敗: ${e.message}');
    }
  }

  /// バックグラウンドですれ違った相手のIDを送信する（POST /encounters）
  Future<EncounterRecordResult> recordEncounter({
    required String myId,
    String? targetId,
    String? targetToken,
  }) async {
    if ((targetId == null || targetId.isEmpty) &&
        (targetToken == null || targetToken.isEmpty)) {
      throw Exception('targetId か targetToken のどちらかが必要です');
    }

    final data = <String, dynamic>{
      'my_id': myId,
      if (targetId != null && targetId.isNotEmpty) 'target_id': targetId,
      if (targetToken != null && targetToken.isNotEmpty) ...{
        'target_token': targetToken,
        // 後方互換のため従来キーも併送
        'ephemeral_id': targetToken,
        'token': targetToken,
      },
    };

    final response = await _dio.post(
      '/encounters',
      data: data,
      options: Options(contentType: 'application/json'),
    );

    final status = response.statusCode ?? 0;
    final body = response.data;
    final message = body is Map<String, dynamic> ? body['message']?.toString() : null;

    return EncounterRecordResult(
      created: status == 201,
      message: message,
    );
  }

  /// すれ違い結果を確認済みにする（PUT /users/:id/encounters/confirm）
  Future<void> confirmAllEncounters(String userId) async {
    await _dio.put('/users/$userId/encounters/confirm');
  }

  /// 解除済み実績一覧を取得する（GET /users/:id/achievements）
  Future<List<UnlockedAchievement>> fetchUnlockedAchievements(String userId) async {
    final response = await _dio.get('/users/$userId/achievements');
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      return const [];
    }

    final achievements = (body['achievements'] as List?) ?? const [];
    return achievements
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => e['is_unlocked'] == true)
        .map(
          (e) => UnlockedAchievement(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
          ),
        )
        .where((a) => a.id.isNotEmpty)
        .toList();
  }
}

class EncounterRecordResult {
  final bool created;
  final String? message;

  const EncounterRecordResult({
    required this.created,
    this.message,
  });
}

class UnlockedAchievement {
  final String id;
  final String title;

  const UnlockedAchievement({required this.id, required this.title});
}

/// エフェメラルトークン（短期間有効なBLEアドバタイズ用トークン）
class EphemeralToken {
  final String token;
  final DateTime expiresAt;

  EphemeralToken({required this.token, required this.expiresAt});

  factory EphemeralToken.fromJson(Map<String, dynamic> json) {
    DateTime parseExpiresAt() {
      final expiresAtRaw = json['expires_at'];
      if (expiresAtRaw is String && expiresAtRaw.isNotEmpty) {
        return DateTime.parse(expiresAtRaw);
      }

      final expiresInRaw = json['expires_in'];
      final expiresInSec = int.tryParse(expiresInRaw?.toString() ?? '');
      if (expiresInSec != null) {
        return DateTime.now().add(Duration(seconds: expiresInSec));
      }

      return DateTime.now().add(const Duration(hours: 1));
    }

    return EphemeralToken(
      token: json['token'] as String,
      expiresAt: parseExpiresAt(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
