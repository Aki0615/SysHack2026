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
