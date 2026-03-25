import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider));
});

/// ホーム画面のデータを取得するリポジトリ
class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  /// ホーム画面の表示に必要なデータを一括で取得する（GET /users/:id/home）
  /// 仕様レスポンス: {"total_encounters": 15, "today_encounters": 3, "unconfirmed": [...], "random_three": [...]}
  Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    final response = await _dio.get('/users/$userId/home');
    return response.data as Map<String, dynamic>;
  }
}
