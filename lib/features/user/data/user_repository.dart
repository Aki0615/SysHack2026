import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_model.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(dioProvider));
});

/// ユーザー情報のAPI通信を担当するリポジトリ
/// バックエンドの GET /users/:id に合わせた実装
class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  /// ユーザー情報を取得する（GET /users/:id）
  Future<UserModel> getUser(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
    }
  }

  /// ユーザー情報を更新する（PATCH /users/:id）
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/users/$id', data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('ユーザー情報の更新に失敗しました: ${e.message}');
    }
  }
}
