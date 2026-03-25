import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../user/domain/user_model.dart';

final plazaRepositoryProvider = Provider<PlazaRepository>((ref) {
  return PlazaRepository(ref.read(dioProvider));
});

/// 広場画面のすれ違い情報を取得するリポジトリ
class PlazaRepository {
  final Dio _dio;

  PlazaRepository(this._dio);

  /// ランダムで10人のすれ違い相手を取得する（GET /users/:id/encounters）
  ///
  /// ※仕様書のレスポンス例は単一のユーザーオブジェクトとなっているが、
  /// 役割として「10人取得します」と記載されているため、
  /// 単一オブジェクト通信・配列通信のどちらがバックエンドから返ってきても
  /// 安全にパースしてリスト化できるように実装。
  Future<List<UserModel>> fetchEncounters(String userId) async {
    final response = await _dio.get('/users/$userId/encounters');
    final data = response.data;

    if (data is List) {
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic>) {
      return [UserModel.fromJson(data)];
    }
    return [];
  }
}
